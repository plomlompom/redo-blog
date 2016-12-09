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

diff_test()
{
  expected_file="$1"
  generated_file="$2"
  printf "== %s diff test ==\n" "$generated_file"
  diff "$expected_file" "$generated_file"
  if [ "$?" = "0" ]; then
    echo "== test SUCCESS =="
  else
    echo "== test FAILURE =="
  fi
}

# Set up test directory. 
expected_files_dir="test/test_files"
expected_files_dir_escaped="test\\/test_files"
generated_files_dir="test/test_dir"
generated_files_dir_escaped="test\\/test_dir"
rm -rf "$generated_files_dir" 
./add_dir.sh "$generated_files_dir" 
working_dir=$(pwd)
cp "$expected_files_dir"/test.md "$generated_files_dir"/
cp "$expected_files_dir"/foo.rst "$generated_files_dir"/
cp "$expected_files_dir"/bar\ baz.md "$generated_files_dir"/
cd "$generated_files_dir"
redo
cd "$working_dir" 

# Simple file comparison tests and UUID tests.
uuid_test "$generated_files_dir""/uuid.meta"
for file in "$expected_files_dir"/*.html "$expected_files_dir"/*.meta; do
  sed_expression='s/'"$expected_files_dir_escaped"'/'"$generated_files_dir_escaped"'/'
  cmp_file=`echo "$file" | sed "$sed_expression"`
  if [ ! "$file" = "$expected_files_dir""/index.html" ] && \
      echo "$file" | grep -q "\.html$"; then
    uuid_test "${cmp_file%.html}.uuid"
  fi
  diff_test "$file" "$cmp_file"
done

# To compare feed.xml, ignore all variable date and uuid strings.
original_file="$generated_files_dir""/feed.xml"
generated_file="$original_file".ignoring
expected_file="$expected_files_dir""/feed.xml.ignoring"
cat "$original_file" | \
  sed 's/>[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}Z</>IGNORE</' | \
  sed 's/>urn:uuid:[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}</>urn:uuid:IGNORE</' \
  > "$generated_file"
diff_test "$expected_file" "$generated_file"
rm "$generated_file"
