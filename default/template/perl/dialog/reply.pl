#!/usr/bin/perl -T

use strict;
use warnings;

use 5.010;

sub GetReplyForm { # $replyTo ; returns reply form for specified item
# sub GetReplyDialog {
# sub GetCommentDialog {
	my $replyTo = shift;
	chomp $replyTo;

	state $accessKey;
	if (!$accessKey) {
		$accessKey = GetAccessKey('write');
	} # if (!$accessKey)

	if (!$replyTo || !IsItem($replyTo)) {
		WriteLog('GetReplyForm: warning: sanity check failed');
		return '';
	} # if (!$replyTo || !IsItem($replyTo))

	WriteLog('GetReplyForm: $replyTo = ' . $replyTo);

	my $replyTag = GetTemplate('html/replytag.template');
	my $replyForm = GetTemplate('html/form/write/reply.template');

	$replyTag =~ s/\$parentPost/$replyTo/g;
	$replyForm =~ s/\$replyTo/$replyTo/g;

	if (GetConfig('admin/php/enable') && !GetConfig('admin/php/rewrite')) {
		$replyForm =~ s/\/post\.html/\/post.php/g;
	}

	if (GetConfig('admin/js/enable')) {
		if (GetConfig('admin/js/reply_form_optimize_for_delivery')) {
			$replyForm = AddAttributeToTag(
				$replyForm,
				'input id=btnSendReply',
				'onclick',
				"this.value = 'Meditate...'; if (window.WriteSubmit) { setTimeout('WriteSubmit();', 100); return true; } else { return true; }" #reply, optimize_for_delivery = true
			);
		} else {
			$replyForm = AddAttributeToTag(
				$replyForm,
				'input id=btnSendReply',
				'onclick',
				"this.value='Meditate...';if(window.WriteSubmit){return WriteSubmit(this);}" #reply, optimize_for_delivery = false
			);
		}

		#todo the return value can be changed from false to true to issue two submissions, one signed and one not
		#		Use this line instead for improved delivery, but duplicate messages
		#			#todo merge the duplicates server-side
		#			"this.value = 'Meditate...'; if (window.WriteSubmit) { setTimeout('WriteSubmit();', 1); return false; } else { return true; }"


		if (GetConfig('admin/php/enable')) {
			$replyForm = AddAttributeToTag($replyForm, 'textarea', 'onchange', "if (window.CommentOnChange) { return CommentOnChange(this, 'compose'); } else { return true; }");
			$replyForm = AddAttributeToTag($replyForm, 'textarea', 'onkeyup', "if (window.CommentOnChange) { return CommentOnChange(this, 'compose'); } else { return true; }");
		}

		if ($accessKey) {
			$replyForm = AddAttributeToTag($replyForm, 'textarea', 'accesskey', $accessKey);
		}

		if (GetConfig('admin/js/translit')) {
			# add onkeydown event which calls translitKey if feature is enabled
			# translit substitutes typed characters with a different character set
			$replyForm = AddAttributeToTag(
				$replyForm,
				'textarea',
				'onkeydown',
				'if (window.translitKey) { translitKey(event, this); } else { return true; }'
			);
		}
	} # GetConfig('admin/js/enable')

	$replyForm = GetDialogX($replyForm, 'Comment');

	return $replyForm;
} # GetReplyForm()

1;
