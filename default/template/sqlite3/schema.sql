PRAGMA journal_mode=WAL;

CREATE TABLE item(
id INTEGER PRIMARY KEY AUTOINCREMENT,
file_path UNIQUE,
file_name,
file_hash UNIQUE,
item_type
);

CREATE TABLE item_attribute
(
id INTEGER PRIMARY KEY AUTOINCREMENT,
file_hash,
attribute,
value,
epoch,
source
);

CREATE UNIQUE INDEX item_attribute_unique ON item_attribute (
file_hash,
attribute,
value,
epoch,
source
);

CREATE TABLE item_parent(item_hash, parent_hash, CONSTRAINT item_hash_not_equal_parent_hash CHECK (item_hash <> parent_hash));
CREATE UNIQUE INDEX item_parent_unique ON item_parent(item_hash, parent_hash);

CREATE TABLE author_alias(
id INTEGER PRIMARY KEY AUTOINCREMENT,
key UNIQUE,
alias,
fingerprint,
file_hash
);

CREATE VIEW child_count
AS
SELECT
parent_hash AS parent_hash,
COUNT(*) AS child_count
FROM
item_parent
GROUP BY
parent_hash;

CREATE TABLE item_label(id INTEGER PRIMARY KEY AUTOINCREMENT, file_hash, label_time, label, author_key, source_hash);
CREATE UNIQUE INDEX item_label_unique ON item_label (file_hash, label_time, label, author_key);

CREATE TABLE item_page(item_hash, page_name, page_param);
CREATE UNIQUE INDEX item_page_unique ON item_page(item_hash, page_name, page_param);

CREATE TABLE location(
id INTEGER PRIMARY KEY AUTOINCREMENT,
item_hash,
author_key,
latitude,
longitude
);

CREATE TABLE user_agent(
user_agent_string
);

CREATE TABLE task(id INTEGER PRIMARY KEY AUTOINCREMENT, task_type, task_name, task_param, touch_time INTEGER, priority DEFAULT 1);
CREATE UNIQUE INDEX task_unique ON task(task_type, task_name, task_param);


CREATE TABLE config (key, value, reset_flag, file_hash);

CREATE VIEW parent_count
AS
SELECT
item_hash AS item_hash,
COUNT(parent_hash) AS parent_count
FROM
item_parent
GROUP BY
item_hash
;

CREATE TABLE label_weight(label, weight);

CREATE TABLE label_parent(label, label_parent);

CREATE VIEW item_labels_list
AS
SELECT
file_hash,
GROUP_CONCAT(DISTINCT label) AS labels_list
FROM item_label
GROUP BY file_hash
;

CREATE VIEW item_label_count
AS
SELECT
file_hash,
label AS label,
COUNT(file_hash) AS label_count
FROM item_label
GROUP BY file_hash, label
ORDER BY label_count DESC
;



CREATE VIEW item_score
AS
SELECT
item.file_hash AS file_hash,
IFNULL(SUM(label_weight.weight), 0) AS item_score
FROM
item_label
LEFT JOIN item
ON (item_label.file_hash = item.file_hash)
LEFT JOIN label_weight
ON (item_label.label = label_weight.label)
GROUP BY
item.file_hash
;

CREATE VIEW item_attribute_latest
AS
SELECT
item_attribute_latest_timestamp.file_hash, 
item_attribute_latest_timestamp.attribute, 
item_attribute_latest_timestamp.epoch,
item_attribute.value
FROM (
SELECT file_hash, attribute, MAX(epoch) AS epoch FROM item_attribute
GROUP BY
file_hash, attribute
ORDER BY epoch DESC
) AS item_attribute_latest_timestamp
JOIN item_attribute ON (
item_attribute.file_hash = item_attribute_latest_timestamp.file_hash AND
item_attribute.attribute = item_attribute_latest_timestamp.attribute AND
item_attribute.epoch = item_attribute_latest_timestamp.epoch
)
;

CREATE VIEW added_time
AS
SELECT
file_hash,
MIN(value) AS add_timestamp
FROM
item_attribute_latest
WHERE
attribute LIKE '%_timestamp'
GROUP BY
file_hash
;


CREATE VIEW item_title
AS
SELECT
file_hash,
value AS title
FROM item_attribute_latest
WHERE attribute = 'title';


CREATE VIEW item_name
AS
SELECT
file_hash,
value AS name
FROM item_attribute_latest
WHERE attribute = 'name';


CREATE VIEW item_order
AS
SELECT
file_hash,
value AS item_order
FROM item_attribute_latest
WHERE attribute = 'order';


CREATE VIEW item_sequence
AS
SELECT
file_hash,
value AS item_sequence,
epoch AS item_timestamp
FROM item_attribute_latest
WHERE attribute = 'chain_sequence';


CREATE VIEW item_author
AS
SELECT
file_hash,
MAX(value) AS author_key
FROM item_attribute_latest
WHERE attribute IN ('cookie_id', 'gpg_id')
GROUP BY file_hash
;

CREATE VIEW item_client
AS
SELECT
file_hash,
MAX(value) AS author_key
FROM item_attribute_latest
WHERE attribute IN ('client_id')
GROUP BY file_hash
;

