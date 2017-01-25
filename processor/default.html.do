#!/bin/sh

# Handle URL from .links file.
prep_url() {
  url=$(printf "%s" "$(escape_html "$1")" | prep_sed)
  template=$(cat "$linkback_tmpl_file")
  printf "%s" "$template" | sed 's/%URL%/'"$url"'/g' | tr '\a' '%' | prep_sed
}

# Pull in global dependencies.
. ./helpers.sh
metadata_dir=metadata
captchas_dir=captchas
meta_file="${metadata_dir}/${1%.html}.automatic_metadata"
redo-ifchange "$meta_file"
intermediate_file="${metadata_dir}/${1%.html}.intermediate"
redo-ifchange "$intermediate_file"
title_file="${metadata_dir}"/title
redo-ifchange "$title_file" 
article_tmpl_file="${metadata_dir}"/article.tmpl
redo-ifchange "$article_tmpl_file"
linkback_tmpl_file="${metadata_dir}"/linkback.tmpl
redo-ifchange "$linkback_tmpl_file"
replies_file="${1%.html}.links"
redo-ifchange "$replies_file"
captcha_file="$captchas_dir/${1%.html}"
redo-ifchange "$captcha_file"

# Build entry data.
blog_title=$(read_and_escape_file "$title_file" | head -1 | prep_sed)
title_html=$(cat "$intermediate_file" | head -1)
title_plaintext=`echo "$title_html" | html2text`
title_html=$(printf "%s" "$title_html" | prep_sed)
title_plaintext=$(escape_html "$title_plaintext" | prep_sed)
body=$(cat "$intermediate_file" | sed 1d | prep_sed)
datetime_created_unix=$(get_creation_date_from_meta_file_seconds "$meta_file")
date_created=$(date -u "+%Y-%m-%d" -d "@${datetime_created_unix}")
datetime_lastmod_unix=$(get_lastmod_date_from_meta_file "$meta_file")
date_updated=$(date -u "+%Y-%m-%d" -d "@${datetime_lastmod_unix}")
replies=$(while read line; do prep_url "$line"; done < "$replies_file")

# Put data into template.
template=$(cat "$article_tmpl_file")
printf "%s" "$template" | \
sed 's/%BLOG_TITLE%/'"$blog_title"'/g' | \
sed 's/%ARTICLE_TITLE_ESCAPED%/'"$title_plaintext"'/g' | \
sed 's/%ARTICLE_TITLE_HTML%/'"$title_html"'/g' | \
sed 's/%DATE_CREATED%/'"$date_created"'/g' | \
sed 's/%DATE_UPDATED%/'"$date_updated"'/g' | \
sed 's/%BODY%/'"$body"'/g' | \
sed 's/%LINKBACKS%/'"$replies"'/g' | \
tr '\a' '%'
