#!/bin/sh

# Pull in global dependencies.
. ./helpers.sh
metadata_dir=metadata
srcdir=`pwd`
title_file="$metadata_dir"/title
redo-ifchange "$title_file"
template_file="${metadata_dir}"/index.tmpl
redo-ifchange "$template_file"

# Build blog title.
title=$(read_and_escape_file "$title_file" | head -1 | prep_sed)

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
  if [ -e "$file" ]; then
    touch ./${tmp_snippets_dir}/list
    cat "$file" ./${tmp_snippets_dir}/list > ./${tmp_snippets_dir}/tmp
    mv ./${tmp_snippets_dir}/tmp ./${tmp_snippets_dir}/list
  fi
done
if [ -e "./${tmp_snippets_dir}/list" ]; then
  list=$(cat ./${tmp_snippets_dir}/list | prep_sed)
fi
rm -rf "${tmp_snippets_dir}"

# Put data into template.
template=$(cat "$template_file")
printf "%s" "$template" | \
sed 's/%TITLE%/'"$title"'/g' | \
sed 's/%LIST%/'"$list"'/g' | \
tr '\a' '%'
