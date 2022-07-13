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
