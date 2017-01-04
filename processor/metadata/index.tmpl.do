#!/bin/sh

if [ ! -f "$1" ]; then
cat << EOF
<!DOCTYPE html>
<meta charset="UTF-8">
<style type="text/css">
h1 { font-size: 2em; }
</style>
<link rel="alternate" type="application/rss+xml" title="atom feed" href="feed.xml" />
<title>%BLOG_TITLE%</title>
<h1>%BLOG_TITLE%</h1>
<p><a href="feed.xml">feed</a></p>
<ul>
%INDEX%
</ul>
EOF
fi
