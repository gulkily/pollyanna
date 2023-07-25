SELECT
	c.file_hash,
	author_alias
FROM
	( SELECT * FROM item_flat ) a
	JOIN ( SELECT * FROM vote) b ON (a.file_hash = b.ballot_hash)
	JOIN (SELECT * FROM item_flat) c ON (b.file_hash = c.file_hash)
	JOIN author_flat ON (author_flat.author_key = a.author_key)
WHERE
	b.vote_value = 'avatar'
	AND author_flat.author_alias = ?
ORDER BY a.add_timestamp DESC
LIMIT 1
