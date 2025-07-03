#!/bin/bash

PLUGIN_NAME=$1
VERSION=${2:-"1.0.0"}
OUTPUT_DIR="./$PLUGIN_NAME"
JUCE_SOURCE_PATH="~/dev/juce"  # Adjust this to where your JUCE is located

if [ -z "$PLUGIN_NAME" ]; then
    echo "Usage: $0 <PluginName> [version]"
    echo "Make sure JUCE is installed at: $JUCE_SOURCE_PATH"
    exit 1
fi

echo "Creating plugin: $PLUGIN_NAME v$VERSION"

# Create project directory
mkdir -p "$OUTPUT_DIR/Source"

# ────────────────────────────────────────────────────────────
# Copy/Link JUCE to the project
# ────────────────────────────────────────────────────────────
echo "Setting up JUCE modules..."

JUCE_SOURCE_PATH="~/JUCE"

# Expand the tilde path using the variable defined at top
JUCE_EXPANDED_PATH=$(eval echo $JUCE_SOURCE_PATH)

if [ ! -d "$JUCE_EXPANDED_PATH" ]; then
    echo "❌ JUCE not found at: $JUCE_EXPANDED_PATH"
    echo "Please install JUCE first:"
    echo "  cd ~"
    echo "  git clone https://github.com/juce-framework/JUCE.git JUCE"
    exit 1
fi

# Create symlink to JUCE (saves space, keeps up to date)
ln -sf "$JUCE_EXPANDED_PATH" "$OUTPUT_DIR/juce"

echo "✅ JUCE linked to project"

# Generate unique plugin codes
MANUFACTURER_CODE="CUR1"
PLUGIN_CODE=$(echo $PLUGIN_NAME | head -c 2 | tr '[:lower:]' '[:upper:]')$(printf "%02d" $((RANDOM % 100)))
BUNDLE_ID="com.curioaudio.$(echo $PLUGIN_NAME | tr '[:upper:]' '[:lower:]')"

# Create PluginProcessor.h
cat > "$OUTPUT_DIR/Source/PluginProcessor.h" << 'EOF'
/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>

//==============================================================================
/**
*/
class {{PLUGIN_NAME}}AudioProcessor  : public juce::AudioProcessor
{
public:
    //==============================================================================
    {{PLUGIN_NAME}}AudioProcessor();
    ~{{PLUGIN_NAME}}AudioProcessor() override;

    //==============================================================================
    void prepareToPlay (double sampleRate, int samplesPerBlock) override;
    void releaseResources() override;

   #ifndef JucePlugin_PreferredChannelConfigurations
    bool isBusesLayoutSupported (const BusesLayout& layouts) const override;
   #endif

    void processBlock (juce::AudioBuffer<float>&, juce::MidiBuffer&) override;

    //==============================================================================
    juce::AudioProcessorEditor* createEditor() override;
    bool hasEditor() const override;

    //==============================================================================
    const juce::String getName() const override;

    bool acceptsMidi() const override;
    bool producesMidi() const override;
    bool isMidiEffect() const override;
    double getTailLengthSeconds() const override;

    //==============================================================================
    int getNumPrograms() override;
    int getCurrentProgram() override;
    void setCurrentProgram (int index) override;
    const juce::String getProgramName (int index) override;
    void changeProgramName (int index, const juce::String& newName) override;

    //==============================================================================
    void getStateInformation (juce::MemoryBlock& destData) override;
    void setStateInformation (const void* data, int sizeInBytes) override;

private:
    //==============================================================================
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR ({{PLUGIN_NAME}}AudioProcessor)
};
EOF

# Create PluginProcessor.cpp
cat > "$OUTPUT_DIR/Source/PluginProcessor.cpp" << 'EOF'
/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
{{PLUGIN_NAME}}AudioProcessor::{{PLUGIN_NAME}}AudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
     : AudioProcessor (BusesProperties()
                     #if ! JucePlugin_IsMidiEffect
                      #if ! JucePlugin_IsSynth
                       .withInput  ("Input",  juce::AudioChannelSet::stereo(), true)
                      #endif
                       .withOutput ("Output", juce::AudioChannelSet::stereo(), true)
                     #endif
                       )
#endif
{
}

{{PLUGIN_NAME}}AudioProcessor::~{{PLUGIN_NAME}}AudioProcessor()
{
}

//==============================================================================
const juce::String {{PLUGIN_NAME}}AudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool {{PLUGIN_NAME}}AudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool {{PLUGIN_NAME}}AudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

bool {{PLUGIN_NAME}}AudioProcessor::isMidiEffect() const
{
   #if JucePlugin_IsMidiEffect
    return true;
   #else
    return false;
   #endif
}

