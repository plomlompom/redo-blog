redo-blog
=========

small blog system using the redo build system, with blog article files written
in (pandoc) Markdown or ReStructured Text.

dependencies
------------

- redo
- python3
- uuidgen (Debian package: uuid-runtime)
- html2text
- pandoc

testing
-------

Run ./test.sh.

setup
-----

To set up a directory with symbolic links to the relevant files in ./processor/,
run ./add_dir.sh DIRECTORY.

You can then enter the directory and run redo there. This will generate article
.html files from all .md and .rst files, plus a ./index.html, and a ./feed.xml.
These files will be linked to symbolically in a directory ./public/.

Some metadata files will also be generated below ./metadata/: For each article,
there will be generated a .automatic_metadata (to contain an article's UUID,
checksum, and creation/modification dates) and a .intermediate file (to contain
pandoc-formatted article content like title and body); furthermore, files for
data used in ./feed.xml and ./index.html will, if non-existant, be built there
and can be edited to customize the blog – namely the files url, author, title,
index.tmpl, index_snippet.tmpl, article.tmpl. A blog-specific UUID and creation
date is stored in ./metadata/automatic_metadata

recipe to remotely manage a redo blog with git
----------------------------------------------

On your server, install the dependencies listed above. Then set up a repository
for your blog files. Let's assume we want it to sit in our home directory and be
called `blog`:

    cd ~
    mkdir blog
    git init --bare blog.git
    cat << EOF > blog.git/hooks/post-update
    #!/bin/sh
    blog_dir=~/blog
    export GIT_DIR=\$(pwd)
    export GIT_WORK_TREE="\$blog_dir"
    git checkout -f
    cd "\$GIT_WORK_TREE"
    redo
    git add metadata/author metadata/url metadata/title metadata/*.tmpl metadata/automatic_metadata
    count=\$(ls -1 metadata/*.automatic_metadata 2>/dev/null | wc -l)
    if [ "\$count" != 0 ]; then
      git add metadata/*.automatic_metadata
    fi
    status=\$(git status -s)
    n_updates=\$(printf "$status" | grep -vE '^\?\?' | wc -l)
    if [ "\$n_updates" -gt 0 ]; then
      git commit -a -m 'Update metadata'
    fi
    EOF
    chmod a+x blog.git/hooks/post-update

Enable management of `~/blog` via redo-blog:

    git clone https://github.com/plomlompom/redo-blog/
    cd redo-blog/
    ./add_dir.sh ~/blog
    mkdir ~/blog/public

Link to the `public` subdirectory from wherever your web server expects your
public web content to sit:

    ln -s ~/blog/public /var/www/html/blog

Client-side, do this (you obviously need to customize this code; at least
replace the username `user` and the server name `example.org`):

    cd ~
    git init blog
    cd blog
    git remote add origin ssh://user@example.org:/home/user/blog.git
    mkdir metadata
    echo 'https://example.org/blog/' > metadata/url
    git add metadata/url
    git commit -m 'set up blog metadata'
    git push origin master

If successful, the git hook will furthermore commit some ~/blog/metadata/ files
generated by redo, that can be pulled into the client-side local repository:

    git pull origin master

bugs and peculiarities
----------------------

Don't create a index.rst or index.md in the redo-managed directory, that will
break things.

The article title is derived in .md files from a first line prefixed with `%`,
while all other headings are treated as sub-headings. In .rst files, the title
is derived from a heading that must be at the top of the document, and be of an
adornment style (such as underlining with `=`) that must be used only once in
it.
