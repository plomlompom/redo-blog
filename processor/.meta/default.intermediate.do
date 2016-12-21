#!/bin/sh

template=intermediate.tmpl
uuidfile="${1%.intermediate}.uuid"
redo-ifchange "$uuidfile"
redo-ifchange "$template"
mdfile="../${1%.intermediate}.md"
rstfile="../${1%.intermediate}.rst"
if [ -f "$rstfile" ]; then
  redo-ifchange "$rstfile"
  pandoc -f rst --template="$template" --mathml -t html5 "$rstfile" > "$3"
elif [ -f "$mdfile" ]; then
  redo-ifchange "$mdfile"
  pandoc -f markdown --template="$template" --mathml -t html5 "$mdfile" > "$3"
fi
