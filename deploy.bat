
vuepress build docs

cd docs/.vuepress/dist

git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:TimeWz667/chai_press.git master:gh-pages

cd ../../../