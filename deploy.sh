#!/bin/bash

# Set PATH to include homebrew binaries
export PATH="/opt/homebrew/bin:$PATH"

# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build the web app
flutter build web

# Ensure the build directory exists
if [ -d "build/web" ]; then
  echo "Build directory exists, proceeding with deployment..."

  # Create CNAME file
  echo 'examai.ai' > build/web/CNAME

  # Deploy to GitHub Pages
  gh-pages -d build/web
else
  echo "Error: Build directory does not exist. Please check the build process."
  exit 1
fi
