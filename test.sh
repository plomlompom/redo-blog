#!/bin/sh

rm -rf test/test_dir
./add_dir.sh test/test_dir
cp test/test_files/test.md test/test_dir/
cp test/test_files/foo.rst test/test_dir/
cp test/test_files/bar\ baz.md test/test_dir/
cd test/test_dir
redo
cd ../..
echo "== index.html diff test =="
diff test/test_files/index.html test/test_dir/index.html
if [ "$?" = "0" ]; then
  echo "== test SUCCESS =="
else
  echo "== test FAILURE =="
fi
