#!/bin/bash

echo "🚀 Setting up Flutter environment..."

# Install dependencies
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Download and install Flutter
if [ ! -d "/usr/local/flutter" ]; then
    echo "📥 Downloading Flutter SDK..."
    git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
else
    echo "✅ Flutter already installed, updating..."
    cd /usr/local/flutter && git pull origin stable
fi

# Add Flutter to PATH
export PATH="$PATH:/usr/local/flutter/bin"

# Accept Android licenses
echo "📱 Setting up Android..."
flutter doctor --android-licenses

# Get Flutter packages
echo "📦 Installing Flutter packages..."
flutter pub get

# Run Flutter doctor
echo "🔍 Flutter Doctor:"
flutter doctor

echo "✅ Setup complete! You can now run 'flutter run' to start the app."
