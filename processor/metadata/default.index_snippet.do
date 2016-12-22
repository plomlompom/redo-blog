#!/bin/sh

# Pull in dependencies.
. ../helpers.sh
src_file=$(get_source_file "$1")
intermediate_file="${1%.index_snippet}.intermediate"
redo-ifchange "$intermediate_file"
html_file="${src_file%.*}.html"
redo-ifchange "$html_file"

# Get variables, write entry.
title_html=$(cat "$intermediate_file" | head -1)
html_file_escaped=$(escape_url "${1%.index_snippet}.html")
printf "<li><a href=\"%s\" />%s</a></li>\n" "$html_file_escaped" "$title_html"
