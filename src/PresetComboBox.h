#ifndef PRESETCOMBOBOX_H
#define PRESETCOMBOBOX_H

#include "juce.h"


class PresetComboBox : public ComboBox
{
	public:
		PresetComboBox(const String &name);
		virtual ~PresetComboBox();
		void initItems();
	protected:
	private:
};

#endif // PRESETCOMBOBOX_H
