
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
	ON (a.file_hash = b.ballot_hash)
	join (select * from item_flat) c
	on (b.ballot_hash = c.file_hash)
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
