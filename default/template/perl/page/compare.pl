#!/usr/bin/perl -T

use strict;
use warnings;

sub GetComparePage {
	my $hashItemA = shift;
	my $hashItemB = shift;

	if (!IsItem($hashItemA) || !IsItem($hashItemB)) {
		WriteLog('GetComparePage: warning: sanity check failed');
		return '';
	}

	#todo more sanity

	my $html = '';

	$html = GetPageHeader('compare');

	my %queryParams;
	$queryParams{'where_clause'} = "WHERE file_hash = '$hashItemA' OR file_hash = '$hashItemB'";
	$queryParams{'limit_clause'} = "LIMIT 2";
	$queryParams{'order_clause'} = "ORDER BY file_hash = '$hashItemA' DESC";

	my @items = DBGetItemList(\%queryParams);

	if (scalar(@items) != 2) {
		WriteLog('GetComparePage: warning: scalar(@items) does not equal 2');
		return '';
	}

	my %itemA = %{$items[0]};
	my %itemB = %{$items[1]};

	my $itemImageA = GetImageContainer($itemA{'file_hash'}, $itemA{'item_name'}, 0, '');
	$itemImageA = AddAttributeToTag($itemImageA, 'img', 'width', '45%');
	$itemImageA = '<a href="/post.html?replyto='.$hashItemA.'&comment=surpass%20'.$hashItemB.'">'.$itemImageA.'</a>';

	my $itemImageB = GetImageContainer($itemB{'file_hash'}, $itemB{'item_name'}, 0, '');
	$itemImageB = AddAttributeToTag($itemImageB, 'img', 'width', '45%');
	$itemImageB = '<a href="/post.html?replyto='.$hashItemB.'&comment=surpass%20'.$hashItemA.'">'.$itemImageB.'</a>';

	$html .= GetDialogX($itemImageA . $itemImageB, 'Please Choose Your Preferred Image');

	$html .= GetPageFooter('compare');
	$html = InjectJs($html, qw(settings utils));

	return $html;
} # GetComparePage()

1;
