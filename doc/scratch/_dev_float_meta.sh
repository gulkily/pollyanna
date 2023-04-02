#!/bin/sh

#note, this script has needle ('meta') in several other places
#i could not figure out how to do variable substitution in this case

needle=meta
echo $needle

echo 'Combing archives for "' $needle '" and writing import script...'

echo \#!/bin/sh > ./_temp_import_needle_items_from_archives.sh

for f in ./archive/*.gz; do
  echo 'Searching in' $f 'for "' $needle '"'
  # needle on next line, replace it manually
  tar -xzf $f --to-command='grep -iHnl --label="tar -zxvf $TAR_ARCHIVE $TAR_FILENAME ; mv $TAR_FILENAME html/txt" meta || true' | grep "txt ;" >> ./_temp_import_needle_items_from_archives.sh
  echo Found: `wc -l _temp_import_needle_items_from_archives.sh`
done

chmod +x ./_temp_import_needle_items_from_archives.sh

echo run ./_temp_import_needle_items_from_archives.sh to import

