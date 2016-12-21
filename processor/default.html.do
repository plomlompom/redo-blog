#!/bin/sh

# Pull in global dependencies.
. ./helpers.sh
metadata_dir=metadata
intermediate_file="${metadata_dir}/${1%.html}.intermediate"
title_file="${metadata_dir}"/title
redo-ifchange "$title_file" 
redo-ifchange "$intermediate_file"

# Build entry data.
blog_title=`read_and_escape_file "$title_file" | head -1`
title_html=`cat "$intermediate_file" | head -1`
title_plaintext=`echo "$title_html" | html2text`
title_plaintext_escaped=`escape_html "$title_plaintext"`
body=`cat "$intermediate_file" | sed 1d`

# Write first part of entry head.
cat << EOF
<!DOCTYPE html>
<html>
<head>
EOF

# Write remaining entry head and body. 
printf "<title>%s – %s</title>\n</head>\n<body>\n" "$blog_title" "$title_plaintext_escaped"
printf "<h1>%s</h1>\n" "$title_html"
printf "<section>\n%s\n</section>\n</body>\n</html>" "$body"
