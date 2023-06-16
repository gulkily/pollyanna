select vote_value, count(vote_value) vote_count from vote group by vote_value order by vote_count desc;

