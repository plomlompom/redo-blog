#!/bin/sh

if [ ! -f "$1" ]; then
cat << EOF
<!DOCTYPE html>
<html>
<head>
<title>%BLOG_TITLE% – %ARTICLE_TITLE_ESCAPED%</title>
</head>
<body>
<h1>%ARTICLE_TITLE_HTML%</h1>
<section>
%BODY%
</section>
</body>
</html>
EOF
fi
