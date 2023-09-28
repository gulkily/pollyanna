#!/bin/bash

#sqlite3 -cmd ".headers off" -cmd ".timeout 500" cache/*/index.sqlite3 "SELECT file_hash FROM item_flat WHERE ','||labels_list||',' NOT LIKE '%,pubkey,%' and ','||labels_list||',' NOT LIKE '%,admin,%' AND ','||labels_list||',' NOT LIKE '%,approve,%';" >> log/archived.log

