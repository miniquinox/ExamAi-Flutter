const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

console.log('NODE VERSION:', process.version);
console.log('PATH:', process.env.PATH);

// Check if git is available
exec('which git', (gitError, gitStdout, gitStderr) => {
  if (gitError) {
    console.error(`Git not found: ${gitError.message}`);
    return;
  }
  console.log(`Git found at: ${gitStdout.trim()}`);

  const cacheDir = path.join(process.env.HOME, '.gh-pages-cache');

  // Set GIT_EXEC_PATH and GH_PAGES_CACHE to ensure the correct paths are used
  const options = {
    env: {
      ...process.env,
      PATH: '/opt/homebrew/bin:' + process.env.PATH,
      GIT_EXEC_PATH: '/opt/homebrew/bin',
      GH_PAGES_CACHE: cacheDir
    },
  };

  // Create the cache directory if it doesn't exist
  exec(`mkdir -p ${cacheDir}`, (mkdirError, mkdirStdout, mkdirStderr) => {
    if (mkdirError) {
      console.error(`Error creating cache directory: ${mkdirError.message}`);
      return;
    }

    // Ensure the build directory exists
    const buildDir = path.join(__dirname, 'build/web');
    console.log(`Checking if build directory exists: ${buildDir}`);
    if (!fs.existsSync(buildDir)) {
      console.error(`Build directory does not exist: ${buildDir}`);
      return;
    } else {
      console.log(`Build directory exists: ${buildDir}`);
    }

    // Proceed with gh-pages deployment
    const command = `gh-pages -d ${buildDir}`;
    exec(command, options, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error: ${error.message}`);
        console.error(`stderr: ${stderr}`);
        return;
      }
      console.log(`stdout: ${stdout}`);
    });
  });
});
