#!/usr/bin/env bash

#
# Script for updating documentation.
#
# @copyright  copyright (c) 2020-present by Harald Lapp
# @author     Harald Lapp <harald@octris.org>
#

if [ "$1" = "" ]; then
  echo "usage: update.sh <path> [<path> ...]"
  exit
fi

if [ ! -d gh-pages ]; then
  git clone git@github.com:octris/phpdoc.git gh-pages -b gh-pages --depth=1
else
  (cd gh-pages && git pull)
fi

for i in $@; do
  target_dir=$(pwd)/gh-pages/$(basename $i)

  if [ ! -d $target_dir ]; then
    mkdir $target_dir
  fi

  phpdoc -d $1 -t $target_dir
done

exec 3> $(pwd)/gh-pages/index.html

cat <<EOF >&3
<html>
  <head>
    <title>Octris project documentation</title>
  </head>

  <body>
    <h1>Octris project documentation</h1>

    <ul>
EOF

for i in $(find $(pwd)/gh-pages/* -type d -maxdepth 0); do
  name="$(basename "$i")"

  echo "<li><a href=\"$name/\">$name</a></li>" >&3
done

cat <<EOF >&3
    </ul>
  </body>
</html>
EOF

exec 3<&-

cd gh-pages && \
  git add * && \
  git commit -m "updated repository" && \
  git push
