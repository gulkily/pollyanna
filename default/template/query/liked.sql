SELECT * from item_flat where file_hash in (select file_hash from vote where vote.author_key = '646E6CAA9CBABE66')

