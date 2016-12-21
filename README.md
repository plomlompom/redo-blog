redo-blog
=========

small blog system using the redo build system

dependencies
------------

- redo
- python3
- uuidgen
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
These files will be linked to symbolically in a directory ./public/. (Some
metadata files will also be generated below ./metadata/: for each article, there
will be generated a .uuid and a .intermediate file; furthermore, files for data
used in ./feed.xml and ./index.html will be built and can be edited to customize
the blog: ./metadata/url, ./metadata/author, ./metadata/uuid, ./metadata/title.) 

bugs
----

Don't create a index.rst or index.md in the redo-managed directory, that will
break things.
