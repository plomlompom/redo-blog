#!/bin/sh

escape_html() {
  out=`python3 -c 'import sys, html; print(html.escape(sys.argv[1]))' "$1"`
  printf "%s" "$out"
}

read_and_escape_file() {
  in=`cat "$1"`
  escape_html "$in"
}

escape_url() {
  out=`python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$1"`
  printf "%s" "$out"
}

get_basepath() {
  url_file=url.meta
  redo-ifchange "$url_file"
  base_url=`cat "$url_file" | head -1`
  url_protocol=`echo $base_url | cut -d ':' -f 1`
  url_basepath=`echo $base_url | cut -d '/' -f 3-`
  url_basepath_escaped=`escape_url "$url_basepath"`
  basepath="$url_protocol""://""$url_basepath_escaped"
  echo "$basepath"
}

get_source_file() {
  md_file="${1%.*}.md"
  rst_file="${1%.*}.rst"
  if [ -f "$rst_file" ]; then
    src_file="$rst_file"
  elif [ -f "$md_file" ]; then
    src_file="$md_file"
  else
    exit 1
  fi
  redo-ifchange "$src_file"
  printf "$src_file"
}
