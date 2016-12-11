#!/bin/sh

# Pull in global dependencies.
. ./helpers.sh
author_file=author.meta
uuid_file=uuid.meta
title_file=title.meta
redo-ifchange "$url_file"
redo-ifchange "$author_file"
redo-ifchange "$uuid_file"
redo-ifchange "$title_file"

# Build some variables. XML-escape even file contents that should not contain
# dangerous characters, just to avoid any XML trouble.
srcdir=`pwd`
basepath=$(get_basepath)
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

# Generate feed entry snippets.
mkdir -p feed_snippets
for file in ./*.rst ./*.md; do
  if [ -e "$file" ]; then
    uuid_file="${file%.*}.uuid"
    redo-ifchange "$uuid_file"
    published=`stat -c%y "${uuid_file}"`
    published_unix=$(date -u "+%s%N" -d "${published}")
    snippet_file="${file%.*}.feed_snippet"
    redo-ifchange "$snippet_file"
    ln -s "$srcdir/$snippet_file" "./feed_snippets/${published_unix}"
  fi
done

# Derive feed modification date from snippets.
mod_dates=$(grep -hE "^<updated>" ./feed_snippets/* | sed -E 's/<.?updated>//g')
last_mod_unix=0
for date in $mod_dates; do
  date_unix=$(date -u "+%s" -d "${date}")
  if [ "$date_unix" -gt "$last_mod_unix" ]; then
    last_mod_unix=$date_unix
  fi
done
lastmod_rfc3339=`date -u "+%Y-%m-%dT%TZ" -d "@${last_mod_unix}"`
printf "<updated>%s</updated>\n\n" "$lastmod_rfc3339"

# Write feed entries.
for file in ./feed_snippets/*; do
  cat "${file}"
  printf "\n"
done
rm -rf feed_snippets

# Write feed foot.
printf "</feed>"
