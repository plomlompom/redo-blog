#!/bin/sh

set -e

link_files_in_dir () {
  local parent_dir="$1"
  for file in "$parent_dir"/* "$parent_dir"/.*; do
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
        link_files_in_dir "$parent_dir/$dir"
      cd ..
    fi
  done
}

src_dir=`pwd`/processor
mkdir -p "$1"
cd "$1"
link_files_in_dir "$src_dir"
