SELECT
	author_alias,
	count(author_key) AS author_key_count,
	MAX(last_seen) AS last_seen,
	SUM(author_score) AS author_score,
	SUM(item_count) AS item_count
FROM author_flat
GROUP BY author_alias