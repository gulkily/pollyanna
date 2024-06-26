SELECT
    date,
    SUM(item_count) AS item_count
FROM (
    SELECT
        SUBSTR(DATETIME(add_timestamp, 'unixepoch', 'localtime'), 0, 11) AS date,
        COUNT(file_hash) AS item_count
    FROM item_flat
    WHERE item_score >= 0
    GROUP BY date
    UNION ALL
    SELECT
        value AS date,
        COUNT(file_hash) AS item_count
    FROM
    	item_attribute
    	JOIN item_flat USING (file_hash)
    WHERE attribute = 'date'
    GROUP BY date
)
GROUP BY date

