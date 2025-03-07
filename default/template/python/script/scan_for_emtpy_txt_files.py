#!/usr/bin/env python3
"""
Scans a directory recursively for empty .txt and .text files.
Outputs just the filenames, one per line, suitable for piping to xargs.

Usage: python script_name.py [directory_path]
If no directory is specified, scans current working directory.
"""

import os
import sys

def find_empty_text_files(directory):
    empty_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.lower().endswith(('.txt', '.text')):
                file_path = os.path.join(root, file)
                try:
                    if os.path.getsize(file_path) == 0:
                        empty_files.append(file_path)
                except OSError:
                    continue
    return empty_files

if __name__ == "__main__":
    if len(sys.argv) > 2:
        print("Usage: python script_name.py [directory_path]", file=sys.stderr)
        sys.exit(1)

    directory_to_scan = sys.argv[1] if len(sys.argv) == 2 else os.getcwd()

    if not os.path.isdir(directory_to_scan):
        print(f"Error: {directory_to_scan} is not a valid directory", file=sys.stderr)
        sys.exit(1)

    empty_text_files = find_empty_text_files(directory_to_scan)

    if empty_text_files:
        for file in empty_text_files:
            print(file)
