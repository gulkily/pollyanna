SELECT
    '' AS special_title_labels_list_author,
    item_flat.item_title AS item_title,
    item_flat.author_key AS author_id,
    item_flat.labels_list AS labels_list,
    item_attribute_chain.value AS chain_order,
    item_attribute_chain.epoch AS chain_timestamp,
    item_flat.add_timestamp AS add_timestamp,
    item_attribute_hash.value AS chain_hash, 
    item_attribute_chain.file_hash AS file_hash,
    '' AS tagset_chain,
    '' AS cart
FROM
    item_attribute AS item_attribute_chain
JOIN
    item_flat ON (item_flat.file_hash = item_attribute_chain.file_hash)
LEFT JOIN
    item_attribute AS item_attribute_hash ON (item_attribute_hash.file_hash = item_flat.file_hash AND item_attribute_hash.attribute = 'chain_hash')
WHERE
    item_attribute_chain.attribute = 'chain_sequence'
ORDER BY
    chain_timestamp DESC