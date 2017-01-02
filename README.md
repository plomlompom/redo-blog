redo-blog
=========

small blog system using the redo build system

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
there will be generated a .uuid and a .intermediate file; furthermore, files for
data used in ./feed.xml and ./index.html will be built there and can be edited
to customize the blog – namely the files url, author, uuid, title, index.tmpl,
index_snippet.tmpl, article.tmpl.

recipe to use server-side with git
----------------------------------

On your server, install the dependencies listed above. Then set up a repository
for your blog files. Let's assume we want it to sit in our home directory and be
called `blog`:

    cd ~
    mkdir blog
    git init --bare blog.git
    cat << EOF > blog.git/hooks/post-update
    #!/bin/sh
    BLOGDIR=~/blog
    GIT_WORK_TREE=\$BLOGDIR git checkout -f
    cd \$BLOGDIR
    redo
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

Client-side, do this (obviously, replace server and username):

    cd ~
    git init blog
    cd blog
    git remote add origin ssh://user@example.org:/home/user/blog.git
    mkdir metadata
    echo 'https://example.org/blog/' > metadata/url
    git add metadata/url
    git commit -m 'set up blog metadata'
    git push origin master

bugs
----

Don't create a index.rst or index.md in the redo-managed directory, that will
break things.
