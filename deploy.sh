#!/bin/bash

export PATH="/opt/homebrew/bin:$PATH"
flutter clean
rm -rf build
flutter pub get
flutter pub outdated

echo "Building web..."
flutter build web && echo 'examai.ai' > build/web/CNAME

# Check if the build/web directory exists
if [ -d "build/web" ]; then
  echo "Build directory exists, proceeding with deployment..."

  echo "Deploying to GitHub Pages..."
  node deploy.js
else
  echo "Error: Build directory does not exist. Please check the build process."
  exit 1
fi
