#!/bin/bash

flutter clean
rm -rf build
flutter pub get
flutter pub outdated
npm run deploy
