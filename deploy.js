const { exec } = require('child_process');

console.log('PATH:', process.env.PATH);

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
