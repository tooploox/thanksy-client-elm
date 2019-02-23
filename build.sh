#!/bin/sh

set -xe

dist="./dist"
rm -rf $dist/*
bin="./node_modules/.bin"
npx elm-typescript-interop && webpack -p
$bin/node-sass -r src/style.scss -o .
mv style.css $dist

echo "Publishing app to $dist"
cat index.html | sed -e 's/.script src=.*vendors~index.bundle.*//g' > $dist/index.html
