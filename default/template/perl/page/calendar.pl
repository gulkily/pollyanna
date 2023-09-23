#!/usr/bin/perl -T

use strict;
use warnings;

use Time::HiRes; # High resolution alarm, sleep, gettimeofday, interval timers
use Time::Local; # Efficiently compute time from local and GMT time
use Time::Piece; # Object Oriented time objects
use Time::Seconds; # A simple API to convert seconds to other date values
use Time::tm; # Internal object used by Time::gmtime and Time::localtime
#use Time::ParseDate;

use POSIX qw(strftime);

#January - 31 days
#February - 28 days in a common year and 29 days in leap years
#March - 31 days
#April - 30 days
#May - 31 days
#June - 30 days
#July - 31 days
#August - 31 days
#September - 30 days
#October - 31 days
#November - 30 days
#December - 31 days

# leap years
# divisible by 4
#   except divisible by 100
#     except divisible by 400

sub IsLeapYear { # $year ; returns 1 if leap year, 0 if not
	my $year = shift;

	#todo sanity checks
	
	if ($year % 4) {
		#2001
		return 0;
	} else {
		if (!($year % 400)) {
			# 2000
			return 1;
		} else {
			if (!($year % 100)) {
				# 1900
				return 0;
			} else {
				# 2004
				return 1;
			}
		}
	}
} # IsLeapYear()

sub GetNumberOfDaysInMonth { # $year, $month ; return number of days in given year's given month
	my $year = shift;
	my $month = shift;

	# assume resonable inputs #todo sanity
	my $numberOfDays = 0;

	# january = 1

	if (!defined($month)) {
		WriteLog('GetNumberOfDaysInMonth: warning: $month not defined; caller = ' . join(',', caller));
		return '';
	}

	if ($month == 1 || $month == 3 || $month == 5 || $month == 7 || $month == 8 || $month == 10 || $month == 12) {
		$numberOfDays = 31;
	} elsif ($month == 4 || $month == 6 || $month == 7 || $month == 9 || $month == 11) {
		$numberOfDays = 30;
	} elsif ($month == 2) {
		#february
		if (IsLeapYear($year)) {
			$numberOfDays = 29;
		} else {
			$numberOfDays = 28;
		}
	}
	return $numberOfDays;
} # GetNumberOfDaysInMonth()

use Time::Local;

#$time = timelocal($sec,$min,$hours,$mday,$mon,$year);
#$time = timegm($sec,$min,$hours,$mday,$mon,$year);

sub GetMonthTable { # $year, $month, \%fillDates ; return html table with links for dates in %fillDates
# dates in %fillDates should be in format 'yyyy-mm-dd' => integer
# example: '2022-10-07' => 1
# SUBSTR(DATETIME(add_timestamp, 'unixepoch', 'localtime'), 0, 11) AS date,
	my $year = shift;
	my $month = shift;
		
	my $fillDatesRef = shift;
	my %fillDates;
	if ($fillDatesRef) {
		%fillDates = %{$fillDatesRef};
	}

	#todo templatize
	
	my $emptyCell = '';
	my $html = '';

	my @months = qw(January February March April May June July August September October November December);
	my $daysInMonth = GetNumberOfDaysInMonth($year, $month);

	if (!$daysInMonth) {
		WriteLog('GetMonthTable: warning: $daysInMonth is FALSE; caller = ' . join(',', caller));
		return '';
	}

	my $dialogTitle = $months[$month-1] . ' ' . $year;
	
	$html .= "\n";

	my $time;
	my $timeString;

	$time = timelocal(1, 1, 1, 1, $month - 1, $year);
	my $firstDay = strftime('%w', localtime($time));


	my $epoch = time();
	my $curMonth = strftime('%m', localtime ($epoch));
	my $curDay = strftime('%d', localtime ($epoch));
	my $curYear = strftime('%Y', localtime ($epoch));

	my $curDate = "$curYear-$curMonth-$curYear";

	$html .= '<tr>';

	my $started = 0;

	my $dayTime;
	my $dayOfWeek;

	my $day;

	for ($day = 1; $day <= $daysInMonth; $day++) {
		$dayTime = timelocal(1, 1, 1, $day, $month-1, $year);
		$dayOfWeek = strftime('%w', localtime($dayTime));

		if (!$started) {
			# print day of week header and fill empty cells
			
			#$html .= '<tr>';
			#for my $dow (qw(Sun Mon Tue Wed Thu Fri Sat)) {
			#	$html .= '<td>' . $dow . '</td>';
			#}
			#$html .= '</tr>';
			
			$html .= '<tr>';
			while ($firstDay) {
				$firstDay--;
				$html .= '<td>' . $emptyCell . '</td>';
			}
			$started = 1;
		}

		if ($dayOfWeek == 0 && $day > 1) {
			$html .= '<tr>';
		}
		
		my $thisDate = '';
		$thisDate = $year . '-';
		if ($month > 9) {
			$thisDate .= $month . '-';
		} else {
			if (length($month) > 1) {
				$thisDate .= $month . '-';
			} else {
				$thisDate .= '0' . $month . '-';
			}
		}
		if ($day > 9) {
			$thisDate .= $day;
		} else {
			$thisDate .= '0' . $day;
		}
		
		if ($fillDates{$thisDate}) {
			my $numItems = $fillDates{$thisDate};
			my $indicator = '';
			
			if (0) {
				if ($numItems == 1) {
					$indicator = '.';
				}
				elsif ($numItems == 2) {
					$indicator = ':';
				}
				elsif ($numItems == 3) {
					$indicator = '.:';
				}
				elsif ($numItems >= 4) {
					$indicator = '::';
				}
			}
			
			$html .= '<td>';
			$html .= '<a href="/date/' . $thisDate .'.html">';
			$html .= '<div>';
			
			$html .= $indicator;
			$html .= $day;
			
			$html .= '</div>';
			$html .= '</a>';
			$html .= '</td>';
		} else {
			$html .= '<td>' . $day . '</td>';
		}

		if ($dayOfWeek == 6) {
			$html .= '</tr>';
		}
		$html .= "\n";
	}

	if ($dayOfWeek != 6) {
		while ((6 - $dayOfWeek) > 0) {
			$html .= '<td>' . $emptyCell . '</td>';
			$dayOfWeek++;
		}
		$html .= '</tr>';
	}

	#$time = timelocal(1, 1, 1, 1, $month-1, $year);
	#$timeString = scalar(localtime($time));
	#my @lastDayArray = split(' ', $timeString);
	#my $lastDay = $firstDayArray[0];

	$html .= '</tr>';

	my %windowTemplateParams;
	$windowTemplateParams{'body'} = $html;
	$windowTemplateParams{'title'} = $dialogTitle;
	$windowTemplateParams{'headings'} = 'Sun,Mon,Tue,Wed,Thu,Fri,Sat';
	$windowTemplateParams{'table_sort'} = 0;

	$html = GetDialogX2(\%windowTemplateParams);

	return $html;
} # GetMonthTable()

