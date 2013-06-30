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

![](https://raw.github.com/clementfarabet/tty.js/master/img/torchclient2.png)

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
js = require 'tty.js'
js.image(image.lena())
js.image({
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
}, {zoom=0.5})
```

This will produce this output:

![](https://raw.github.com/clementfarabet/tty.js/master/img/torchclient.png)

I've also slowly started to integrate plots from [NVD3](http://nvd3.org/), and bind
them to Torch, so that they can seamlessly be called from the Torch repl:

```lua
js.chart(data, {
   chart = 'line', -- or: bar, stacked, multibar, scatter
   width = 600,
   height = 450,
})

-- where data has the form:
data = {
    {
        key = 'Legend 1',
        color = '#0f0',
        values = { {x=0,y=0}, {x=1,y=1}, ... },
    },
    {
        key = 'Legend 2',
        color = '#00f',
        values = { {x=0,y=0}, {x=1,y=1}, ... },
    },
}

-- or, for a single dataset:
data = {
    key = 'Legend',
    values = { {x=0,y=0} , ... }
}

-- values can be provided in convenient ways:
values = { {x=0,y=0[,size=0]}, ... }
values = { {0,0,0}, ... }
values = torch.randn(100,2)
values = torch.randn(100,3)  -- the 3rd dimension is the optional size, only used by certain charts
```
