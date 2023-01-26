#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;
use utf8;

sub GetInterestsPage {
	# interests aka fields
	# should probably standardize on the term for this?

	my $interestsTemplate = GetTemplate('html/form/interests.template');

	###

	my $fieldsButtons = '';
	my @fields = GetList('tagset/field');
	for my $field (@fields) {
		# there is no checkbox widget currently ... make a template for a checkbox
		my $checkboxTemplate = '<label for=$field><input type=checkbox name=$field id=$field>$fieldCaption</label>';
		my $fieldCaption = ucfirst(str_replace('_', ' ', $field));
		$checkboxTemplate = str_replace('$fieldCaption', $fieldCaption, $checkboxTemplate);
		$checkboxTemplate = str_replace('$field', $field, $checkboxTemplate);
		$fieldsButtons .= $checkboxTemplate;
		#$fieldsButtons .= '<br>';
	}

	my $fieldsPlaceholder = '<span id=fields></span>';
	$interestsTemplate = str_replace($fieldsPlaceholder, '<span id=fields>' . $fieldsButtons . '</span>', $interestsTemplate);

	###

	my $tasksButtons = '';
	my @tasks = GetList('tagset/task');
	for my $task (@tasks) {
		# there is no checkbox widget currently ... make a template for a checkbox
		my $checkboxTemplate = '<label for=$task><input type=checkbox name=$task id=$task>$taskCaption</label>';
		my $taskCaption = ucfirst(str_replace('_', ' ', $task));
		$checkboxTemplate = str_replace('$taskCaption', $taskCaption, $checkboxTemplate);
		$checkboxTemplate = str_replace('$task', $task, $checkboxTemplate);
		$tasksButtons .= $checkboxTemplate;
		#$tasksButtons .= '<br>';
	}

	my $tasksPlaceholder = '<span id=tasks></span>';
	$interestsTemplate = str_replace($tasksPlaceholder, '<span id=interests>' . $tasksButtons . '</span>', $interestsTemplate);

	###

	my $html =
		GetPageHeader('interests') .
		GetDialogX($interestsTemplate, 'Interests') .
		GetPageFooter('interests')
	;

	if (GetConfig('admin/js/enable')) {
		my @js = qw(utils profile write puzzle clock easyreg settings);
		if (GetConfig('admin/php/enable')) {
			push @js, 'write_php';
		}
		if (GetConfig('setting/html/reply_cart')) {
			push @js, 'reply_cart';
		}
		$html = InjectJs($html, @js);
	}

	return $html;
} # GetInterestsPage()

1;