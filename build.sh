#!/bin/sh

set -xe

dist="./dist"
bin="./node_modules/.bin"

rm -rf $dist/*
npx elm-typescript-interop && webpack -p
$bin/node-sass -r src/style.scss -o .
mv style.css $dist
cp index.html  $dist/index.html
echo "Publishing app to $dist"
ls -lah $dist
