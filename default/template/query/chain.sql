SELECT
	'' AS special_title_tags_list_author,
	item_flat.item_title item_title,
	item_flat.author_key AS author_id,
	item_flat.tags_list tags_list,
	item_attribute.value AS chain_order,
	item_attribute.epoch chain_timestamp,
	item_attribute.file_hash AS file_hash,
	'' AS tagset_chain
FROM
	item_attribute
	JOIN item_flat ON (item_flat.file_hash = item_attribute.file_hash)
WHERE
	attribute = 'chain_sequence'
ORDER BY
	chain_timestamp DESC