SELECT
	COALESCE(NULLIF(item_title,''), 'Untitled') AS item_title,
	item_flat.add_timestamp AS add_timestamp,
	item_attribute_chain.value AS chain_timestamp,
	(item_flat.file_hash = ?) AS this_row,
	'' AS cart,
	item_flat.file_hash AS file_hash,
	GROUP_CONCAT(related_list.attribute) AS attribute_list,
	COUNT(related_list.attribute) AS attribute_count
FROM
	item_flat
		JOIN
		(
			SELECT
				file_hash,
				attribute
			FROM
				item_attribute
			WHERE (
				attribute||'='||value IN (
					SELECT
						attribute||'='||value
					FROM
						item_attribute
					WHERE
						file_hash IN (?) AND
						attribute IN (
							'http',
							'https',
							'url_domain',
							'title',
							'cookie_id',
							'client_id',
							'url_domain',
							'message_hash'
						)
				)
			)
		) AS related_list ON (item_flat.file_hash = related_list.file_hash)
		JOIN item_attribute AS item_attribute_chain ON (item_flat.file_hash = item_attribute_chain.file_hash)
WHERE
	labels_list NOT LIKE '%notext%'
	AND
	item_attribute_chain.attribute = 'chain_timestamp'
GROUP BY
	item_title, add_timestamp, this_row, item_flat.file_hash
ORDER BY
	attribute_count DESC, add_timestamp DESC
LIMIT 25