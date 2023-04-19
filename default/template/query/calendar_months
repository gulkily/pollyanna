SELECT
    year_month
FROM (
    SELECT
        SUBSTR(DATETIME(add_timestamp, 'unixepoch', 'localtime'), 0, 8) AS year_month
    FROM item_flat
    WHERE item_score >= 0
    GROUP BY year_month
    UNION ALL
    SELECT
        SUBSTR(value, 0, 8) AS year_month
    FROM item_attribute
    WHERE attribute = 'date'
    GROUP BY year_month
)
GROUP BY year_month

