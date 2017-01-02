#!/bin/sh

escape_html() {
  out=`python3 -c 'import sys, html; print(html.escape(sys.argv[1]))' "$1"`
  printf "%s" "$out"
}

read_and_escape_file() {
  in=$(cat "$1")
  escape_html "$in"
}

get_uuid_from_meta_file() {
  probable_uuid=$(cat "$1" | head -1)
  if printf "$probable_uuid" | grep -Eq "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"; then
    printf "$probable_uuid"
  else
    echo "Malformed UUID in meta file." >&2
    exit 1
  fi
}

get_creation_date_from_meta_file_seconds() {
  cat "$1" | sed -n '2p' | cut -d'_' -f1
}

get_creation_date_from_meta_file_nanoseconds() {
  cat "$1" | sed -n '2p'
}

get_lastmod_date_from_meta_file() {
  cat "$1" | sed -n '4p'
}

escape_url() {
  out=`python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$1"`
  printf "%s" "$out"
}

get_basepath() {
  url_file="$1"url
  redo-ifchange "$url_file"
  base_url=`cat "$url_file" | head -1`
  url_protocol=`echo $base_url | cut -d ':' -f 1`
  url_basepath=`echo $base_url | cut -d '/' -f 3-`
  url_basepath_escaped=`escape_url "$url_basepath"`
  basepath="$url_protocol""://""$url_basepath_escaped"
  printf "%s" "$basepath"
}

get_source_file() {
  md_file="../${1%.*}.md"
  rst_file="../${1%.*}.rst"
  if [ -f "$rst_file" ]; then
    src_file="$rst_file"
  elif [ -f "$md_file" ]; then
    src_file="$md_file"
  else
    exit 1
  fi
  redo-ifchange "$src_file"
  printf "%s" "$src_file"
}

prep_sed () {
  # Escape characters that confuse sed in a replacement string. Also replace
  # occurences of % (which the templating uses as a variable marker) with
  # non-printable placeholder \a (clear input of it first), to be replaced by
  # % again when the templating has finished (so that no replacement string gets
  # interpreted by the templating).
  sedsafe_pattern='s/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g; $!s/$/\\/g; '
  sed "$sedsafe_pattern" | tr -d '\a' | tr '%' '\a'
}
