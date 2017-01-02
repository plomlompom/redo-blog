#!/bin/sh

if [ ! -f "$1" ]; then
cat << EOF
<!DOCTYPE html>
<html>
<head>
<title>%BLOG_TITLE% – %ARTICLE_TITLE_ESCAPED%</title>
</head>
<body>
<a href="index.html">%BLOG_TITLE%</a>
<article>
<h1>%ARTICLE_TITLE_HTML%</h1>
%BODY%
</article>
</body>
</html>
EOF
fi