double {{PLUGIN_NAME}}AudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int {{PLUGIN_NAME}}AudioProcessor::getNumPrograms()
{
    return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
                // so this should be at least 1, even if you're not really implementing programs.
}

int {{PLUGIN_NAME}}AudioProcessor::getCurrentProgram()
{
    return 0;
}

void {{PLUGIN_NAME}}AudioProcessor::setCurrentProgram (int index)
{
}

const juce::String {{PLUGIN_NAME}}AudioProcessor::getProgramName (int index)
{
    return {};
}

void {{PLUGIN_NAME}}AudioProcessor::changeProgramName (int index, const juce::String& newName)
{
}

//==============================================================================
void {{PLUGIN_NAME}}AudioProcessor::prepareToPlay (double sampleRate, int samplesPerBlock)
{
    // Use this method as the place to do any pre-playback
    // initialisation that you need..
}

void {{PLUGIN_NAME}}AudioProcessor::releaseResources()
{
    // When playback stops, you can use this as an opportunity to free up any
    // spare memory, etc.
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool {{PLUGIN_NAME}}AudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
{
  #if JucePlugin_IsMidiEffect
    juce::ignoreUnused (layouts);
    return true;
  #else
    // This is the place where you check if the layout is supported.
    // In this template code we only support mono or stereo.
    // Some plugin hosts, such as certain GarageBand versions, will only
    // load plugins that support stereo bus layouts.
    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()
     && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
        return false;

    // This checks if the input layout matches the output layout
   #if ! JucePlugin_IsSynth
    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
        return false;
   #endif

    return true;
  #endif
}
#endif

void {{PLUGIN_NAME}}AudioProcessor::processBlock (juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
    juce::ScopedNoDenormals noDenormals;
    auto totalNumInputChannels  = getTotalNumInputChannels();
    auto totalNumOutputChannels = getTotalNumOutputChannels();

    // In case we have more outputs than inputs, this code clears any output
    // channels that didn't contain input data, (because these aren't
    // guaranteed to be empty - they may contain garbage).
    // This is here to avoid people getting screaming feedback
    // when they first compile a plugin, but obviously you don't need to keep
    // this code if your algorithm always overwrites all the output channels.
    for (auto i = totalNumInputChannels; i < totalNumOutputChannels; ++i)
        buffer.clear (i, 0, buffer.getNumSamples());

    // This is the place where you'd normally do the guts of your plugin's
    // audio processing...
    // Make sure to reset the state if your inner loop is processing
    // the samples and the outer loop is handling the channels.
    // Alternatively, you can process the samples with the channels
    // interleaved by keeping the same state.
    for (int channel = 0; channel < totalNumInputChannels; ++channel)
    {
        auto* channelData = buffer.getWritePointer (channel);

        // ..do something to the data...
    }
}

//==============================================================================
bool {{PLUGIN_NAME}}AudioProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

juce::AudioProcessorEditor* {{PLUGIN_NAME}}AudioProcessor::createEditor()
{
    return new {{PLUGIN_NAME}}AudioProcessorEditor (*this);
}

//==============================================================================
void {{PLUGIN_NAME}}AudioProcessor::getStateInformation (juce::MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
}

void {{PLUGIN_NAME}}AudioProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}

//==============================================================================
// This creates new instances of the plugin..
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new {{PLUGIN_NAME}}AudioProcessor();
}
EOF

# Create PluginEditor.h
cat > "$OUTPUT_DIR/Source/PluginEditor.h" << 'EOF'
/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>
#include "PluginProcessor.h"

//==============================================================================
/**
*/
class {{PLUGIN_NAME}}AudioProcessorEditor  : public juce::AudioProcessorEditor
{
public:
    {{PLUGIN_NAME}}AudioProcessorEditor ({{PLUGIN_NAME}}AudioProcessor&);
    ~{{PLUGIN_NAME}}AudioProcessorEditor() override;

    //==============================================================================
    void paint (juce::Graphics&) override;
    void resized() override;

private:
    // This reference is provided as a quick way for your editor to
    // access the processor object that created it.
    {{PLUGIN_NAME}}AudioProcessor& audioProcessor;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR ({{PLUGIN_NAME}}AudioProcessorEditor)
};
EOF

# Create PluginEditor.cpp
cat > "$OUTPUT_DIR/Source/PluginEditor.cpp" << 'EOF'
/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
{{PLUGIN_NAME}}AudioProcessorEditor::{{PLUGIN_NAME}}AudioProcessorEditor ({{PLUGIN_NAME}}AudioProcessor& p)
    : AudioProcessorEditor (&p), audioProcessor (p)
{
    // Make sure that before the constructor has finished, you've set the
    // editor's size to whatever you need it to be.
    setSize (400, 300);
}

