var tty = require('./');

var app = tty.createServer({
    shell: 'bash',
    port: 8000,
    static: process.env.HOME + '/.gfx.js/static'
    // syncSession: true,
    // sessionTimeout: 3600*24*1000,
    // users: {
    //     u:"p"
    // }
});

app.get('/foo', function(req, res, next) {
  res.send('bar');
});

app.listen();
