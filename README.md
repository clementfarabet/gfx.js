# tty.js + HTML Injection

Originally forked from the amazing [tty.js](https://github.com/chjj/tty.js/).

The goal is to extend this project to support the creation of rich media windows,
on top of the terminal windows.

The idea is simple: the server watches a directory, and monitors the creation &
modification of HTML files; upong modification / creation, it creates a new window
on the client side (browser), which simply render the HTML. 

Clients are easy to develop: one simply needs to dump HTML into the watched
directory to have it rendered by the browser.

For now, I'm focusing on one client, written in Lua, for 
[Torch7](https://github.com/andresy/torch).

Check out [tty.js](https://github.com/chjj/tty.js/) for reference on the
original project. Note: I'm simply extending their project, not modifying
any of the core structure, so it should remain compatible.

## Installation

Just run:

```
./install.sh
```

It assumes that you already have Node.js, NPM, and Torch7 installed (the later
is the only supported client for now).

## Execution

Once installed, you can run the server like this:

```
node ~/.tty.js/server.js
```

And then open up a tab in your browser, at [http://localhost:8000](http://localhost:8000).

Start up a terminal, and then run Torch:

```
torch
```

At the prompt, you can load the tty.js client, and render things:

```lua
t = require 'ttyjs'
require 'image'
t.image(image.lena())
t.images({
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
}, 0.5)
```

This will produce this output:

-![](https://raw.github.com/clementfarabet/tty.js/master/img/torchclient.jpg)