{{PLUGIN_NAME}}AudioProcessorEditor::~{{PLUGIN_NAME}}AudioProcessorEditor()
{
}

//==============================================================================
void {{PLUGIN_NAME}}AudioProcessorEditor::paint (juce::Graphics& g)
{
    // (Our component is opaque, so we must completely fill the background with a solid colour)
    g.fillAll (getLookAndFeel().findColour (juce::ResizableWindow::backgroundColourId));

    g.setColour (juce::Colours::white);
    g.setFont (15.0f);
    g.drawFittedText ("{{PLUGIN_NAME}}", getLocalBounds(), juce::Justification::centred, 1);
}

void {{PLUGIN_NAME}}AudioProcessorEditor::resized()
{
    // This is generally where you'll want to lay out the positions of any
    // subcomponents in your editor..
}
EOF

# Process templates to replace {{PLUGIN_NAME}}
sed -i '' "s/{{PLUGIN_NAME}}/$PLUGIN_NAME/g" "$OUTPUT_DIR/Source/PluginProcessor.h"
sed -i '' "s/{{PLUGIN_NAME}}/$PLUGIN_NAME/g" "$OUTPUT_DIR/Source/PluginProcessor.cpp"
sed -i '' "s/{{PLUGIN_NAME}}/$PLUGIN_NAME/g" "$OUTPUT_DIR/Source/PluginEditor.h"
sed -i '' "s/{{PLUGIN_NAME}}/$PLUGIN_NAME/g" "$OUTPUT_DIR/Source/PluginEditor.cpp"

# Create CMakeLists.txt with local juce folder
cat > "$OUTPUT_DIR/CMakeLists.txt" << CMAKE_EOF
#
# CMakeLists.txt – $PLUGIN_NAME (VST3-only, macOS universal)
#
cmake_minimum_required(VERSION 3.15)
project(${PLUGIN_NAME}Plugin VERSION $VERSION)
# ────────────────────────────────────────────────────────────
# 1.  JUCE: build only the core modules (faster, fewer errors)
# ────────────────────────────────────────────────────────────
set(JUCE_BUILD_EXTRAS   OFF CACHE BOOL "" FORCE)   # no Projucer / Host
set(JUCE_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)   # no demo apps
# ────────────────────────────────────────────────────────────
# 2.  Architectures – produce a fat binary on Apple Silicon
# ────────────────────────────────────────────────────────────
if (APPLE)
    set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "" FORCE)
endif()
# ────────────────────────────────────────────────────────────
# 3.  Add JUCE source tree (local juce folder)
# ────────────────────────────────────────────────────────────
add_subdirectory(juce)
# ────────────────────────────────────────────────────────────
# 4.  Declare the plug-in target         *** VST3 ONLY ***
# ────────────────────────────────────────────────────────────
juce_add_plugin($PLUGIN_NAME          # target / bundle name
    COMPANY_NAME         "Curio Audio"
    PRODUCT_NAME         "$PLUGIN_NAME"
    BUNDLE_ID            $BUNDLE_ID
    PLUGIN_MANUFACTURER_CODE $MANUFACTURER_CODE
    PLUGIN_CODE          $PLUGIN_CODE
    FORMATS              VST3
)
# ────────────────────────────────────────────────────────────
# 4.5 Code signing (use correct target path)
# ────────────────────────────────────────────────────────────
if(APPLE)
    add_custom_command(TARGET ${PLUGIN_NAME}_VST3 POST_BUILD
        COMMAND codesign --force --sign - "\$<TARGET_FILE:${PLUGIN_NAME}_VST3>"
        COMMENT "Code signing VST3 plugin"
    )
endif()
# ────────────────────────────────────────────────────────────
# 5.  Source files you actually compile
# ────────────────────────────────────────────────────────────
target_sources($PLUGIN_NAME PRIVATE
    Source/PluginProcessor.cpp
    Source/PluginEditor.cpp
)
# ────────────────────────────────────────────────────────────
# 6.  Link the JUCE modules you need
# ────────────────────────────────────────────────────────────
target_link_libraries($PLUGIN_NAME PRIVATE
    # Core modules (essential for any plugin)
    juce::juce_core
    juce::juce_data_structures
    juce::juce_events

    # Audio modules (for audio processing)
    juce::juce_audio_basics
    juce::juce_audio_devices
    juce::juce_audio_formats
    juce::juce_audio_processors
    juce::juce_audio_utils

    # GUI modules (for plugin interface)
    juce::juce_graphics
    juce::juce_gui_basics
    juce::juce_gui_extra

    # Plugin client (handles VST3/AU/AAX formats)
    juce::juce_audio_plugin_client

    # Optional but commonly used modules (uncomment as needed)
    # juce::juce_dsp                 # DSP utilities
    # juce::juce_opengl              # OpenGL graphics
    # juce::juce_cryptography        # Encryption utilities
    # juce::juce_video               # Video support
    # juce::juce_analytics           # Analytics
    # juce::juce_blocks_basics       # ROLI Blocks support
    # juce::juce_midi_ci             # MIDI CI support
    # juce::juce_osc                 # OSC support
    # juce::juce_product_unlocking   # License management
)
# ────────────────────────────────────────────────────────────
# 7.  Force VST3-only build, bypass param-ID clash guard
# ────────────────────────────────────────────────────────────
target_compile_definitions($PLUGIN_NAME PRIVATE
    JucePlugin_Build_VST=0
    JucePlugin_Build_VST3=1
    JUCE_FORCE_USE_LEGACY_PARAM_IDS=1
)
# ────────────────────────────────────────────────────────────
# 8.  Generate JuceHeader.h for this target
# ────────────────────────────────────────────────────────────
juce_generate_juce_header($PLUGIN_NAME)
CMAKE_EOF

