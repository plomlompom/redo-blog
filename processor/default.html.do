#!/bin/sh

# Pull in global dependencies.
. ./helpers.sh
metadata_dir=metadata
meta_file="${metadata_dir}/${1%.html}.automatic_metadata"
redo-ifchange "$meta_file"
intermediate_file="${metadata_dir}/${1%.html}.intermediate"
redo-ifchange "$intermediate_file"
title_file="${metadata_dir}"/title
redo-ifchange "$title_file" 
template_file="${metadata_dir}"/article.tmpl
redo-ifchange "$template_file"

# Build entry data.
blog_title=$(read_and_escape_file "$title_file" | head -1 | prep_sed)
title_html=$(cat "$intermediate_file" | head -1)
title_plaintext=`echo "$title_html" | html2text`
title_html=$(printf "%s" "$title_html" | prep_sed)
title_plaintext=$(escape_html "$title_plaintext" | prep_sed)
body=$(cat "$intermediate_file" | sed 1d | prep_sed)
datetime_created_unix=$(get_creation_date_from_meta_file_seconds "$meta_file")
datetime_created_friendly=$(date -u "+%Y-%m-%d" -d "@${datetime_created_unix}")

# Put data into template.
template=$(cat "$template_file")
printf "%s" "$template" | \
sed 's/%BLOG_TITLE%/'"$blog_title"'/g' | \
sed 's/%ARTICLE_TITLE_ESCAPED%/'"$title_plaintext"'/g' | \
sed 's/%ARTICLE_TITLE_HTML%/'"$title_html"'/g' | \
sed 's/%DATE_CREATED%/'"$datetime_created_friendly"'/g' | \
sed 's/%BODY%/'"$body"'/g' | \
tr '\a' '%'
