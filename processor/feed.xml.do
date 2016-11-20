#!/bin/sh

# Pull in global dependencies.
. ./helpers.sh
url_file=url.meta
author_file=author.meta
uuid_file=uuid.meta
title_file=title.meta
redo-ifchange "$url_file"
redo-ifchange "$author_file"
redo-ifchange "$uuid_file"
redo-ifchange "$title_file"

# Build some variables. XML-escape even file contents that should not contain
# dangerous characters, just to avoid any XML trouble.
base_url=`cat "$url_file" | head -1`
url_protocol=`echo $base_url | cut -d ':' -f 1`
url_basepath=`echo $base_url | cut -d '/' -f 3-`
url_basepath_escaped=`escape_url "$url_basepath"`
basepath="$url_protocol""://""$url_basepath_escaped"
title=`read_and_escape_file "$title_file" | head -1`
author=`read_and_escape_file "$author_file" | head -1`
uuid=`read_and_escape_file "$uuid_file" | head -1`

# Write majority of feed head.
cat << EOF
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
EOF
printf "<link href=\"%s\" />\n" "$basepath"
printf "<link href=\"%sfeed.xml\" rel=\"self\" />\n" "$basepath"
printf "<title type=\"html\">%s</title>\n" "$title"
printf "<author><name>%s</name></author>\n" "$author"
printf "<id>urn:uuid:%s</id>\n" "$uuid"

# Iterate through most recent entries (go by lastmod date of source files) to
# build feed head "updated" element, and individual entries.
# FIXME: This ls parsing is a bad way to loop through the sorted files. Besides,
# $('\0') is a bashism.
first_run=0
files=`ls -1t *.rst *.md | head -10 | tr '\n' $'\0'`
oldIFS="$IFS"
IFS=$'\0'
for file in $files; do
  lastmod=`stat -c%y "$file"`
  lastmod_rfc3339=`date -u "+%Y-%m-%dT%TZ" -d "$lastmod"`
  if [ "$first_run" -lt "1" ]; then
    IFS="$oldIFS"
    printf "<updated>%s</updated>\n\n" "$lastmod_rfc3339" 
    first_run=1
  fi

  # Build some variables and dependencies.
  intermediate_file="${file%.*}.intermediate"
  htmlfile=`escape_url "${file%.*}.html"`
  uuid_file="${file%.*}.uuid"
  redo-ifchange "$intermediate_file"
  redo-ifchange "$uuid_file"
  title=`read_and_escape_file "$intermediate_file" | head -1`
  uuid=`read_and_escape_file "$uuid_file" | head -1`
  body=`read_and_escape_file "$intermediate_file" | sed 1d`
  published=`stat -c%y "$uuid_file"`
  published_rfc3339=`date -u "+%Y-%m-%dT%TZ" -d "$published"`

  # Write entry.
  printf "<entry>\n"
  printf "<title type=\"html\">%s</title>\n" "$title"
  printf "<id>urn:uuid:%s</id>\n" "$uuid" 
  printf "<updated>%s</updated>\n" "$lastmod_rfc3339" 
  printf "<published>%s</published>\n" "$published_rfc3339" 
  printf "<link href=\"%s%s\" />\n" "$basepath" "$htmlfile"
  printf "<content type=\"html\">\n%s\n</content>\n" "$body"
  printf "</entry>\n\n"
done

printf "</feed>"
