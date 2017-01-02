#!/bin/sh

# Pull in dependencies.
. ../helpers.sh
src_file=$(get_source_file "$1")
meta_file="${1%.index_snippet}.automatic_metadata"
redo-ifchange "$meta_file"
intermediate_file="${1%.index_snippet}.intermediate"
redo-ifchange "$intermediate_file"
html_file="${src_file%.*}.html"
redo-ifchange "$html_file"
template_file=index_snippet.tmpl
redo-ifchange "$template_file"

# Build entry data.
title=$(cat "$intermediate_file" | head -1 | prep_sed)
link=$(escape_url "${1%.index_snippet}.html" | prep_sed)
datetime_created_unix=$(get_creation_date_from_meta_file_seconds "$meta_file")
date_created_human=$(date -u "+%Y-%m-%d" -d "@${datetime_created_unix}")

# Put data into template.
template=$(cat "$template_file")
printf "%s\n" "$template" | \
sed 's/%TITLE%/'"$title"'/g' | \
sed 's/%LINK%/'"$link"'/g' | \
sed 's/%DATE_CREATED%/'"$date_created_human"'/g' | \
tr '\a' '%'
