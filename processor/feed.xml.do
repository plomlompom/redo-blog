#!/bin/sh

# Pull in global dependencies.
. ./helpers.sh
metadata_dir=metadata
author_file="$metadata_dir"/author
meta_file="$metadata_dir"/automatic_metadata
title_file="$metadata_dir"/title
url_file="$metadata_dir"/url
redo-ifchange "$url_file"
redo-ifchange "$author_file"
redo-ifchange "$meta_file"
redo-ifchange "$title_file"

# Build some variables. XML-escape even file contents that should not contain
# dangerous characters, just to avoid any XML trouble.
srcdir=$(pwd)
tmp_snippets_dir=.tmp_feed_snippets
basepath=$(get_basepath "${metadata_dir}/")
title=$(read_and_escape_file "$title_file" | head -1)
author=$(read_and_escape_file "$author_file" | head -1)
uuid=$(get_uuid_from_meta_file "$meta_file")
feed_gen_date=$(get_creation_date_from_meta_file_seconds "$meta_file")

# Write majority of feed head.
cat << EOF
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
EOF
printf "<link href=\"%s\" rel=\"alternate\" type=\"text/html\" />\n" "$basepath"
printf "<link href=\"%sfeed.xml\" rel=\"self\" />\n" "$basepath"
printf "<title type=\"html\">%s</title>\n" "$title"
printf "<author><name>%s</name></author>\n" "$author"
printf "<id>urn:uuid:%s</id>\n" "$uuid"

# Generate feed entry snippets.
mkdir -p "$tmp_snippets_dir"
for file in ./*.rst ./*.md; do
  if [ -e "$file" ]; then
    meta_file="${metadata_dir}/${file%.*}.automatic_metadata"
    redo-ifchange "$meta_file"
    published=$(get_creation_date_from_meta_file_nanoseconds "$meta_file")
    snippet_file=./${metadata_dir}/"${file%.*}.feed_snippet"
    redo-ifchange "$snippet_file"
    ln -s "$srcdir/$snippet_file" "./${tmp_snippets_dir}/${published}"
  fi
done

# Derive feed modification date from snippets. Fallback to blog creation date.
n_snippet_files=`ls -1 ./${metadata_dir}/*.feed_snippet 2>/dev/null | wc -l`
if [ $n_snippet_files != 0 ]
then
  mod_dates=$(grep -hE "^<updated>" ./${metadata_dir}/*.feed_snippet | sed -E 's/<.?updated>//g')
fi
last_mod_unix=$feed_gen_date
for date in $mod_dates; do
  date_unix=$(date -u "+%s" -d "${date}")
  if [ "$date_unix" -gt "$last_mod_unix" ]; then
    last_mod_unix=$date_unix
  fi
done
last_mod_rfc3339=`date -u "+%Y-%m-%dT%TZ" -d "@${last_mod_unix}"`
printf "<updated>%s</updated>\n\n" "$last_mod_rfc3339"

# Write feed entries.
for file in ./${tmp_snippets_dir}/*; do
  if [ -e "$file" ]; then
    cat "${file}"
    printf "\n"
  fi
done
rm -rf "$tmp_snippets_dir"

# Write feed foot.
printf "</feed>"
