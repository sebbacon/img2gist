#!/bin/bash

# Bail on errors.
set -e

# Check the user has `jist(1)` installed.
[ `command -v jist` ] || (echo "img2gist: Please 'gem install jist' first" && exit 1)

# Show usage if no arguments are given.
if [ "$#" = "0" ]; then
  echo 'Usage:  img2gist <path-to-file>'
  exit 1
fi

DIR="$(pwd)"
trap cleanup EXIT
# Given a path to an image, gist it
function upload_image {
 echo "uploading..."
 GIST_URL=$(echo "yo whatevs" | jist)
 echo $GIST_URL | sed -e 's/https:\/\//git@/' | sed -e 's/\//:/' | sed -e 's/$/.git/' | xargs --replace=REPO git clone REPO .tmp
 cd .tmp
 git rm a.rb
 FILENAME=$(basename "$1")
 cp "$1" .
 git add "$FILENAME"
 git commit -a -m "Added image"
 git push
 cd ..
 echo "*** Image now at $GIST_URL"
 exit 0
}

function cleanup {
    echo "Cleaning up $DIR/.tmp"
    rm -rf "$DIR/.tmp"
}

if [ -f "$1" ]; then
  # The user has provided a file, convert it and gist it.
  upload_image "$1"
else
    echo "Could not find file $1"
    exit 1
fi
