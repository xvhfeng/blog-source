#!/bin/bash

bundle exec jekyll build --incremental
git add ./
git checkout master
git commit -m"publish"
git push

cd ../blog/
git checkout gh-pages
rm -rf _site
cp -rf ../blog/_site ./
git add ./
git commit -m"publish"
git push


