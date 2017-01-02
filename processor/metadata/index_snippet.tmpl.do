#!/bin/sh

if [ ! -f "$1" ]; then
cat << EOF
<li><a href="%LINK%">%TITLE%</a> (<time>%DATE_CREATED%</time>)</li>
EOF
fi
