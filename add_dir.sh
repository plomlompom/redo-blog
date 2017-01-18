#!/bin/sh

set -e

link_files_in_dir () {
  srcdir="$1"
  for file in "$srcdir"/* "$srcdir"/.*; do
    if [ -f "$file" ]; then
      set +e
      ln -s "$file"
      set -e
    elif [ -d "$file" ] && \
        [ $(basename "$file") != "." ] && \
        [ $(basename "$file") != ".." ]; then
      dir=$(basename "$file")
      mkdir -p "$dir"
      cd "$dir"
        link_files_in_dir "$srcdir/$dir"
      cd ..
    fi
  done
}

srcdir=`pwd`/processor
mkdir -p "$1"
cd "$1"
link_files_in_dir "$srcdir"
