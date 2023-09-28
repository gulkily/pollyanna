#!/usr/bin/perl -T
#
# widget.pl
# returns widget html 
# GetItemLabelButtons3: voting buttons for an item
# to come: clock, etc

use strict;
use warnings;
use 5.010;
use utf8;

sub FormatDateAbsolute { # $epoch
	my $epoch = shift;

	WriteLog('FormatDateAbsolute: $epoch = ' . $epoch);

	if ($epoch =~ m/\D/ && !($epoch =~ m/\d\.\d/)) { # has non-digits
		WriteLog('FormatDate: warning: $epoch failed sanity check. $epoch = ' . $epoch);
		return '[timestamp]';
	}

	my $timeDate = strftime '%Y-%m-%d %H:%M:%S', localtime $epoch;

	return $timeDate;
} # FormatDateAbsolute()

sub FormatDate { # $epoch, $showSeconds = 1 ; formats date depending on how long ago it was
# sub FormatDateForDisplay {
	my $epoch = shift;

	my $showSeconds = shift;
	if ($showSeconds) {
		$showSeconds = 1;
	} else {
		$showSeconds = 0;
	}

	WriteLog('FormatDate: $epoch = ' . $epoch);

	my $millisec = 0; #
	if ($epoch =~ m/^([0-9])\.([0-9])$/) {
		$millisec = $epoch;
		$epoch = $1;
		#return FormatDate($epoch); #
	} #todo edge case for $epoch==0

	if ($epoch =~ m/\D/ && !($epoch =~ m/\d\.\d/)) { # has non-digits
		WriteLog('FormatDate: warning: $epoch failed sanity check. $epoch = ' . $epoch);
		return '[timestamp]';
	}

	my $time = GetTime();
	my $difference = 0;
	if ($millisec) {
		$difference = $time - $millisec;
	} else {
		$difference = $time - $epoch;
	}
	my $formattedDate = '';

	if ($difference < 86400) {
		# less than a day, return 24-hour time
		if ($showSeconds) {
			$formattedDate = strftime '%H:%M:%S', localtime $epoch;
		} else {
			$formattedDate = strftime '%H:%M', localtime $epoch;
		}
	} elsif ($difference < 86400 * 30) {
		# less than a month, return short date
		$formattedDate = strftime '%m/%d', localtime $epoch;
	} else {
		# more than a month, return long date
		$formattedDate = strftime '%a, %d %b %Y', localtime $epoch;
		# my $timeDate = strftime '%Y/%m/%d %H:%M:%S', localtime $time;
	}
	return $formattedDate;
} # FormatDate()

require_once('widget/item_label_buttons.pl');

sub GetFileSizeWidget { # $fileSize ; takes file size as number, and returns html-formatted human-readable size
	my $fileSize = shift;
	if ($fileSize) {
		chomp ($fileSize);
	}

	if (defined($fileSize)) {
	    # ok
	} else {
	    WriteLog('GetFileSizeWidget: warning: defined($fileSize) was FALSE; caller = ' . join(',', caller));
	    return '';
	}

	if ($fileSize == 0 || int($fileSize)) {
		$fileSize = int($fileSize);
		WriteLog('GetFileSizeWidget: sanity check passed, $fileSize = ' . $fileSize);
	} else {
		WriteLog('GetFileSizeWidget: sanity check FAILED; caller = ' . join(',', caller));
		return '';
	}

	my $fileSizeString = $fileSize;
	my $units = '';

	if ($fileSizeString > 1024) {
		$fileSizeString = $fileSizeString / 1024;

		if ($fileSizeString > 1024) {
			$fileSizeString = $fileSizeString / 1024;

			if ($fileSizeString > 1024) {
				$fileSizeString = $fileSizeString / 1024;

				if ($fileSizeString > 1024) {
					$fileSizeString = $fileSizeString / 1024;
					$fileSizeString = ceil($fileSizeString);
					$units = '<abbr title="terabytes">TB</abbr>';
				} else {
					$fileSizeString = ceil($fileSizeString);
					$units = '<abbr title="gigabytes">GB</abbr>';
				}
			} else {
				$fileSizeString = ceil($fileSizeString);
				$units = '<abbr title="megabytes">MB</abbr>';
			}
		} else {
			$fileSizeString = ceil($fileSizeString);
			$units = '<abbr title="kilobytes">KB</abbr>';
		}
	} else {
		#$fileSizeString
		$units = 'bytes';
	}

	my $widget = $fileSizeString . ' ' . $units;

	return $widget;
} # GetFileSizeWidget()

