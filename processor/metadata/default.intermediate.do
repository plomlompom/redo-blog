#!/bin/sh

# Pull in dependencies.
template=intermediate.pandoc_tmpl
meta_file="${1%.intermediate}.automatic_metadata"
redo-ifchange "$meta_file"
redo-ifchange "$template"
mdfile="../${1%.intermediate}.md"
rstfile="../${1%.intermediate}.rst"

# Build intermediate file.
if [ -f "$rstfile" ]; then
  redo-ifchange "$rstfile"
  pandoc -f rst --template="$template" --mathml -t html5 "$rstfile" --base-header-level=2 --email-obfuscation=references > "$3"
elif [ -f "$mdfile" ]; then
  redo-ifchange "$mdfile"
  pandoc -f markdown --template="$template" --mathml -t html5 "$mdfile" --base-header-level=2 --email-obfuscation=references > "$3"
fi

# Update meta file if appropriate.
md5_new=$(md5sum "$3" | cut -d ' ' -f 1)
md5_old=$(cat "$meta_file" | sed -n '3p')
if [ ! "$md5_new" = "$md5_old" ]; then
  new_date=$(date -u "+%s")
  sed -i '1,2!d' "$meta_file"
  echo "$md5_new" >> "$meta_file"
  echo "$new_date" >> "$meta_file"
fi
