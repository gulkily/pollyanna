SELECT
	item_title,
	file_hash,
	author_key,
	item_sequence,
	'' AS tagset_pending,
	'' AS cart
FROM item_flat
WHERE
	file_hash IN (
		SELECT file_hash
		FROM author_flat
		WHERE
			author_alias IN (
				SELECT alias FROM author_alias
				WHERE
					key = ?
					AND file_hash IN (SELECT file_hash FROM item_flat WHERE labels_list LIKE '%,approve,%')
			)
			AND file_hash IN (
				SELECT file_hash
				FROM item_flat
				WHERE (
					labels_list NOT LIKE '%,approve,%' AND labels_list NOT LIKE '%,flag,%'
				)
			)
	)



--keys that need approval for a user
	SELECT * FROM item_flat
	WHERE
		file_hash IN (
			SELECT file_hash
			FROM author_flat
			WHERE
				author_alias IN (
					SELECT alias FROM author_alias
					WHERE
						key = ?
						AND file_hash IN (SELECT file_hash FROM item_flat WHERE labels_list LIKE '%,approve,%')
				)
				AND file_hash IN (
					SELECT file_hash
					FROM item_flat
					WHERE (
						labels_list NOT LIKE '%,approve,%' AND labels_list NOT LIKE '%,flag,%'
					)
				)
		)




SELECT
	file_hash,
	author_key AS author_id,
	'' AS tagset_pending,
	author_key,
FROM
	item_flat
	JOIN author_flat USING (author_key)
WHERE
	labels_list LIKE '%,pubkey,%'
	AND (labels_list NOT LIKE '%,approve,%' AND labels_list NOT like '%,person,%')
	AND author_key IN (SELECT author_key FROM author_flat WHERE author_alias = 'Guest')
ORDER BY
	add_timestamp DESC





SELECT author_alias, c.file_hash from
(
	SELECT
		*
	FROM
		item_flat
) a
JOIN
(
	SELECT * FROM vote) b
	ON (a.file_hash = b.source_hash)
	join (select * from item_flat) c
	on (b.source_hash = c.file_hash)
JOIN author_flat ON (author_flat.author_key = a.author_key)
where
	b.vote_value = 'avatar'
	AND author_flat.author_alias = 'testing2'
order by a.add_timestamp desc
LIMIT 1



CREATE VIEW item_attribute_latest
AS
SELECT
file_hash,
attribute,
value,
source,
MAX(epoch) AS epoch
FROM item_attribute
GROUP BY file_hash, attribute
ORDER BY epoch DESC
;




select
	key||','||date
from
	config
where
	key||','||date in
		(
			select
				key||','||date
			from
				config
			group by key
			order by date desc
		)


CREATE VIEW relative_score
SELECT
	sum(relative_score) AS relative_score,
	file_hash
FROM (
	SELECT
		COUNT(*) AS relative_score,
		file_hash
	FROM
		item_attribute
	WHERE
		attribute = 'surpass'
	GROUP BY
		file_hash
UNION ALL
	SELECT
		(-(COUNT(*))) AS relative_score,
		`value` AS file_hash
	FROM
		item_attribute
	WHERE
		attribute = 'surpass'
	GROUP BY
		file_hash
)
GROUP BY file_hash
ORDER BY relative_score DESC
