SELECT * from item_flat where file_hash in (select file_hash from item_label where item_label.author_key = '646E6CAA9CBABE66')

