#!/usr/bin/perl -T
use strict;
use warnings;
use 5.010;

sub GetReplyCartDialog { # uses reply_cart.template and needs reply_cart.js
# sub GetCartDialog {
# sub GetCart {
	if (!GetConfig('setting/html/reply_cart')) {
		WriteLog('GetReplyCartDialog: warning: called when reply_cart setting is off');
		return '';
	}

	my $replyCart = GetTemplate('html/widget/reply_cart.template');

	if (GetConfig('setting/admin/js/enable')) {
		$replyCart = AddAttributeToTag(
			$replyCart, 'a id=replyCartInsert', 'onclick',
			"if (window.insertReplyCart) { return insertReplyCart() + clearReplyCart(); }"
		);

		$replyCart = AddAttributeToTag(
			$replyCart, 'a id=replyCartClear', 'onclick',
			"if (window.clearReplyCart) { return clearReplyCart() }"
		); #todo re-add this control to template and rename function for consistency

		$replyCart = AddAttributeToTag(
			$replyCart, 'a id=replyCartAddAll', 'onclick',
			"if (window.ReplyCartAddAll) { return ReplyCartAddAll() }"
		); #todo re-add this control to template
	}

	my $replyCartDialog = GetDialogX($replyCart, 'Cart');
	$replyCartDialog = '<span class=advanced>' . $replyCartDialog . '</span>';
	return $replyCartDialog;
} # GetReplyCartDialog()

1;