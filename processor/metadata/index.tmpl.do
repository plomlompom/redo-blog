#!/bin/sh

if [ ! -f "$1" ]; then
cat << EOF
<!DOCTYPE html>
<html>
<head>
<title>%TITLE%</title>
</head>
<body>
<h1>%TITLE%</h1>
<ul>
%LIST%
</ul>
</body>
</html>
EOF
fi
