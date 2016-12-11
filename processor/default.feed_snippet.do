#!/bin/sh

# Pull in dependencies. 
. ./helpers.sh
src_file=$(get_source_file "$1")
uuid_file="${1%.feed_snippet}.uuid"
redo-ifchange "$uuid_file"
intermediate_file="${src_file%.*}.intermediate"
redo-ifchange "$intermediate_file"

# Get variables, write entry.
html_file=`escape_url "${src_file%.*}.html"`
lastmod=`stat -c%y "$src_file"`
lastmod_rfc3339=`date -u "+%Y-%m-%dT%TZ" -d "$lastmod"`
published=`stat -c%y "$uuid_file"`
published_rfc3339=`date -u "+%Y-%m-%dT%TZ" -d "${published}"`
title=`read_and_escape_file "$intermediate_file" | head -1`
uuid=`read_and_escape_file "$uuid_file" | head -1`
body=`read_and_escape_file "$intermediate_file" | sed 1d`
printf "<entry>\n"
printf "<title type=\"html\">%s</title>\n" "$title"
printf "<id>urn:uuid:%s</id>\n" "$uuid"
printf "<updated>%s</updated>\n" "$lastmod_rfc3339"
printf "<published>%s</published>\n" "$published_rfc3339"
printf "<link href=\"%s%s\" />\n" "$(get_basepath)" "${html_file#\./}"
printf "<content type=\"html\">\n%s\n</content>\n" "$body"
printf "</entry>\n"
