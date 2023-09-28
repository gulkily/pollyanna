select label, count(label) label_count from item_label group by label order by label_count desc;

