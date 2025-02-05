SELECT
    item_label.label AS label,
	COUNT(DISTINCT item_label.file_hash) AS label_count
FROM
	item_label
    JOIN item_flat ON (item_label.file_hash = item_flat.file_hash)
WHERE
    item_flat.item_score >= 0
GROUP BY
    item_label.label
ORDER BY
	label_count DESC