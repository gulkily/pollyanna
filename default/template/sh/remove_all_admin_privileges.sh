#!/bin/sh

sqlite3 -echo -cmd ".headers on" -cmd ".timeout 500" -cmd ".mode column" cache/*/index.sqlite3 'DELETE FROM vote WHERE vote_value = "admin";'