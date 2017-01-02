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
<header>
<h1>%ARTICLE_TITLE_HTML%</h1>
<p><time datetime="%DATETIME_CREATED_RFC3339%">%DATETIME_CREATED_FRIENDLY%</time></p>
</header>
%BODY%
</article>
</body>
</html>
EOF
fi
