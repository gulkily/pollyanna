SELECT
	file_hash,
	item_title,
	add_timestamp
FROM item_flat
WHERE
	file_hash in (
		SELECT item_hash
		FROM item_parent
		WHERE parent_hash in
		(
			SELECT file_hash
			FROM item_flat
			WHERE author_key = ?
		)
	) AND
	author_key != ? AND
	add_timestamp >= strftime('%s', 'now', '-3 day') AND
	file_hash NOT IN (
		SELECT parent_hash 
		FROM item_parent 
		WHERE item_hash IN (
			SELECT file_hash 
			FROM item_author 
			WHERE author_key = ?
		)
	)
ORDER BY add_timestamp DESC
