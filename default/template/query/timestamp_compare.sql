SELECT
	item_title,
	item_flat.file_hash,
	item_attribute.attribute AS type,
	item_attribute.value AS value,
	add_timestamp AS notarized,
	ABS(item_attribute.value - add_timestamp ) AS difference
FROM
	item_flat
	JOIN item_attribute ON (item_attribute.file_hash = item_flat.file_hash)
WHERE
	attribute like '%_timestamp' AND
	ABS(ts1 - ts2) > 300
ORDER BY
	item_attribute.file_hash,
	add_timestamp DESC
