redo-blog
=========

small blog system using the redo build system

dependencies
------------

- python3
- uuidgen
- html2text

testing
-------

Run ./test.sh.

setup
-----

To set up a directory with symbolic links to the relevant .do files and other
important files, run ./add_dir.sh DIRECTORY.

You can then enter the directory and run redo there. This will generate article
.html files from all .md and .rst files, plus a ./index.html, and a ./feed.xml.
(Some other metadata files will also be generated: for each article, there will
also be generated a .uuid and a .intermediate file; furthermore, files with
metadata used in ./feed.xml and ./index.html will be built and can be edited to
customize the blog: ./url, ./author, ./uuid, ./title.) 
