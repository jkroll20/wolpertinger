#ifndef SYNTH_H
#define SYNTH_H

#include "juce.h"
#include "filters.h"
#include "ADSRenv.h"


template<typename T> T sqr(T v) { return v*v; }



class wolpSound: public SynthesiserSound
{
	public:
		bool appliesToNote(const int midiNoteNumber) { return true; }
		bool appliesToChannel(const int midiChannel) { return true; }
};

class WaveGenerator
{
	public:
		enum { oversampling = 16 };

		WaveGenerator():
			phase(0.0), cyclecount(0)
		{ }

		~WaveGenerator()
		{ }

		double getNextSample()
		{
			double s= 0;
			for(int i= 0; i<oversampling; i++)
			{
				if(oversampling>1)
					s+= filter.run(getNextRawSample());
				else
					s+= getNextRawSample();
			}
			return s/oversampling;
		}

		void setFrequency(double sampleRate, double noteFrequency)
		{
			sampleStep= noteFrequency / (sampleRate*oversampling);
			filter[0].calc_filter_coeffs(0, sampleRate*0.4, sampleRate*oversampling, 0.1, 0, true);
			filter.updateparams();
		}

		void setMultipliers(double mSaw, double mRect, double mTri)
		{
			float div= mSaw+mRect+mTri;
			if(div==0.0f) mSaw= div= 1.0;
			div= 1.0/div;
			sawFactor= mSaw*div;
			rectFactor= mRect*div;
			triFactor= mTri*div;
		}

	private:
		double sawFactor, rectFactor, triFactor, sampleStep, phase;
		int cyclecount;

		multifilter<CFxRbjFilter, 4> filter;

		double getNextRawSample()
		{
			double saw= phase,
				   rect= (phase<0.5? -1: 1),
				   tri= (cyclecount&1? 2-(phase+1)-1: phase);

			double val= saw*sawFactor+ rect*rectFactor + tri*triFactor;

			phase+= sampleStep;
			if (phase > 1)
				cyclecount++,
				phase -= 2;

			return val;
		}
};

class wolpVoice: public SynthesiserVoice
{
	public:
		wolpVoice(class wolp *s): synth(s)
		{
		}

		//==============================================================================
		bool canPlaySound (SynthesiserSound* sound) { return true; }

		void startNote (const int midiNoteNumber,
						const float velocity,
						SynthesiserSound* sound,
						const int currentPitchWheelPosition);

		void stopNote (const bool allowTailOff);

		void pitchWheelMoved (const int newValue) { }

		void controllerMoved (const int controllerNumber,
							  const int newValue) { }

		//==============================================================================
		void renderNextBlock (AudioSampleBuffer& outputBuffer, int startSample, int numSamples);

		void setvolume(double v) { vol= v; }
		void setfreq(double f) { freq= f; }

	protected:
		void process(float* p1, float* p2, int samples);

		double phase, low, band, high, vol, freq;
//		double curvol;
		bool playing;
		int cyclecount;

		WaveGenerator generator;
		bandpass<8> filter;
		ADSRenv env;

		class wolp *synth;
};



class wolp:	public AudioProcessor,
            public Synthesiser,
            public ChangeBroadcaster,
            public MidiKeyboardStateListener
{
	public:
		enum params
		{
			gain= 0,
			clip,
			gsaw,
			grect,
			gtri,
			tune,
			cutoff,
			resonance,
			bandwidth,
			velocity,
			inertia,
			nfilters,
			curcutoff,
			attack,
			decay,
			sustain,
			release,
			param_size
		};

		struct paraminfo
		{
			const char *internalname;
			const char *label;
			double min, max, defval;
		};
		static const paraminfo paraminfos[param_size];


		wolp();
		~wolp();

		const String getName() const { return "wolp"; }
		void prepareToPlay (double sampleRate, int estimatedSamplesPerBlock) { }
		void releaseResources() { }
		void processBlock (AudioSampleBuffer& buffer, MidiBuffer& midiMessages);
		const String getInputChannelName (const int channelIndex) const { return String("In") + String(channelIndex); }
		const String getOutputChannelName (const int channelIndex) const { return String("Out") + String(channelIndex); }
		bool isInputChannelStereoPair (int index) const { return true; }
		bool isOutputChannelStereoPair (int index) const { return true; }
		bool acceptsMidi() const  { return true; }
		bool producesMidi() const { return false; }
		AudioProcessorEditor* createEditor();
		int getNumParameters() { return param_size; }
		const String getParameterName (int idx) { return String(paraminfos[idx].label); }
		float getParameter (int idx)
		{
			return params[idx];
		}
		const String getParameterText (int idx)
		{
			switch(idx)
			{
				default:
					return String(getparam(idx), 2);
			}
		}
		void setParameter (int idx, float value);

		//==============================================================================
		int getNumPrograms() { return 1; };
		int getCurrentProgram() { return 0; };
		void setCurrentProgram (int index) { };
		const String getProgramName (int index) { return "Default"; };
		void changeProgramName (int index, const String& newName) {}

		//==============================================================================
		void getStateInformation (JUCE_NAMESPACE::MemoryBlock& destData);
		void setStateInformation (const void* data, int sizeInBytes);

		//==============================================================================
		double getnotefreq (int noteNumber)
		{
			noteNumber -= 12 * 6 + 9; // now 0 = A440
			return getparam(tune) * pow (2.0, noteNumber / 12.0);
		}

		float getparam(int idx);

        void loaddefaultparams();

		void renderNextBlock (AudioSampleBuffer& outputAudio,
							  const MidiBuffer& inputMidi,
							  int startSample,
							  int numSamples);

		//==============================================================================
		/** Called when one of the MidiKeyboardState's keys is pressed.

			This will be called synchronously when the state is either processing a
			buffer in its MidiKeyboardState::processNextMidiBuffer() method, or
			when a note is being played with its MidiKeyboardState::noteOn() method.

			Note that this callback could happen from an audio callback thread, so be
			careful not to block, and avoid any UI activity in the callback.
		*/
		virtual void handleNoteOn (MidiKeyboardState* source,
								   int midiChannel, int midiNoteNumber, float velocity)
		{
			noteOn(midiChannel, midiNoteNumber, velocity);
		}

		/** Called when one of the MidiKeyboardState's keys is released.

			This will be called synchronously when the state is either processing a
			buffer in its MidiKeyboardState::processNextMidiBuffer() method, or
			when a note is being played with its MidiKeyboardState::noteOff() method.

			Note that this callback could happen from an audio callback thread, so be
			careful not to block, and avoid any UI activity in the callback.
		*/
		virtual void handleNoteOff (MidiKeyboardState* source,
									int midiChannel, int midiNoteNumber)
		{
			noteOff(midiChannel, midiNoteNumber, velocity);
		}

	protected:

	private:
		float params[param_size];

		velocityfilter <float> cutoff_filter;

		unsigned long samples_synthesized;

		friend class wolpVoice;
		friend class editor;
};


#endif // SYNTH_H
