package = "gfx.js"
version = "scm-0"

source = {
   url = "git://github.com/clementfarabet/gfx.js",
   dir = "gfx.js"
}

description = {
   summary = "A graphics backend for the browser, with a Torch7 client.",
   detailed = [[
A graphics backend for the browser, with a Torch7 client.
   ]],
   homepage = "https://github.com/clementfarabet/gfx.js",
   license = "MIT"
}

dependencies = {
   "torch >= 7.0",
   "image >= 1.0",
   "penlight >= 1.1.0",
   "graphicsmagick >= 1.scm"
}

build = {
   type = "command",
   build_command = "ls",
   install_command = "bash install.sh"
}
