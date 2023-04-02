#!/bin/sh

# remove all admin privileges stored in database from all users
# only affects the index database cache, not the underlying data

sqlite3 -echo -cmd ".headers on" -cmd ".timeout 500" -cmd ".mode column" cache/*/index.sqlite3 'DELETE FROM vote WHERE vote_value = "admin";'