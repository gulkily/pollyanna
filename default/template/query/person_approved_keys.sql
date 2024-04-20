SELECT
    file_hash,
    item_title,
    add_timestamp,
    '' AS tagset_pubkey
FROM item_flat
WHERE
    (labels_list LIKE '%,pubkey,%' OR labels_list LIKE '%,my_name_is,%') AND
    labels_list LIKE '%,approve,%' AND
    file_hash IN (
        SELECT file_hash
        FROM item_flat
        WHERE author_key IN(
            SELECT author_key
            FROM author_flat
            WHERE author_alias = ?
        )
    )
