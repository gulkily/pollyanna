SELECT
	key,
	value,
	reset_flag,
	file_hash
FROM
	config
	LEFT JOIN item_flat ON (config.file_hash = item_flat.file_hash)
WHERE
	(','||labels_list||',' like '%,admin,%')
ORDER BY
	add_timestamp DESC
