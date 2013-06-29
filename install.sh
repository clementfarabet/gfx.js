#!/usr/bin/env bash

echo "==> installing deps"
unset CC CXX
npm install

echo "==> installing static resources into ~/.tty.js/"
mkdir -p ~/.tty.js/
cp -r * ~/.tty.js/

DIR=`torch-lua -lpaths -e "print(paths.install_lua_path)"`/ttyjs/
echo "==> installing torch client into" $DIR
mkdir -p $DIR
if [ $? -ne 0 ]; then
    sudo mkdir -p $DIR
fi
cp clients/torch/* $DIR
if [ $? -ne 0 ]; then
    sudo cp clients/torch/* $DIR
fi

echo "==> run me like this:"
echo "$ node ~/.tty.js/server.js"

