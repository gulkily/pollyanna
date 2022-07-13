SELECT
	'' AS tagset_compost,
	file_hash,
	item_title,
	item_score,
	item_flat.author_key AS author_key,
	author_score,
	parent_count,
	child_count,
	add_timestamp,
	item_sequence
FROM
	item_flat
	LEFT JOIN author_score ON (author_score.author_key = item_flat.author_key)
ORDER BY add_timestamp DESC
