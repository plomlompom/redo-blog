#!/bin/sh

# Remove target files for which no sources files can be found.
for file in *.intermediate; do
  if   test -f "$file" &&
     ! test -f "${file%.intermediate}.md" &&
     ! test -f "${file%.intermediate}.rst"; then
    rm "$file"
  fi
done
for file in *.uuid; do
  if   test -f "$file" &&
     ! test -f "${file%.uuid}.md" &&
     ! test -f "${file%.uuid}.rst"; then
    rm "$file"
  fi
done
for file in *.html; do
  if   test -f "$file" &&
     ! test "$file" = "index.html" &&
     ! test -f "${file%.html}.intermediate"; then
    rm "$file"
  fi
done

# Determine target files from the sources files present, declare dependencies
# of the all.do script on them / build them if necessary.
for file in *.rst *.md; do
  if test -f "$file"; then
    redo-ifchange "${file%.*}.intermediate"
  fi
done
for file in *.intermediate; do
  if test -f "$file"; then
    redo-ifchange "${file%.*}.html"
  fi
done

# Regenerate feed and index pages. Always.
redo "feed.xml"
redo "index.html"
