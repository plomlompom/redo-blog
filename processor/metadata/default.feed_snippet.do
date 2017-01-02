#!/bin/sh

# Pull in dependencies. 
. ../helpers.sh
src_file=$(get_source_file "$1")
meta_file="${1%.feed_snippet}.automatic_metadata"
redo-ifchange "$meta_file"
intermediate_file="${1%.feed_snippet}.intermediate"
redo-ifchange "$intermediate_file"

# Get variables, write entry.
html_file=$(escape_url "${1%.feed_snippet}.html")
lastmod=$(get_lastmod_date_from_meta_file "$meta_file")
lastmod_rfc3339=$(date -u "+%Y-%m-%dT%TZ" -d "@$lastmod")
title=$(read_and_escape_file "$intermediate_file" | head -1)
uuid=$(get_uuid_from_meta_file "$meta_file")
published_unix=$(get_creation_date_from_meta_file_seconds "$meta_file")
published_rfc3339=$(date -u "+%Y-%m-%dT%TZ" -d "@${published_unix}")
body=$(read_and_escape_file "$intermediate_file" | sed 1d)
printf "<entry>\n"
printf "<title type=\"html\">%s</title>\n" "$title"
printf "<id>urn:uuid:%s</id>\n" "$uuid"
printf "<updated>%s</updated>\n" "$lastmod_rfc3339"
printf "<published>%s</published>\n" "$published_rfc3339"
printf "<link href=\"%s%s\" />\n" "$(get_basepath)" "${html_file}"
printf "<content type=\"html\">\n%s\n</content>\n" "$body"
printf "</entry>\n"
