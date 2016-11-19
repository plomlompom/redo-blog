#!/bin/sh

rm -rf test/test_dir
./add_dir.sh test/test_dir
cp test/test_files/test.md test/test_dir/
cp test/test_files/foo.rst test/test_dir/
cp test/test_files/bar\ baz.md test/test_dir/
cd test/test_dir
redo
cd ../..
for file in test/test_files/*.html; do
  cmp_file=`echo "$file" | sed 's/test_files/test_dir/'`
  printf "== %s diff test ==\n" "$cmp_file"
  diff "$file" "$cmp_file"
  if [ "$?" = "0" ]; then
    echo "== test SUCCESS =="
  else
    echo "== test FAILURE =="
  fi
done
