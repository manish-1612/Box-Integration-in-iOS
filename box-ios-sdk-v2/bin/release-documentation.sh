#!/usr/bin/env bash

git checkout master
git fetch origin
git reset --hard origin/master
./bin/generate-documentation.sh
git checkout gh-pages
git reset --hard origin/gh-pages
cp -R docs/docset/Contents/Resources/Documents/* ./

