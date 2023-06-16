SELECT
	vote_value,
	vote_count
FROM
	(
		SELECT
			vote_value,
			COUNT(vote_value) AS vote_count
		FROM
			vote
		GROUP BY
			vote_value
	)
WHERE
	vote_value NOT IN (
		'hastext',
		'notext',
		'hastitle',
		'hasvote',
		'changelog'
	) AND
	vote_count >= 2
ORDER BY
	vote_count DESC;