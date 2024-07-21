const { exec } = require('child_process');
const path = require('path');

console.log('Current working directory:', process.cwd());

const command = 'gh-pages -d build/web';
const options = {
  env: {
    ...process.env,
    PATH: '/opt/homebrew/bin:' + process.env.PATH,
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
