#!/bin/sh

set -e
npx poi --prod

dist="./dist"
js="$dist/elm.js"
minjs="$dist/elm.min.js"
bin="./node_modules/.bin"
$bin/elm make src/Main.elm --optimize --output=$js $@
$bin/uglifyjs --mangle --output=a $js
mv a $minjs
$bin/node-sass -r style.scss -o .
cp style.css $dist

echo "Initial size: $(($(cat $js | wc -c)/1024)) Kb    ($js)"
echo "Minified size: $(($(cat $minjs | wc -c)/1024)) Kb    ($minjs)"

echo "Publishing app to $dist"
cat $dist/index.html | sed -e 's/="\/assets/="assets/g' > a
mv a $dist/index.html
