SELECT label
FROM item_label
WHERE source_hash = ?
GROUP BY label