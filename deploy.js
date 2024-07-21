const { exec } = require('child_process');
const path = require('path');

const gitPath = '/opt/homebrew/bin/git'; // Ensure this is the correct path

console.log('NODE VERSION:', process.version);
console.log('PATH:', process.env.PATH);

const command = `PATH=${path.dirname(gitPath)}:$PATH gh-pages -d build/web`;
const options = {
  env: {
    ...process.env,
    PATH: `/opt/homebrew/bin:/opt/homebrew/Cellar/git/2.45.2/bin:` + process.env.PATH,
    GIT_EXEC_PATH: '/opt/homebrew/Cellar/git/2.45.2/libexec/git-core', // Adding GIT_EXEC_PATH
  },
};

exec(command, options, (error, stdout, stderr) => {
  if (error) {
    console.error(`Error: ${error.message}`);
    return;
  }
  if (stderr) {
    console.error(`stderr: ${stderr}`);
    return;
  }
  console.log(`stdout: ${stdout}`);
});
