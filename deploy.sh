#!/bin/bash

export PATH="/opt/homebrew/bin:$PATH"
flutter clean
rm -rf build
flutter pub get
flutter pub outdated
npm run deploy
