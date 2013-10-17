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
chmod -R a+w ~/.gfx.js/

if [[ `which torch-lua` == '' ]]; then
    echo '==> torch not found, aborting... it must be in your path (this is a stupid installer)'
    exit -1
fi

DIR=`dirname \`which torch-lua\``/../share/torch/lua/gfx/
echo "==> installing torch client into" $DIR
mkdir -p $DIR || sudo mkdir -p $DIR
cp clients/torch/* $DIR 2> /dev/null || sudo cp clients/torch/* $DIR 2> /dev/null

echo "==> Torch client installed globally, run me like this:"
echo "$ torch -lgfx.start"
echo "or"
echo "$ torch -lgfx.go"
echo "(this will start the gfx server automatically)"
