SELECT
    item_flat.file_hash,
    item_title,
    item_flat.author_key AS author_id,
    COUNT(CASE WHEN item_label.label = 'solution' THEN 1 ELSE NULL END) AS solution_count
FROM
    item_flat
    LEFT JOIN item_parent ON (item_flat.file_hash = item_parent.parent_hash)
    LEFT JOIN item_label ON (item_parent.item_hash = item_label.file_hash)
WHERE
    labels_list LIKE '%,problem,%'
GROUP BY
    item_flat.file_hash
