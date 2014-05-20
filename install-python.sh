#!/usr/bin/env bash
set -e

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

cd clients/python/
if [[ $EUID -ne 0 ]]; then
    echo "==> installing gfx.py locally"
    python setup.py install --user
else
    echo "==> installing gfx.py globally"
    python setup.py install
fi
cd -

echo "==> Python client installed, run me like this:"
echo "$ gfx-start: Start and show the server"
echo "$ gfx-stop: Stop the server"


