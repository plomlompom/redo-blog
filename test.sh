#!/bin/sh

uuid_pattern='[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'

blog_meta_file_test()
{
  meta_file="$1"
  printf "== %s meta file pattern match test ==\n" "$meta_file"
  if cat "$meta_file" | sed -n '1p' | grep -Eq '^'"$uuid_pattern"'$' \
      && cat "$meta_file" | sed -n '2p' | grep -Eq "^[0-9]+$"; then
    echo "== test SUCCESS =="
  else
    echo "== test FAILURE =="
  fi
}

article_meta_file_test()
{
  meta_file="$1"
  printf "== %s meta file pattern match test ==\n" "$meta_file"
  if cat "$meta_file" | sed -n '1p' | grep -Eq '^'"$uuid_pattern"'$' \
      && cat "$meta_file" | sed -n '2p' | grep -Eq "^[0-9]+_[0-9]+$" \
      && cat "$meta_file" | sed -n '3p' | grep -Eq "^[0-9a-f]{32}$" \
      && cat "$meta_file" | sed -n '2p' | grep -Eq "^[0-9]+_[0-9]+$"; then
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

# Set up test directory, run file creations.
expected_files_dir="test/test_files"
generated_files_dir="test/test_dir"
rm -rf "$generated_files_dir" 
./add_dir.sh "$generated_files_dir" 
working_dir=$(pwd)
cd "$generated_files_dir"
redo
cp "$working_dir/$expected_files_dir"/te\&quot\;st.md .
redo
cp "$working_dir/$expected_files_dir"/bar\ baz.md .
redo
cp "$working_dir/$expected_files_dir"/foo.rst .
cp "$working_dir/$expected_files_dir"/foo.links .
redo

# Test file modification tracking.
update_datetime_start=$(cat "metadata/bar baz.feed_snippet" | grep '<updated>')
sleep 1
sed -i '2d' bar\ baz.md
redo
update_datetime_after_invisible_change=$(cat "metadata/bar baz.feed_snippet" | grep '<updated>')
printf "== testing \"bar baz\"' update tag remaining unchanged with invisible source file change ==\n"
if [ "$update_datetime_start" = "$update_datetime_after_invisible_change" ]; then
    echo "== test SUCCESS =="
else
    echo "== test FAILURE =="
fi
sleep 1
sed -i '2d' bar\ baz.md
redo
update_datetime_after_visible_change=$(cat "metadata/bar baz.feed_snippet" | grep '<updated>')
printf "== testing \"bar baz\"' update tag changing with visible source file change ==\n"
if [ "$update_datetime_start" = "$update_datetime_after_visible_change" ]; then
    echo "== test FAILURE =="
else
    echo "== test SUCCESS =="
fi
cp "$working_dir/$expected_files_dir"/bar\ baz.md .
redo

# Compare metadata files.
cd "$working_dir"
blog_meta_file_test "$generated_files_dir""/metadata/automatic_metadata"
for file in "$expected_files_dir"/metadata/*; do
  basename=$(basename "$file")
  cmp_file="$generated_files_dir/metadata/$basename"
  diff_test "$file" "$cmp_file"
done

# Compare .links files.
cd "$working_dir"
for file in "$expected_files_dir"/*.links "$expected_files_dir"/*.captcha; do
  basename=$(basename "$file")
  cmp_file="$generated_files_dir/$basename"
  diff_test "$file" "$cmp_file"
done

# Compare generated HTML files. Ignore variable dates.
for file in "$expected_files_dir"/*.html.ignoring; do
  basename=$(basename "$file")
  cmp_file="$generated_files_dir/${basename%.ignoring}"
  if [ ! "$file" = "$expected_files_dir""/index.html.ignoring" ]; then
    article_meta_file_test "${generated_files_dir}/metadata/${basename%.html.ignoring}.automatic_metadata"
  fi
  generated_file="$cmp_file".ignoring
  cat "$cmp_file" | \
    sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/IGNORE/g' \
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
