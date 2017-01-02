#!/bin/sh

if [ ! -f "$1" ]; then
cat << EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style type="text/css">
h1 { font-size: 2em; }
</style>
<link rel="alternate" type="application/rss+xml" title="atom feed" href="feed.xml" />
<title>%TITLE%</title>
</head>
<body>
<h1>%TITLE%</h1>
<p><a href="feed.xml">feed</a></p>
<ul>
%LIST%
</ul>
</body>
</html>
EOF
fi
