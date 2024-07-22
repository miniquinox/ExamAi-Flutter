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
  echo 'examai.ai' > build/web/CNAME

  # Run the deployment command using Node.js
  node -e "
    const { exec } = require('child_process');
    const command = 'gh-pages -d build/web';
    const options = {
      env: {
        ...process.env,
        PATH: '/opt/homebrew/bin:' + process.env.PATH,
      },
    };

    exec(command, options, (error, stdout, stderr) => {
      if (error) {
        console.error('Deployment error:', error.message);
        return;
      }
      if (stderr) {
        console.error('Deployment stderr:', stderr);
        return;
      }
      console.log('Deployment stdout:', stdout);
    });
  "
else
  echo "Error: Build directory does not exist. Please check the build process."
  exit 1
fi