CREATE VIEW item_flat
AS
SELECT
item.file_path AS file_path,
IFNULL(item_name.name, item.file_name) AS item_name,
item.file_hash AS file_hash,
IFNULL(item_author.author_key, '') AS author_key,
IFNULL(child_count.child_count, 0) AS child_count,
IFNULL(parent_count.parent_count, 0) AS parent_count,
added_time.add_timestamp AS add_timestamp,
IFNULL(item_sequence.item_sequence, '') AS item_sequence,
IFNULL(item_title.title, '') AS item_title,
IFNULL(item_score.item_score, 0) AS item_score,
item.item_type AS item_type,
','||labels_list||',' AS labels_list,
item.file_name AS file_name,
CAST(item_order.item_order AS INTEGER) AS item_order
FROM
item
LEFT JOIN child_count ON ( item.file_hash = child_count.parent_hash )
LEFT JOIN parent_count ON ( item.file_hash = parent_count.item_hash )
LEFT JOIN added_time ON ( item.file_hash = added_time.file_hash )
LEFT JOIN item_title ON ( item.file_hash = item_title.file_hash )
LEFT JOIN item_name ON ( item.file_hash = item_name.file_hash )
LEFT JOIN item_order ON ( item.file_hash = item_order.file_hash )
LEFT JOIN item_author ON ( item.file_hash = item_author.file_hash )
LEFT JOIN item_score ON ( item.file_hash = item_score.file_hash)
LEFT JOIN item_labels_list ON ( item.file_hash = item_labels_list.file_hash )
LEFT JOIN item_sequence ON ( item.file_hash = item_sequence.file_hash )
;

CREATE VIEW item_flat_filtered
AS
SELECT
item.file_path AS file_path,
IFNULL(item_name.name, item.file_name) AS item_name,
item.file_hash AS file_hash,
IFNULL(item_author.author_key, '') AS author_key,
IFNULL(child_count.child_count, 0) AS child_count,
IFNULL(parent_count.parent_count, 0) AS parent_count,
added_time.add_timestamp AS add_timestamp,
IFNULL(item_sequence.item_sequence, '') AS item_sequence,
IFNULL(item_title.title, '') AS item_title,
IFNULL(item_score.item_score, 0) AS item_score,
item.item_type AS item_type,
','||labels_list||',' AS labels_list,
item.file_name AS file_name,
CAST(item_order.item_order AS INTEGER) AS item_order
FROM
item
LEFT JOIN child_count ON ( item.file_hash = child_count.parent_hash )
LEFT JOIN parent_count ON ( item.file_hash = parent_count.item_hash )
LEFT JOIN added_time ON ( item.file_hash = added_time.file_hash )
LEFT JOIN item_title ON ( item.file_hash = item_title.file_hash )
LEFT JOIN item_name ON ( item.file_hash = item_name.file_hash )
LEFT JOIN item_order ON ( item.file_hash = item_order.file_hash )
LEFT JOIN item_author ON ( item.file_hash = item_author.file_hash )
LEFT JOIN item_score ON ( item.file_hash = item_score.file_hash)
LEFT JOIN item_labels_list ON ( item.file_hash = item_labels_list.file_hash )
LEFT JOIN item_sequence ON ( item.file_hash = item_sequence.file_hash )
;

CREATE VIEW author_score
AS
SELECT
item_flat.author_key AS author_key,
SUM(item_flat.item_score) AS author_score
FROM
item_flat
GROUP BY
item_flat.author_key
;

CREATE VIEW item_score_weighed
AS
SELECT
item.file_hash AS file_hash,
IFNULL(SUM(label_weight.weight), 0) AS item_score,
IFNULL(SUM(label_weight.weight), 0) * IFNULL(SUM(author_score), 0) AS item_score_weighed
FROM
item_label
LEFT JOIN item
ON (item_label.file_hash = item.file_hash)
LEFT JOIN label_weight
ON (item_label.label = label_weight.label)
LEFT JOIN author_score
ON (item_label.author_key = author_score.author_key)
GROUP BY
item.file_hash
;

CREATE VIEW author
AS
SELECT DISTINCT
value AS key
FROM
item_attribute
WHERE
attribute IN ('cookie_id', 'gpg_id');

CREATE VIEW author_flat
AS
SELECT
author.key AS author_key,
author_alias.alias AS author_alias,
MAX(item_flat.add_timestamp) AS author_seen,
SUM(item_flat.item_score) AS author_score,
COUNT(item_flat.file_hash) AS item_count,
author_alias.file_hash AS file_hash
FROM
author
LEFT JOIN author_alias
ON (author.key = author_alias.key)
LEFT JOIN item_flat
ON (author.key = item_flat.author_key)
GROUP BY
author.key,
author_alias.alias,
author_alias.file_hash
;

CREATE VIEW person_flat
AS
SELECT
author_alias,
COUNT(author_key) AS author_key_count,
MAX(author_seen) AS author_seen,
SUM(author_score) AS author_score,
SUM(item_count) AS item_count
FROM author_flat
WHERE author_alias != ''
GROUP BY author_alias
;

CREATE VIEW person_author
AS
SELECT DISTINCT
author_key,
author_alias
FROM author_flat
WHERE author_alias != ''
AND file_hash IN (SELECT file_hash FROM item_flat WHERE labels_list LIKE '%,approve,%')
;

CREATE VIEW item_score_relative AS
SELECT 
SUM(score_relative) AS score_relative,
file_hash
FROM (
SELECT
COUNT(*) AS score_relative,
file_hash
FROM
item_attribute
WHERE
attribute = 'surpass'
GROUP BY
file_hash
UNION ALL
SELECT
(-(COUNT(*))) AS score_relative,
`value` AS file_hash
FROM
item_attribute
WHERE
attribute = 'surpass'
GROUP BY
file_hash
)
GROUP BY file_hash
ORDER BY score_relative DESC;

CREATE VIEW author_alias_valid AS
SELECT
author_alias.key AS author_key,
author_alias.alias AS alias,
author_alias.fingerprint AS fingerprint,
author_alias.file_hash AS file_hash
FROM
author_alias
WHERE
file_hash IN (
SELECT file_hash
FROM item_label
WHERE label IN ('approve', 'vouch')
)
;