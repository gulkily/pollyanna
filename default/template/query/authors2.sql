SELECT
	author_alias,
	count(author_key) AS author_key_count,
	MAX(author_seen) AS author_seen,
	SUM(author_score) AS author_score,
	SUM(item_count) AS item_count
FROM author_flat
GROUP BY author_alias