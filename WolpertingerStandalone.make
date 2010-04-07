# GNU Make project makefile autogenerated by Premake
ifndef config
  config=debug
endif

ifndef verbose
  SILENT = @
endif

ifndef CC
  CC = gcc
endif

ifndef CXX
  CXX = g++
endif

ifndef AR
  AR = ar
endif

ifeq ($(config),debug)
  OBJDIR     = build/Debug/WolpertingerStandalone
  TARGETDIR  = build
  TARGET     = $(TARGETDIR)/Wolpertinger003-debug
  DEFINES   += -DLINUX=1 -DJUCE_USE_XSHM=1 -DJUCE_ALSA=1 -DJUCE_USE_VSTSDK_2_4=1 -DDATE="`date +%F`" -DVERSION=003 -DVERSIONSTRING="0.3" -DCONFIGURATION="Debug" -DCONFIG_STANDALONE=1 -DBINTYPE="Linux Standalone" -DDEBUG=1 -D_DEBUG=1
  INCLUDES  += -I../juce-git -I../vstsdk2.4 -Isrc
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -g -ggdb
  CXXFLAGS  += $(CFLAGS) 
  LDFLAGS   += -L../juce-git/bin -L../../../../usr/X11R6/lib -L../../../../usr/lib
  LIBS      += -lfreetype -lpthread -lrt -lX11 -lXext -lasound -lm -lGL -ljuce_debug
  RESFLAGS  += $(DEFINES) $(INCLUDES) 
  LDDEPS    += 
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH) $(LIBS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

ifeq ($(config),release)
  OBJDIR     = build/Release/WolpertingerStandalone
  TARGETDIR  = build
  TARGET     = $(TARGETDIR)/Wolpertinger003
  DEFINES   += -DLINUX=1 -DJUCE_USE_XSHM=1 -DJUCE_ALSA=1 -DJUCE_USE_VSTSDK_2_4=1 -DDATE="`date +%F`" -DVERSION=003 -DVERSIONSTRING="0.3" -DCONFIGURATION="Release" -DCONFIG_STANDALONE=1 -DBINTYPE="Linux Standalone" -DNDEBUG=1
  INCLUDES  += -I../juce-git -I../vstsdk2.4 -Isrc
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -O2 -O2
  CXXFLAGS  += $(CFLAGS) 
  LDFLAGS   += -s -L../juce-git/bin -L../../../../usr/X11R6/lib -L../../../../usr/lib
  LIBS      += -lfreetype -lpthread -lrt -lX11 -lXext -lasound -lm -lGL -ljuce
  RESFLAGS  += $(DEFINES) $(INCLUDES) 
  LDDEPS    += 
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH) $(LIBS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

OBJECTS := \
	$(OBJDIR)/PresetComboBox.o \
	$(OBJDIR)/RotatingToggleButton.o \
	$(OBJDIR)/synth.o \
	$(OBJDIR)/KeyboardButton.o \
	$(OBJDIR)/about.o \
	$(OBJDIR)/editor.o \
	$(OBJDIR)/tabbed-editor.o \
	$(OBJDIR)/wolpMain.o \

RESOURCES := \

SHELLTYPE := msdos
ifeq (,$(ComSpec)$(COMSPEC))
  SHELLTYPE := posix
endif
ifeq (/bin,$(findstring /bin,$(SHELL)))
  SHELLTYPE := posix
endif

.PHONY: clean prebuild prelink

all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET)

$(TARGET): $(GCH) $(OBJECTS) $(LDDEPS) $(RESOURCES)
	@echo Linking WolpertingerStandalone
	$(SILENT) $(LINKCMD)
	$(POSTBUILDCMDS)

$(TARGETDIR):
	@echo Creating $(TARGETDIR)
ifeq (posix,$(SHELLTYPE))
	$(SILENT) mkdir -p $(TARGETDIR)
else
	$(SILENT) mkdir $(subst /,\\,$(TARGETDIR))
endif

$(OBJDIR):
	@echo Creating $(OBJDIR)
ifeq (posix,$(SHELLTYPE))
	$(SILENT) mkdir -p $(OBJDIR)
else
	$(SILENT) mkdir $(subst /,\\,$(OBJDIR))
endif

clean:
	@echo Cleaning WolpertingerStandalone
ifeq (posix,$(SHELLTYPE))
	$(SILENT) rm -f  $(TARGET)
	$(SILENT) rm -rf $(OBJDIR)
else
	$(SILENT) if exist $(subst /,\\,$(TARGET)) del $(subst /,\\,$(TARGET))
	$(SILENT) if exist $(subst /,\\,$(OBJDIR)) rmdir /s /q $(subst /,\\,$(OBJDIR))
endif

prebuild:
	$(PREBUILDCMDS)

prelink:
	$(PRELINKCMDS)

ifneq (,$(PCH))
$(GCH): $(PCH)
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<
endif

$(OBJDIR)/PresetComboBox.o: src/PresetComboBox.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<
$(OBJDIR)/RotatingToggleButton.o: src/RotatingToggleButton.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<
$(OBJDIR)/synth.o: src/synth.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<
$(OBJDIR)/KeyboardButton.o: src/KeyboardButton.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<
$(OBJDIR)/about.o: src/about.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<
$(OBJDIR)/editor.o: src/editor.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<
$(OBJDIR)/tabbed-editor.o: src/tabbed-editor.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<
$(OBJDIR)/wolpMain.o: standalone/wolpMain.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<

-include $(OBJECTS:%.o=%.d)
