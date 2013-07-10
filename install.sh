#!/usr/bin/env bash

echo "==> installing Node.js dependencies"
if [[ `which npm` == '' ]]; then
    echo '==> npm not found, aborting... please install Node.js + NPM'
    exit -1
fi
npm install

echo "==> installing static resources into ~/.gfx.js/"
mkdir -p ~/.gfx.js/
cp -r * ~/.gfx.js/

DIR=`torch-lua -lpaths -e "print(paths.install_lua_path)"`/gfx/
echo "==> installing torch client into" $DIR
mkdir -p $DIR || sudo mkdir -p $DIR
cp clients/torch/* $DIR || sudo cp clients/torch/* $DIR

echo "==> graphics server installed in ~/.gfx.js:"
echo "$ node ~/.gfx.js/server.js"

echo "==> Torch client installed globally, run me like this:"
echo "$ torch -lgfx.go"
echo "(this will start the gfx server automatically)"
