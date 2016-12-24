#!/bin/sh

# Pull in dependencies.
. ../helpers.sh
src_file=$(get_source_file "$1")
intermediate_file="${1%.index_snippet}.intermediate"
redo-ifchange "$intermediate_file"
html_file="${src_file%.*}.html"
redo-ifchange "$html_file"
template_file=index_snippet.tmpl
redo-ifchange "$template_file"

# Build entry data.
title=$(cat "$intermediate_file" | head -1 | prep_sed)
link=$(escape_url "${1%.index_snippet}.html" | prep_sed)

# Put data into template.
template=$(cat "$template_file")
printf "%s\n" "$template" | \
sed 's/%TITLE%/'"$title"'/g' | \
sed 's/%LINK%/'"$link"'/g' | \
tr '\a' '%'
