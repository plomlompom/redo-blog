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
generated_files_dir="test/test_dir"
rm -rf "$generated_files_dir" 
./add_dir.sh "$generated_files_dir" 
working_dir=$(pwd)
cd "$generated_files_dir"
redo
cp "$working_dir/$expected_files_dir"/test.md .
redo
cp "$working_dir/$expected_files_dir"/bar\ baz.md .
redo
cp "$working_dir/$expected_files_dir"/foo.rst .
redo
cd "$working_dir"

# Compare metadata files.
uuid_test "$generated_files_dir""/metadata/uuid"
for file in "$expected_files_dir"/metadata/*; do
  basename=$(basename "$file")
  cmp_file="$generated_files_dir/metadata/$basename"
  diff_test "$file" "$cmp_file"
done

# Compare generated HTML files. Ignore variable dates.
for file in "$expected_files_dir"/*.html.ignoring; do
  basename=$(basename "$file")
  cmp_file="$generated_files_dir/${basename%.ignoring}"
  if [ ! "$file" = "$expected_files_dir""/index.html.ignoring" ]; then
    uuid_test "${generated_files_dir}/metadata/${basename%.html.ignoring}.uuid"
  fi
  generated_file="$cmp_file".ignoring
  cat "$cmp_file" | \
    sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/IGNORE/g' | \
    sed 's/IGNORET[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}Z/IGNORE/g' | \
    sed 's/IGNORE [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} (UTC)/IGNORE/g' \
    > "$generated_file"
  diff_test "$file" "$generated_file"
done

# Compare feed files. Ignore variable dates and UUIDs.
original_file="$generated_files_dir""/feed.xml"
generated_file="$original_file".ignoring
expected_file="$expected_files_dir""/feed.xml.ignoring"
cat "$original_file" | \
  sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}Z/IGNORE/g' | \
  sed 's/urn:uuid:[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}/urn:uuid:IGNORE/g' \
  > "$generated_file"
diff_test "$expected_file" "$generated_file"
rm "$generated_file"

# Check symbolic links.
for file in "$generated_files_dir"/feed.xml "$generated_files_dir"/*.html; do
  basename=$(basename "$file")
  linkname=$(readlink "$generated_files_dir/public/$basename")
  printf "== public/%s symbolic link test ==\n" "$basename"
  if [ "$working_dir/$generated_files_dir/$basename" = "$linkname" ]; then
    echo "== test SUCCESS =="
  else
    echo "== test FAILURE =="
  fi
done
