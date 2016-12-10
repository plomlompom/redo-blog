#!/bin/sh

# Pull in global dependencies.
. ./helpers.sh
title_file=title.meta
redo-ifchange "$title_file"

# Write index head.
cat << EOF
<!DOCTYPE html>
<html>
<head>
EOF
blog_title=`read_and_escape_file "$title_file" | head -1`
printf "<title>%s</title>\n</head>\n<body>\n" "$blog_title"
printf "<h1>%s</h1>\n<ul>\n" "$blog_title"

# Generate link list entries.
mkdir -p index_snippets
for file in ./*.rst ./*.md; do
  if [ -e "$file" ]; then
    uuid_file="${file%.*}.uuid"
    redo-ifchange "$uuid_file"
    published=`stat -c%y "${uuid_file}"`
    published_unix=$(date -u "+%s%N" -d "${published}")
    intermediate_file="${file%.*}.intermediate"
    html_file="${file%.*}.html"
    redo-ifchange "$intermediate_file"
    redo-ifchange "$html_file"
    title_html=`cat "$intermediate_file" | head -1`
    html_file_escaped=`escape_url "${html_file#\./}"`
    printf "<li><a href=\"%s\" />%s</a></li>\n" "$html_file_escaped" "$title_html" > ./index_snippets/${published_unix}
  fi
done

# Write link list.
for file in ./index_snippets/*; do
  touch ./index_snippets/list
  cat "$file" ./index_snippets/list > ./index_snippets/tmp
  mv ./index_snippets/tmp ./index_snippets/list
done
if [ -e "./index_snippets/list" ]; then
  cat ./index_snippets/list
fi
rm -rf index_snippets

# Write index footer.
printf "</ul>\n</body>\n</html>"
