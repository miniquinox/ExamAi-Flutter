#!/bin/bash

export PATH="/opt/homebrew/bin:$PATH"
flutter clean
rm -rf build
flutter pub get
flutter pub outdated

echo "Building web..."
flutter build web && echo 'examai.ai' > build/web/CNAME

echo "Deploying to GitHub Pages..."
PATH="/opt/homebrew/bin:$PATH" npx gh-pages -d build/web
