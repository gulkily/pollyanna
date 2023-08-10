#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetTopicsPage {
	state $topicsPage = 
		GetPageHeader('topics') . 
		GetQueryAsDialog('topics', 'Topics') .
		GetQueryAsDialog("SELECT item_title, file_hash FROM item_flat WHERE tags_list like '%topic%'", 'Topics') .
		GetQueryAsDialog("SELECT DISTINCT vote_value FROM vote WHERE LOWER(vote_value) = vote_value", 'Tags') .
		GetPageFooter('topics')
	;

	return $topicsPage;
}

1;