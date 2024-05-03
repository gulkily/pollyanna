SELECT
    item_attribute_chain.value AS chain_order,
    item_attribute_chain.epoch AS chain_timestamp,
    item_flat.add_timestamp AS add_timestamp,
    item_attribute_chain.file_hash AS file_hash,
	remote_addr_ip_log.remote_addr,
	remote_addr_ip_log.first_three_octets,
	remote_addr_ip_log.first_two_octets,
    item_flat.item_title AS item_title
FROM
    item_attribute AS item_attribute_chain
JOIN
    item_flat ON (item_flat.file_hash = item_attribute_chain.file_hash)
LEFT JOIN
    item_attribute AS item_attribute_hash ON (item_attribute_hash.file_hash = item_flat.file_hash AND item_attribute_hash.attribute = 'chain_hash')
JOIN
	remote_addr_ip_log ON (remote_addr_ip_log.file_hash = item_flat.file_hash)
WHERE
    item_attribute_chain.attribute = 'chain_sequence'
ORDER BY
	ABS(add_timestamp - chain_timestamp),
    chain_timestamp DESC
