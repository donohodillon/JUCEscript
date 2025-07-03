# JUCE Plugin Generator

A bash script that generates a complete JUCE audio plugin project with modern CMake build system and npm-style workflow.

## Features

- **Cross-platform**: Works on macOS and Linux
- **Modern CMake**: Clean, maintainable build configuration
- **npm-style workflow**: Familiar build commands (`npm run build`, `npm run dev`)
- **Universal binaries**: Automatically builds for both Intel and Apple Silicon on macOS
- **Multi-format support**: VST3 and AU (macOS) plugin formats
- **Code signing**: Automatic code signing on macOS
- **Symlinked JUCE**: Efficient disk usage and easy updates

## Quick Start

```bash
# Download the script
wget https://raw.githubusercontent.com/yourusername/juce-plugin-generator/main/create-juce-plugin.sh
chmod +x create-juce-plugin.sh

# Install JUCE (if not already installed)
cd ~
git clone https://github.com/juce-framework/JUCE.git JUCE

# Create a plugin
./create-juce-plugin.sh MyAwesomePlugin 1.0.0

# Build and test
cd MyAwesomePlugin
npm run dev
