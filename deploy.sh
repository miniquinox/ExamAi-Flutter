#!/bin/bash

# Set PATH to include homebrew binaries
export PATH="/opt/homebrew/bin:$PATH"

# Log the PATH for debugging purposes
echo "Current PATH: $PATH"

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
  echo 'app.examai.ai' > build/web/CNAME

  # Navigate to the build directory
  cd build/web

  # Initialize a new Git repository
  git init

  # Add all files to the repository
  git add .

  # Commit the files
  git commit -m "Deploy to GitHub Pages"

  # Add your GitHub repository as a remote
  git remote add origin https://github.com/miniquinox/ExamAi-Flutter.git

  # Force push the files to the gh-pages branch
  git push -f origin master:gh-pages

  # Navigate back to the project root
  cd ../..
else
  echo "Error: Build directory does not exist. Please check the build process."
  exit 1
fi
