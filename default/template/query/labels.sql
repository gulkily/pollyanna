SELECT
    label,
    COUNT(DISTINCT file_hash) AS label_count
FROM (
    SELECT
       label,
       file_hash
    FROM
       item_label
    WHERE
       file_hash IN (
          SELECT file_hash
          FROM item_flat
          WHERE item_score >= 0
       )
    GROUP BY
       label, file_hash
    )
GROUP BY
    label
ORDER BY
    label_count DESC
