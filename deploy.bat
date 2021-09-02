#!/usr/bin/env sh

# abort on errors

npm run build

cd src/.vuepress/dist

git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:TimeWz667/chai_press.git master:gh-pages

cd ../