# Create package.json
cat > "$OUTPUT_DIR/package.json" << JSON_EOF
{
  "name": "$(echo $PLUGIN_NAME | tr '[:upper:]' '[:lower:]')",
  "version": "$VERSION",
  "description": "$PLUGIN_NAME VST3 Plugin",
  "scripts": {
    "build": "cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build build -j8",
    "build:debug": "cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug && cmake --build build -j8",
    "clean": "rm -rf build",
    "rebuild": "npm run clean && npm run build",
    "install": "find build -name '*.vst3' -type d -exec cp -R {} ~/Library/Audio/Plug-Ins/VST3/ ';' && echo '✅ Installed to VST3 folder'",
    "dev": "npm run build && npm run install",
    "show:build": "open build",
    "show:vst3": "open ~/Library/Audio/Plug-Ins/VST3/",
    "validate": "find ~/Library/Audio/Plug-Ins/VST3/ -name '$PLUGIN_NAME.vst3' -type d && echo '✅ Plugin is installed' || echo '❌ Plugin not found'",
    "ableton": "open -a 'Ableton Live 12 Suite'"
  },
  "keywords": ["vst3", "plugin", "audio", "juce"],
  "author": "Curio Audio",
  "license": "Proprietary"
}
JSON_EOF

# Create .gitignore
cat > "$OUTPUT_DIR/.gitignore" << 'GITIGNORE_EOF'
build/
*.xcodeproj/
.DS_Store
*.dSYM/
.vscode/
.idea/
node_modules/
GITIGNORE_EOF

# Create README
cat > "$OUTPUT_DIR/README.md" << README_EOF
# $PLUGIN_NAME

VST3 Audio Plugin built with JUCE

## Quick Start

\`\`\`bash
npm run dev          # Build + install for testing
npm run ableton      # Launch Ableton to test
\`\`\`

## Build Commands

\`\`\`bash
npm run build        # Build release version
npm run build:debug  # Build debug version
npm run dev          # Build + install locally
npm run install      # Install to VST3 folder
npm run clean        # Clean build directory
npm run rebuild      # Clean + build
\`\`\`

## Plugin Info

- **Name**: $PLUGIN_NAME
- **Version**: $VERSION
- **Plugin Code**: $PLUGIN_CODE
- **Bundle ID**: $BUNDLE_ID
- **Company**: Curio Audio

## Testing

1. \`npm run dev\` - Build and install
2. \`npm run validate\` - Confirm installation
3. \`npm run ableton\` - Launch DAW to test
4. Look for "$PLUGIN_NAME" under "Curio Audio"

## Project Structure

\`\`\`
$PLUGIN_NAME/
├── Source/
│   ├── PluginProcessor.cpp
│   ├── PluginProcessor.h
│   ├── PluginEditor.cpp
│   └── PluginEditor.h
├── juce/               # JUCE framework (symlinked)
├── CMakeLists.txt      # Build configuration
├── package.json        # npm scripts
└── README.md
\`\`\`
README_EOF

echo "✅ Plugin $PLUGIN_NAME created successfully!"
echo "   Plugin Code: $PLUGIN_CODE"
echo "   Bundle ID: $BUNDLE_ID"
echo "   JUCE: Linked from $JUCE_SOURCE_PATH"
echo ""
echo "Project structure:"
echo "  $PLUGIN_NAME/"
echo "  ├── Source/           # Your plugin code"
echo "  ├── juce/            # JUCE framework (symlink)"
echo "  ├── CMakeLists.txt   # Build configuration"
echo "  └── package.json     # npm build scripts"
echo ""
echo "Ready to build:"
echo "  cd $PLUGIN_NAME"
echo "  npm run dev"
