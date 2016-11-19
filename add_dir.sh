#!/bin/sh

set -e

curdir=`pwd`
mkdir -p "$1"
cd "$1"
for file in "$curdir"/*.do "$curdir"/helpers.sh "$curdir"/intermediate.tmpl; do
  set +e
  ln -s "$file"
  set -e
done 
