#!/bin/sh

set -ex
dist="./dist"
rm -rf $dist
mkdir $dist
js="elm.js"
min="elm.min.js"
bin="./node_modules/.bin"
$bin/elm make src/Main.elm --optimize --output=$js $@
$bin/uglifyjs --mangle --output=$dist/$min $js
$bin/node-sass -r style.scss -o .
cp style.css $dist

echo "Initial size: $(cat $js | wc -c)   ($js)"
echo "Minified size:$(cat $min | wc -c)   ($dist/$min)"

echo "Publishing app to /dist"

cat index.html | sed -e "s/$js/$min/g" > $dist/index.html
