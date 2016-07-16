#!/bin/bash
set -e # exit with nonzero exit code if anything fails

# squash messages
git config --global push.default matching

# prepare respec build

# clear the respec directory
#rm -rf respec || exit 0;

cd ${DIR_NAME}
git clone "https://${GH_TOKEN}@${GH_REF}"
cd ${REPO_NAME}

git config user.name "Dataset Site Generator Update Bot"
git config user.email "hello@openactive.io"

echo "metadata.json:"
cat metadata.json
echo ""
echo "Performing merge..."

# Configure git's merge to permanently ignore all upstream changes to locally-changed files
git config merge.pin.driver true
echo index.html merge=pin >> .git/info/attributes
echo metadata.json merge=pin >> .git/info/attributes
echo images/bg.jpg merge=pin >> .git/info/attributes
echo images/logo.png merge=pin >> .git/info/attributes

git remote add upstream git@github.com:openactive/dataset-site-generator.git
git fetch upstream
git pull upstream master -Xtheirs

echo ""
echo "Regenerating index.html..."

../../../generator-standalone.js --template generator/template.html --metadata metadata.json --output index.html

echo ""
echo "Committing index.html..."
git add index.html
git commit -m "Regeneration of index.html by DSG Update Bot"

echo ""
echo "Pushing..."


echo ""

exit 0

# get existing gh-pages
git clone -b develop "https://github.com/openactive/respec.git"

cd respec

# npm install #note: not required for phantom

cd ..


# clear and re-create the out directory
rm -rf out || exit 0;
mkdir out;

# go to the out directory and create a *new* Git repo
cd out
git init

# inside this git repo we'll pretend to be a new user
git config user.name "Travis CI"
git config user.email "travis@openactive.org"

# compile using respec2html (handling each version separately)
function respec2html {
  rm $2
  echo Running respec2html Nightmare for $3
  node respec/tools/respec2html.js --haltonerror --haltonwarn --src $1 --out $2
  {
  if [ ! -f $2 ]; then
      echo "respect2html Nightmare failed to generate index.html for $3"
      exit 2
  fi
  }
}

# old version using phantom still available in case of issues
function respec2htmlPhantom {
  rm $2
  echo Running respec2html Phantom for $3
  phantomjs --ssl-protocol=any respec/tools/respec2html-phantom.js -e -w $1 $2 15000
  {
  if [ ! -f $2 ]; then
      echo "respect2html Phantom failed to generate index.html for $3"
      exit 2
  fi
  }
}



echo Copying static files
cp -r ../0.1.0 .
cp -r ../0.2.2 .
cp -r ../0.2.3 .
cp -r ../EditorsDraft/* .

cd ..

respec2html "file://$PWD/0.2.3/index.html" "$PWD/out/0.2.3/index.html" "0.2.3"
respec2html "file://$PWD/EditorsDraft/index.html" "$PWD/out/index.html" "EditorsDraft"

cd out

# curl "https://labs.w3.org/spec-generator/?type=respec&url=http://openactive.github.io/spec-template/index.html" > index.static.html;

# The first and only commit to this new Git repo contains all the
# files present with the commit message "Deploy to GitHub Pages".
git add .
git commit -m "Deploy to GitHub Pages - Static"

# Force push from the current repo's master branch to the remote
# repo's gh-pages branch. (All previous history on the gh-pages branch
# will be lost, since we are overwriting it.) We redirect any output to
# /dev/null to hide any sensitive credential data that might otherwise be exposed.
#git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages > /dev/null 2>&1

git push --force --quiet "git@github.com:openactive/realtime-paged-data-exchange.git" master:gh-pages > /dev/null 2>&1

cd ..
