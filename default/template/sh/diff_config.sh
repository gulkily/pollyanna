#!/bin/bash

#todo this should ignore files where the only difference is the "\n" at the end of file
#todo these differences normally should not appear, and the file in config/ should match the one in default/

default_dir="default"
config_dir="config"

# Find all files in the config directory
config_files=$(find "$config_dir" -type f)

# Loop through each config file and compare with the corresponding file in default
for file in $config_files; do
    default_file="${default_dir}/${file#*/}"

    # Check if the default file exists
    if [ -e "$default_file" ]; then
        # Use diff to compare the files, ignoring white spaces
        diff_output=$(diff -w "$default_file" "$file")

        # If there are differences, check if they are not just newline differences
        if [ "$?" -ne 0 ] && ! echo "$diff_output" | grep -q '^\([0-9]\+a[0-9]\+\)\?$'; then
            # Extract and print the filename from the config tree
            #echo "$(basename $file)"
            echo "$file"
        fi
    fi
done
