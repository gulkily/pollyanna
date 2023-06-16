SELECT
	item_flat.item_title AS event_title,
	event.event_time AS event_time,
	event.event_duration AS event_duration,
	item_flat.file_hash AS file_hash,
	item_flat.author_key AS author_key,
	item_flat.file_path AS file_path
FROM
	event
	LEFT JOIN item_flat ON (event.item_hash = item_flat.file_hash)
ORDER BY
	event_time