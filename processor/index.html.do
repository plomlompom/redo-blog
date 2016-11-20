#!/bin/sh

# Pull in global dependencies.
. ./helpers.sh
title_file=title.meta
redo-ifchange "$title_file"

# Write index head.
cat << EOF
<!DOCTYPE html>
<html>
<head>
EOF
blog_title=`read_and_escape_file "$title_file" | head -1`
printf "<title>%s</title>\n</head>\n<body>\n" "$blog_title"
printf "<h1>%s</h1>\n<ul>\n" "$blog_title"

# Iterate through entries sorted by lastmod of their source files, write entry.
# FIXME: This ls parsing is a bad way to loop through the sorted files. Besides,
# $('\0') is a bashism.
first_run=0
files=`ls -1t *.rst *.md | tr '\n' $'\0'`
oldIFS="$IFS"
IFS=$'\0'
for file in $files; do
  if [ "$first_run" -lt "1" ]; then
    IFS="$oldIFS"
    first_run=1
  fi
  intermediate_file="${file%.*}.intermediate"
  html_file="${file%.*}.html"
  redo-ifchange "$intermediate_file"
  redo-ifchange "$html_file"
  title_html=`cat "$intermediate_file" | head -1`
  html_file_escaped=`escape_url "$html_file"`
  printf "<li><a href=\"%s\" />%s</a></li>\n" "$html_file_escaped" "$title_html"
done

printf "</ul>\n</body>\n</html>"
