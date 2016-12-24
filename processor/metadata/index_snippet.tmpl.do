#!/bin/sh

if [ ! -f "$1" ]; then
cat << EOF
<li><a href="%LINK%">%TITLE%</a></li>
EOF
fi
