# gfx.js: a browser-based graphics server

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

![](https://raw.github.com/clementfarabet/gfx.js/master/img/torchclient2.png)

Check out [tty.js](https://github.com/chjj/tty.js/) for reference on the
original project. Note: I'm simply extending their project, not modifying
any of the core structure, so it should remain compatible.

## Installation

You have to have Node.js (important, Version >= 0.10.0), NPM, and Torch7
installed. With older versions of Node.js, things won't be stable.

Then simply run:

```
./install.sh
```

## Execution

Once installed, you can start/stop the server like this:

```
torch -lgfx.start
torch -lgfx.stop
```

And then open up a tab in your browser, at [http://localhost:8000](http://localhost:8000).

You can optionally specify a different port as an env variable:

```
PORT=4321 torch -lgfx.start
PORT=4321 torch -lgfx.stop
```

On Mac OS, we provide a shortcut to start the server in the background and automatically
open the browser at the right location:

```
torch -lgfx.go
```

Alternatively, you can do things step by step:

```
torch -lgfx.start
# starts a server...
torch
# starts a Torch session
```

At the prompt, you can load the gfx.js client, and render things:

```lua
gfx = require 'gfx.js'
gfx.image(image.lena())
gfx.image({
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
   image.lena()
}, {zoom=0.5, legends={'Image 1', 'Image 2'}})
```

This will produce this output:

![](https://raw.github.com/clementfarabet/gfx.js/master/img/torchclient.png)

I've also slowly started to integrate plots from [NVD3](http://nvd3.org/), and bind
them to Torch, so that they can seamlessly be called from the Torch repl:

```lua
gfx.chart(data, {
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
values = torch.randn(100) -- in this case, y is provided, x defaults to range(0,N-1)

-- shortcuts are also provided for quick plots:
gfx.chart(torch.randn(100,2), {chart='scatter'})
gfx.chart(torch.randn(100), {chart='line'})  -- y is provided, x will be a range(1,N)
gfx.chart({ torch.randn(100), torch.randn(100) })  -- multiple datasets
gfx.chart({ {1,2,3,4,5,6,7,8,7,6,5,4,3,2,1}, torch.randn(100) })  -- multiple datasets, table format
```

One other way of using the graphics server is to use just run Torch in a regular 
terminal, and use the browser as a separate, asynchronous graphics server. Simply
start torch with gfx.js in your regular terminal:

```
torch -lgfx.go
> gfx.chart()
```

Doing this will automatically start up the node server, if not already done. Then
any call to the graphics functions will trigger a render event in the browser!