sub GetTimestampWidget { # $time ; returns timestamp widget
	#todo format on server-side for no-js clients
	my $time = shift;
	if ($time) {
		chomp $time;
	} else {
		$time = 0;
	}
	WriteLog('GetTimestampWidget("' . $time . '"), caller: ' . join(',', caller));

	state $epoch; # state of config
	if (!defined($epoch)) {
		#what does this do?
		# epoch-formatted timestamp, simpler template
		$epoch = GetConfig('html/timestamp_epoch');
	}

	if (!$time =~ m/^[0-9.]+$/) {
		WriteLog('GetTimestampWidget: warning: sanity check failed! $time = ' . $time . '; caller = ' . join(',', caller));
		return '';
	}

	#my $timeTagFlag = 1; #timestampTagFormat

	my $widget = '';
	if ($epoch) {
		# epoch-formatted timestamp, simpler template
		$widget = GetTemplate('html/widget/timestamp_epoch.template'); # timestampTagFormat
		$widget =~ s/\$timestamp/$time/;
	} else {
		WriteLog('GetTimestampWidget: $epoch = false');
		$widget = GetTemplate('html/widget/timestamp_time.template'); #timestampTagFormat
		#$widget = GetTemplate('html/widget/timestamp_textarea.template'); #timestampTagFormat
		#$widget = GetTemplate('html/widget/timestamp.template'); #timestampTagFormat

		$widget = str_replace("\n", '', $widget);
		# if we don't do this, the link has an extra space

		my $timeDate = $time;
		$timeDate = FormatDate($time);
		# Alternative formats tried
		# my $timeDate = strftime '%c', localtime $time;
		# my $timeDate = strftime '%Y/%m/%d %H:%M:%S', localtime $time;

		my $timeDateTitle = time;
		#$timeDateTitle = FormatDate($time, 1);
		$timeDateTitle = FormatDateAbsolute($time, 1);

		# replace into template
		$widget =~ s/\$timestamp/$time/g;
		$widget =~ s/\$timeDateTitle/$timeDateTitle/g;
		$widget =~ s/\$timeDate/$timeDate/g;
	}

	chomp $widget;

	WriteLog('GetTimestampWidget: returning $widget = ' . $widget);

	return $widget;
} # GetTimestampWidget()

sub GetClockWidget {
	my $clock = '';
	if (GetConfig('html/clock')) {
		WriteLog('GetPageHeader: html/clock is enabled');
		my $currentTime = GetClockFormattedTime();
		if (GetConfig('admin/ssi/enable') && GetConfig('admin/ssi/clock_enhance')) {
			# ssi-enhanced clock
			# currently not compatible with javascript clock
			#todo needs review
			WriteLog('GetPageHeader: ssi is enabled');
			$clock = GetTemplate('html/widget/clock_ssi.template');
			$clock =~ s/\$currentTime/$currentTime/g;
		}
		else {
			# default clock
			$clock = GetTemplate('html/widget/clock.template');
			$clock =~ s/\$currentTime/$currentTime/;

			my $sizeConfig = GetConfig('html/clock_format');
			if ($sizeConfig eq '24hour') {
				$sizeConfig = 6;
			} elsif ($sizeConfig eq 'epoch') {
				$sizeConfig = 11;
			} elsif ($sizeConfig eq 'union') {
				$sizeConfig = 15;
			} else {
				$sizeConfig = 15;
			}
			if ($sizeConfig) {
				$clock = str_replace('size=15', "size=$sizeConfig", $clock);
			}
		}
		#
#		$currentTime = trim($currentTime);
	} else {
		# the plus sign is to fill in the table cell
		# othrwise netscape will not paint its background color
		# and there will be a hole in the table
		$clock = '+';
	}

	#WriteLog('GetClockWidget: $clock = ' . $clock);
	WriteLog('GetClockWidget: length($clock) = ' . length($clock));

	return $clock;
}

