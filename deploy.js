const { exec } = require('child_process');
const path = require('path');

console.log('Current working directory:', process.cwd());

// Use the full path for the git binary
const gitPath = '/opt/homebrew/bin/git';

const command = `gh-pages -d build/web --git ${gitPath}`;
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
