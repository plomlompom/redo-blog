#!/bin/sh

# Pull in global dependencies.
. ./helpers.sh
metadata_dir=metadata
uuid_file="${metadata_dir}/${1%.html}.uuid"
redo-ifchange "$uuid_file"
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
datetime_created_unix=$(stat -c%y "${uuid_file}")
datetime_created_rfc3339=$(date -u "+%Y-%m-%dT%TZ" -d "${datetime_created_unix}")
datetime_created_friendly=$(date -u "+%Y-%m-%d %T (UTC)" -d "${datetime_created_unix}")

# Put data into template.
template=$(cat "$template_file")
printf "%s" "$template" | \
sed 's/%BLOG_TITLE%/'"$blog_title"'/g' | \
sed 's/%ARTICLE_TITLE_ESCAPED%/'"$title_plaintext"'/g' | \
sed 's/%ARTICLE_TITLE_HTML%/'"$title_html"'/g' | \
sed 's/%DATETIME_CREATED_RFC3339%/'"$datetime_created_rfc3339"'/g' | \
sed 's/%DATETIME_CREATED_FRIENDLY%/'"$datetime_created_friendly"'/g' | \
sed 's/%BODY%/'"$body"'/g' | \
tr '\a' '%'
