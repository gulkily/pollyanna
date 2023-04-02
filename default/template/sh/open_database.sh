#!/bin/bash

# opens console-based database viewer and editor and shows tables

sqlite3 -echo -cmd ".headers on" -cmd ".timeout 500" -cmd ".tables" cache/*/index.sqlite3

