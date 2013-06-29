#!/usr/bin/env bash

echo "==> installing static resources into ~/.tty.js/"
mkdir -p ~/.tty.js/
cp -r * ~/.tty.js/

DIR=`torch-lua -lpaths -e "print(paths.install_lua_path)"`/ttyjs/
echo "==> installing torch client into" $DIR
mkdir -p $DIR
cp clients/torch/* $DIR

echo "==> run me like this:"
echo "$ node ~/.tty.js/server.js"

