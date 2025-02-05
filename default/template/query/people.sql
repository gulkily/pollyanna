SELECT * FROM (
	SELECT
		author_alias AS person_name,
		COUNT(author_key) AS author_key_count,
		MAX(author_seen) AS author_seen,
		SUM(author_score) AS author_score,
		SUM(item_count) AS item_count
	FROM author_flat
	WHERE author_key IN (SELECT author_key FROM person_author)
	GROUP BY author_alias
) AS query1
WHERE
	person_name != ''
	AND author_key_count >= 1
	AND author_score >= 0
