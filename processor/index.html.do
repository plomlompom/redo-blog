#!/bin/sh

# Pull in global dependencies.
. ./helpers.sh
metadata_dir=metadata
srcdir=`pwd`
title_file="$metadata_dir"/title
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
tmp_snippets_dir=.tmp_index_snippets
mkdir -p "$tmp_snippets_dir"
for file in ./*.rst ./*.md; do
  if [ -e "$file" ]; then
    uuid_file="${metadata_dir}/${file%.*}.uuid"
    redo-ifchange "$uuid_file"
    published=`stat -c%y "${uuid_file}"`
    published_unix=$(date -u "+%s%N" -d "${published}")
    snippet_file="${metadata_dir}/${file%.*}.index_snippet"
    redo-ifchange "$snippet_file"
    ln -s "$srcdir/$snippet_file" "./${tmp_snippets_dir}/${published_unix}"
  fi
done

# Write link list.
for file in ./${tmp_snippets_dir}/*; do
  touch ./${tmp_snippets_dir}/list
  cat "$file" ./${tmp_snippets_dir}/list > ./${tmp_snippets_dir}/tmp
  mv ./${tmp_snippets_dir}/tmp ./${tmp_snippets_dir}/list
done
if [ -e "./${tmp_snippets_dir}/list" ]; then
  cat ./${tmp_snippets_dir}/list
fi
rm -rf "${tmp_snippets_dir}"

# Write index footer.
printf "</ul>\n</body>\n</html>"
