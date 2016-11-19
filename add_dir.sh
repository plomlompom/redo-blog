#!/bin/sh

set -e

srcdir=`pwd`/processor
mkdir -p "$1"
cd "$1"
for file in "$srcdir"/*; do
  set +e
  ln -s "$file"
  set -e
done 
