var tty = require('./');
var fs = require('fs');

var config;
// check for $HOME/.gfx.js/config.json
var configFile = process.env.HOME + '/.gfx.js/config.json'
console.log('Checking for custom config at ' + configFile)
if (fs.existsSync(configFile)) {
    config  = JSON.parse(fs.readFileSync(configFile, 'utf8'));
    console.log('Custom config found')
} else {
    console.log('Custom config not found, using defaults');
    // Default config
    config = {
	shell: 'bash',
	port: 8000,
	static: process.env.HOME + '/.gfx.js/static',
    }
}

console.log(config);
var app = tty.createServer(config);

app.get('/foo', function(req, res, next) {
  res.send('bar');
});

app.listen();
