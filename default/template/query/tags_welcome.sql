SELECT
	label,
	label_count
FROM
	(
		SELECT
			label,
			COUNT(label) AS label_count
		FROM
			item_label
		GROUP BY
			label
	)
WHERE
	label NOT IN (
		'hastext',
		'notext',
		'hastitle',
		'hasvote',
		'changelog'
	) AND
	label_count >= 2
ORDER BY
	label_count DESC;