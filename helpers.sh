#!/bin/sh

escape_html()
{
out=`python3 -c 'import sys, html; print(html.escape(sys.argv[1]))' "$1"`
printf "%s" "$out"
}

read_and_escape_file()
{
in=`cat "$1"`
escape_html "$in"
}

escape_url()
{
out=`python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$1"`
printf "%s" "$out"
}
