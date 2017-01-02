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
<h1>%ARTICLE_TITLE_HTML%</h1>
<section>
%BODY%
</section>
</body>
</html>
EOF
fi
