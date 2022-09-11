#!/bin/bash

for f in html/txt/*
do
  new="${f// /_}"
  if [ "$new" != "$f" ]
  then
    if [ -e "$new" ]
    then
      echo not renaming \""$f"\" because \""$new"\" already exists
    else
      echo moving "$f" to "$new"
    mv "$f" "$new"
  fi
fi
done

