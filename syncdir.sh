#!/bin/bash

# DEPENDENCIES: inotify-tools, rsync

# Check if two arguments were provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 source_directory destination_directory"
  exit 1
fi

SOURCE="$1"
DEST="$2"

# Check if the source directory exists
if [ ! -d "$SOURCE" ]; then
  echo "Error: Source directory does not exist."
  exit 1
fi

# Using inotifywait to monitor the source directory
inotifywait -m -r -e modify,create,delete --format '%w%f' "$SOURCE" | while read file
do
  rsync -av --delete "$SOURCE" "$DEST"
done
