SELECT
	task_name,
	task_param,
	touch_time,
	priority
FROM task
WHERE task_type = 'page' AND priority > 0
ORDER BY priority DESC, touch_time DESC
