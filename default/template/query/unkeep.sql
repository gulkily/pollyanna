SELECT 
	file_hash 
FROM 
	item_flat 
WHERE 
	file_hash NOT IN (
		SELECT item_hash FROM item_parent 
		WHERE parent_hash IN (
			SELECT file_hash FROM item_flat 
			WHERE labels_list LIKE '%,keep,%'
		)
	) AND 
	labels_list NOT LIKE '%keep%'
;