sub GetWidgetExpand { # $parentCount, $url ; gets "More" button widget GetExpandWidget #more
	my $parentCount = shift; # how many levels of parents to go up
	# for example, for <table><tr><td><a>here it would be 3 layers instead of 1
	# accepts integers 1-10

	my $url = shift;
	# url to point the link to after the expand happens

	if (!$parentCount || !$url) {
		WriteLog('GetWidgetExpand: warning: sanity check failed');
		return '(More)';
	}

	my $widgetTemplateHtml = GetTemplate('html/widget/more_button.template');

	if ($widgetTemplateHtml) {
		# <a href="/etc.html">More</a>
		WriteLog('GetWidgetExpand: got template ok, going to fill it in');
		$widgetTemplateHtml = str_replace('/etc.html', $url, $widgetTemplateHtml);

		if (GetConfig('admin/js/enable')) {
			my $jsTemplate = "if (window.ShowAll && this.removeAttribute) { if (this.style) { this.style.display = 'none'; } return ShowAll(this, this.parentElement); } else { return true; }";
			if (
				$parentCount > 10 ||
				$parentCount < 1 ||
				!($parentCount =~ /\\D/)
			) {
				WriteLog('GetWidgetExpand: warning: $parentCount sanity check failed');
				if (GetConfig('debug')) {
					return '(More2)';
				} else {
					return '';
				}
			} else {
				# adjust number of times it says ".parentElement"
				$jsTemplate = str_replace('.parentElement', str_repeat('.parentElement', $parentCount), $jsTemplate);
			}

			$widgetTemplateHtml = AddAttributeToTag(
				$widgetTemplateHtml,
				'a href="/etc.html"', #todo this should link to item itself
				'onclick',
				$jsTemplate
			);
		}

		#$widgetTemplateHtml = str_replace('/etc.html', $url, $widgetTemplateHtml);
	} else {
		WriteLog('GetWidgetExpand: warning: widget/more_button template not found');
		return '(More3)';
	}

	return $widgetTemplateHtml;
} # GetWidgetExpand()

sub GetWidgetSelect { # $widgetName, $currentSelection, @options
	#my $widgetId = shift; #$setting
	my $widgetName = shift; #$setting
	my $currentSelection = shift;
	my @options = @_; #@options

	my $setting = $widgetName; #todo remove shim

	#todo sanity checks
	#todo make options a hash ref ...

	my $html = '';

	$html .= '<select id="'. $setting . '" name="'. $setting . '">';

	if (!in_array($currentSelection, @options)) {
		push @options, $currentSelection;
	}

	for my $option (@options) {
		$html .= "\n";

		my $optionToDisplay = $option;
		if ($optionToDisplay =~ m/^([0-9a-f]{8})([0-9a-f]{32})$/) {
			$optionToDisplay = $1 . '..';
		}

		if ($option eq $currentSelection) {
			$html .= '<option value="' . $option . '" selected>' . $optionToDisplay . '</option>';
		} else {
			$html .= '<option value="' . $option . '">' . $optionToDisplay . '</option>';
		}
	}

	$html .= '</select>';
	#$html .= '<input name="' . $setting . '" type=text size=10 value="' . GetConfig($setting) . '">';

	#WriteLog('GetWidgetSelect: $html = ' . $html);

	return $html;
} # GetWidgetSelect()

1;
