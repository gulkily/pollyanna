SELECT
	vote_value,
	vote_count
FROM (
	SELECT
		vote_value,
		COUNT(vote_value) AS vote_count
	FROM
		vote
	WHERE
		file_hash IN (
			SELECT file_hash
			FROM item_flat
			WHERE item_score >= 0
		)
	GROUP BY
		vote.vote_value
	)
ORDER BY
	vote_count DESC