sub TestYear {
	my $year = shift;
	print "<h1>\n";
	print " $year \n";
	print "<h1>\n";
	
	my $fillDatesRef = shift;
	my %fillDates = {};
	if ($fillDatesRef) {
		%fillDates = %{$fillDatesRef};
	}

	my @months = qw(January February March April May June July August September October November December);

	for (my $month = 1; $month <= 12; $month++) {
		my $monthHtml = GetMonthTable($year, $month, \%fillDates);
		print $monthHtml;
	}
}

sub GetCalendarPage { # returns calendar page
	my $html = '';
	
	my $epoch = time();
	my $curMonth = strftime('%m', localtime ($epoch));
	my $curDay = strftime('%d', localtime ($epoch));
	my $curYear = strftime('%Y', localtime ($epoch));	
	
	$html .= GetPageHeader('calendar');
	$html .= GetTemplate('html/maincontent.template');

	my @dates = SqliteQueryHashRef('calendar_days');
	shift @dates;

	WriteLog('GetCalendarPage: scalar(@dates) = ' . scalar(@dates));

	if (scalar(@dates)) {
		my %fillDates;

		for my $fillDate (@dates) {
			my %dateHash = %{$fillDate};
			my $dateToAdd = $dateHash{'date'};
			$fillDates{$dateToAdd} = $dateHash{'item_count'};
		}

		#for (my $year = $yearStart; $year != $yearEnd; $year--) {
		#	TestYear($year, \%fillDates);
		#}

		#$html .= GetDialogX("$curYear $curMonth $curDay", 'As Of');

		my @yearMonths = SqliteQueryHashRef('calendar_months');
		shift @yearMonths;

		for my $yearMonthRef (@yearMonths) {
			my %yearMonthRow = %{$yearMonthRef};
			my $yearMonth = $yearMonthRow{'year_month'};
			if ($yearMonth) {
				my $year = substr($yearMonth, 0, 4);
				my $month = substr($yearMonth, 5, 2);
				$html .= GetMonthTable($year, $month, \%fillDates);
			} else {
				WriteLog('GetCalendarPage: warning: $yearMonth failed sanity check');
			}
		}

		if (0) {
			# this would display the next or previous month from current
			# if it is early or late in the current month
			if ($curDay < 7) {
				if ($curMonth == 1) {
					$html .= GetMonthTable($curYear - 1, 12, \%fillDates);
				} else {
					$html .= GetMonthTable($curYear, $curMonth - 1, \%fillDates);
				}
			}

			$html .= GetMonthTable($curYear, $curMonth, \%fillDates);

			if ($curDay > 21) {
				if ($curMonth == 12) {
					$html .= GetMonthTable($curYear + 1, 1, \%fillDates);
				} else {
					$html .= GetMonthTable($curYear, $curMonth + 1, \%fillDates);
				}
			}
		}
	} else {
		$html .= GetDialogX('<p>There is nothing in the calendar at this time.</p>', 'Calendar Empty');
	}

	$html .= '<hr>';
	$html .= GetQuerySqlDialog('calendar_months');
	$html .= GetQuerySqlDialog('calendar_days');

	$html .= GetPageFooter('calendar');
	
	$html = InjectJs($html, qw(settings voting timestamp utils profile));
	
	return $html;
} # GetCalendarPage()

1;
