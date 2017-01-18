#!/bin/sh

if [ ! -f "$1" ]; then
cat << EOF
<!DOCTYPE html>
<meta charset="UTF-8">
<style type="text/css">
h1 { font-size: 2em; }
h2 { font-size: 1.5em; }
h3 { font-size: 1.17em; }
h4 { font-size: 1.12em; }
h5 { font-size: .83em; }
h6 { font-size: .75em; }
header h1 { margin-bottom: 0.1em; }
header p { margin: 0; }
</style>
<title>%BLOG_TITLE% – %ARTICLE_TITLE_ESCAPED%</title>
<a href="index.html">%BLOG_TITLE%</a>
<article>
<header>
<h1>%ARTICLE_TITLE_HTML%</h1>
<p>created: <time>%DATE_CREATED%</time> / last update: <time>%DATE_UPDATED%</time></p>
</header>
%BODY%
<footer>
Links back:
<ul>%LINKBACKS%
</ul>
</footer>
</article>
EOF
fi
