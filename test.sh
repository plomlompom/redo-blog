#!/bin/sh

uuid_test()
{
uuid_file="$1"
printf "== %s UUID pattern match test ==\n" "$uuid_file"
if cat "$uuid_file" | grep -Eq "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"; then
  echo "== test SUCCESS =="
else
  echo "== test FAILURE =="
fi
}

rm -rf test/test_dir
./add_dir.sh test/test_dir
cp test/test_files/test.md test/test_dir/
cp test/test_files/foo.rst test/test_dir/
cp test/test_files/bar\ baz.md test/test_dir/
cd test/test_dir
redo
cd ../..
uuid_regex="^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
for file in test/test_files/*.html test/test_files/*.meta; do
  cmp_file=`echo "$file" | sed 's/test_files/test_dir/'`
  if [ ! "$file" = "test/test_files/index.html" ] && \
      echo "$file" | grep -q "\.html$"; then
    uuid_test "${cmp_file%.html}.uuid"
  fi
  printf "== %s diff test ==\n" "$cmp_file"
  diff "$file" "$cmp_file"
  if [ "$?" = "0" ]; then
    echo "== test SUCCESS =="
  else
    echo "== test FAILURE =="
  fi
done
uuid_test "test/test_dir/uuid.meta"
