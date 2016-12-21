#!/bin/sh

metadata_dir=.meta

# Remove target files for which no sources files can be found.
for file in "$metadata_dir"/*.intermediate; do
  basename=$(basename "$file")
  if   test -f "$file" &&
     ! test -f "${basename%.intermediate}.md" &&
     ! test -f "${basename%.intermediate}.rst"; then
    rm "$file"
  fi
done
for file in "$metadata_dir"/*.uuid; do
  basename=$(basename "$file")
  if   test -f "$file" &&
     ! test -f "${basename%.uuid}.md" &&
     ! test -f "${basename%.uuid}.rst"; then
    rm "$file"
  fi
done
for file in *.html; do
  if   test -f "$file" &&
     ! test "$file" = "index.html" &&
     ! test -f "${metadata_dir}/${file%.html}.intermediate"; then
    rm "$file"
  fi
done

# Determine target files from the sources files present, declare dependencies
# of the all.do script on them / build them if necessary.
for file in *.rst *.md; do
  if test -f "$file"; then
    redo-ifchange "${metadata_dir}/${file%.*}.intermediate"
  fi
done
for file in "$metadata_dir"/*.intermediate; do
  if test -f "$file"; then
    basename=$(basename "$file")
    redo-ifchange "${basename%.intermediate}.html"
  fi
done

# Regenerate feed and index pages. Always.
redo "feed.xml"
redo "index.html"
