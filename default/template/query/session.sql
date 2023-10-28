SELECT *
FROM author_flat
WHERE author_seen >= strftime('%s', 'now', '-75 minutes');

