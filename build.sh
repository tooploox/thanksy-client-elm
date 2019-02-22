#!/bin/sh

set -e
npx poi --prod

dist="./dist"
js="elm.js"
minName="elm.min.js"
min="$dist/$minName"
bin="./node_modules/.bin"
$bin/elm make src/Main.elm --optimize --output=$js $@
$bin/uglifyjs --mangle --output=$min $js
$bin/node-sass -r style.scss -o .
cp style.css $dist
cp $js $dist

echo "Initial size: $(($(cat $js | wc -c)/1024)) Kb   ($js)"
echo "Minified size: $(($(cat $min | wc -c)/1024)) Kb   ($min)"

echo "Publishing app to $dist"
cat $dist/index.html | sed -e 's/="\/assets/="assets/g' > a
mv a $dist/index.html
