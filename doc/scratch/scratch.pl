#item_page.pl

# REPLY CART
#if (GetConfig('setting/html/reply_cart')) {
#	require_once('dialog/reply_cart.pl');
#	$txtIndex .= GetReplyCartDialog(); # GetItemPage()
#}

#$threadListingDialog .= '<span class=advanced>' . $threadListingDialog . '</span>';



# $txtIndex .= '<hr>';

#WriteLog("GetItemIndexLog($file{'file_hash'}, 'gpg_stderr') abcdefghijklmnopqr");

#	my $scriptsInclude = '<script src="/openpgp.js"></script><script src="/crypto2.js"></script>';
#	$txtIndex =~ s/<\/body>/$scriptsInclude<\/body>/;



# REPLY FORM
#if (GetConfig('reply/enable')) {
#	$txtIndex .= GetReplyForm($file{'file_hash'});
#}

#
#		my $query = '';
#		if (ConfigKeyValid("query/template/related")) {
#			$query = SqliteGetQueryTemplate("related");
#			$query =~ s/\?/'$fileHash'/;
#			$query =~ s/\?/'$fileHash'/;
#			$query =~ s/\?/'$fileHash'/;
#		}
#
#		my @itemReplies = SqliteQueryHashRef($query);


#my @itemReplies = DBGetItemReplies($fileHash);


#
#			# VOTE  BUTTONS
#			# Vote buttons depend on reply functionality, so they are also in here
#			$voteButtons .=
#				GetItemLabelButtons($file{'file_hash'}) .
#				'<hr>' .
#				GetTagsListAsHtmlWithLinks($file{'labels_list'}) .
#				'<hr>' .
#				GetString('item_attribute/item_score') . $file{'item_score'}
#			;





#sub sha1_file {
#    my ($file) = @_;
#
#    open my $fh, '<', $file or die "Could not open file: $!";
#    binmode($fh);
#
#    my $sha1 = Digest::SHA->new(1); # 1 indicates SHA-1
#
#	my $data
#    while ($data; read $fh, $data, 8192) {
#        $sha1->add($data);
#    }
#
#    close $fh;
#
#    return $sha1->hexdigest;
#}


if ($file{'item_type'} eq 'txt') {
	# item label has firebase tag
	if ($file{'labels_list'} && index($file{'labels_list'}, 'firebase') != -1) {
		#my $imageUrl = trim(GetFile($file{'file_path'}));
		my $imageUrl = trim(DBGetItemAttribute($file{'file_hash'}, 'https'));
		$itemTemplateBody = '<img src="' . $imageUrl . '" width="200">'; #todo #fixme #hack
	}
	else {



		# add special token for firebase urls
					if (index($httpMatch, 'firebasestorage.googleapis.com') != -1) {
						DBAddLabel($fileHash, $addedTime, 'firebase');
						#DBAddLabel($fileHash, $addedTime, 'image');
					}



elsif (
	$fieldName eq 'chain_hash'
) {
	# chain hash, which should match file_hash
	#
	# not sure why this is handled differently from all the other hashes above,
	# BUT i think it because file_hash is used mainly in tabular listings,
	# where horizontal space is at a premium, while the above fields are
	# mainly used in vertical listings in item attributes dialog
	#
	# <tt> is not used here because it would add a lot to page weight
	# when there is a long list of results

	if ($fieldValue) {
		if ($itemRow{'file_hash'}) {
			if ($itemRow{'file_hash'} eq $fieldValue) {
				$fieldValue = '<tt><font color=green>' . substr($fieldValue, 0, 8) . '</font></tt>';
			}
			else {
				$fieldValue = '<tt><font color=red>' . substr($fieldValue, 0, 8) . '</font></tt>';
			}
		}
		else {
			$fieldValue = '<tt>' . substr($fieldValue, 0, 8) . '</tt>';
		}
	} else {
		$fieldValue = '';
	}
}



# from str_ireplace():


######## below is old code, not used
######## below is old code, not used
######## below is old code, not used
######## below is old code, not used
######## below is old code, not used

my $length = length($string);
my $target = length($replace_this);

my $loopCounter = 0;

for (my $i = 0; $i < $length - $target + 1; $i++) {
	if (lc(substr($string, $i, $target)) eq lc($replace_this)) {
		$string = substr ($string, 0, $i) . $with_this . substr($string, $i + $target);
		$i += length($with_this) - length($replace_this); # when new string contains old string
	}

	$loopCounter++;

	if ($loopCounter > 1000) {
		WriteLog('str_ireplace: warning: loop has reached 1000 iterations, stopping');
		last;
	}
}

WriteLog('str_ireplace: length($result) = ' . length($string));

return $string;



# from str_replace():
if (0) { #buggy code, not used
	my $length = length($string);
	my $target = length($replace_this);

	for (my $i = 0; $i < $length - $target + 1; $i++) {
		#todo there is a bug here
		if (!defined(substr($string, $i, $target))) {
			WriteLog("str_replace: warning: !defined(substr($string, $i, $target))");
		}
		elsif (substr($string, $i, $target) eq $replace_this) {
			$string = substr ($string, 0, $i) . $with_this . substr($string, $i + $target);
			$i += length($with_this) - length($replace_this); # when new string contains old string
			$length += length($with_this) - length($replace_this); # string is getting shorter or longer
		} else {
			# do nothing
		}
	}

	WriteLog('str_replace: length($string) = ' . length($string));

	return $string;
}

#	my $fingerprint = shift; # author's fingerprint
#	my $showPlain = shift; # 1 to display avatar without colors
#
#	require_once('widget/avatar.pl');
#
#	# sanitize $showPlain
#	if (!$showPlain) {
#		$showPlain = 0;
#	} else {
#		$showPlain = 1;
#	}
#
#	if (!$fingerprint) {
#		WriteLog('GetAuthorLink: warning: $fingerprint is missing; caller = ' . join(',', caller));
#		return '';
#	}
#
#	# verify $fingerprint is valid
#	if (!IsFingerprint($fingerprint)) {
#		WriteLog('GetAuthorLink: warning: sanity check failed on $fingerprint = ' . ($fingerprint ? $fingerprint : 'FALSE') . '; caller: ' . join(',', caller));
#		return 'Guest'; #guest...
#	}
#
#	my $authorUrl = "/author/$fingerprint/index.html";
#
#	my $authorAvatar = '';
#	if ($showPlain) {
#		$authorAvatar = GetAvatar($fingerprint);
#	} else {
#		$authorAvatar = GetAvatar($fingerprint);
#	}
#
#	my $authorLink = GetTemplate('html/authorlink.template');
#
#	{ # trim whitespace from avatar template
#		#this trims extra whitespace from avatar template
#		#otherwise there may be extra spaces in layout
#		#WriteLog('avdesp before:'.$avatar);
#		$authorLink =~ s/\>\s+/>/g;
#		$authorLink =~ s/\s+\</</g;
#		#WriteLog('avdesp after:'.$avatar);
#	}
#
#	$authorAvatar = trim($authorAvatar);
#
#	$authorLink =~ s/\$authorUrl/$authorUrl/g;
#	$authorLink =~ s/\$authorAvatar/$authorAvatar/g;
#
#	return $authorLink;



sub GetAvatar2 { # $authorKey
	WriteLog('GetAvatar2(...)');

	my $authorKey = shift;
	if (!$authorKey) {
		WriteLog('GetAvatar2: warning: $authorKey is FALSE, returning empty string; caller = ' . join(',', caller));
		return '';
	}
	chomp $authorKey;
	if ($authorKey = IsFingerprint($authorKey)) {
		# sanity check passed
	} else {
		WriteLog('GetAvatar2: warning: sanity check failed on $authorKey = ' . $authorKey . '; caller = ' . join(',', caller));
		return '';
	}

	my $template = GetTemplate('html/avatar.template');
	my $alias = GetAlias($authorKey);

	return $alias;
}


if (GetConfig('setting/html/item_image_double_click_to_like')) {
	# i think this should only be if there is no link on the image
	$imageContainer = AddAttributeToTag($imageContainer, 'a', 'ondblclick', 'alert(); return false;');
	$imageContainer = AddAttributeToTag($imageContainer, 'a', 'onclick', 'return false;');
}


	if (0 && GetConfig('debug')) {
		# used to generate a baseline of characters which can be in an sql query
		my $existingChars = GetFile('temp_sql.sh');
		for (my $i = 0; $i < length($shCommand); $i++) {
			my $thisChar = substr($shCommand, $i, 1);
			if (index($existingChars, $thisChar) == -1) {
				$existingChars .= $thisChar;
			}
		}
		PutCache('sqlite_encountered_characters', $existingChars);
	}


		";
		$keyList = GetQueryAsDialog($queryApprovedKeys, 'ApprovedKeys');
		#todo templatize the query, use parameter injection
		$keyListQuery = $queryApprovedKeys;




		if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
			if ($hashAnchor) {
				WriteLog('GetItemHtmlLink: $hashAnchor is TRUE; caller = ' . join(',', caller));
				$itemLink = AddAttributeToTag(
					$itemLink,
					'a ',
					'onclick',
					"
						//* if current page has a dialog with that id, then
						// use SpotlightDialog */
						if (document.getElementById('$linkCaption')) {
							/* SetActiveDialog(document.getElementById('$shortHash')); */
							SpotlightDialog('$linkCaption'));
							return false;
						}

						//* else
						// return true to allow the link to go to a new page */
						return true;


					"
				);
			}
			else {
				WriteLog('GetItemHtmlLink: $hashAnchor is FALSE; caller = ' . join(',', caller));
				#$itemLink = AddAttributeToTag($itemLink, 'a ', 'onclick', '');
				$itemLink = AddAttributeToTag(
					$itemLink,
					'a ',
					'onclick',
					"
						if (
							(!(window.GetPrefs) || GetPrefs('draggable_spawn')) &&
							(window.FetchDialogFromUrl) &&
							document.getElementById &&
							!this.getAttribute('new_page')
						) {
							if (document.getElementById('$shortHash')) {
								SetActiveDialog(document.getElementById('$shortHash'));
								return false;
							} else {
								return FetchDialogFromUrl('/dialog/$htmlFilename');
							}
						}
					"
				);
			}
		}




k
	if ($script eq 'dragging') {
		$scriptTemplate .= "\n" . GetTemplate("js/dragging_spotlight_dialog.js");
		#todo unhack
	}


sub GetAuthorPage {
#    my ($authorKey, $otherParams) = @_;
#
#    # Existing author-specific code
#
#    if (!IsFingerprint($authorKey)) {
#        WriteLog('GetAuthorPage called with invalid parameter');
#        return;
#    }
#
#    my $whereClause = "WHERE author_key = '$authorKey' AND item_score >= 0";
#
#    my $authorAliasHtml = GetAlias($authorKey);
#
#    #require_once('widget/avatar.pl');
#
#    my $authorAvatarHtml = GetAvatar($authorKey);
#
#    if (IsAdmin($authorKey)) {
#		$title = "Admin's Blog (Posts by or for $authorAliasHtml)";
#		$titleHtml = "Admin's Blog ($authorAvatarHtml)";
#	} else {
#		if (!$authorAliasHtml) {
#			WriteLog('GetAuthorPage: warning: $authorAliasHtml is FALSE, substituting Guest');
#			$authorAliasHtml = 'Guest';
#		}
#		$title = "Posts by or for $authorAliasHtml";
#		$titleHtml = "$authorAvatarHtml";
#	}
#
#	my %queryParams;
#
#	$queryParams{'where_clause'} = $whereClause;
#	$queryParams{'order_clause'} = 'ORDER BY add_timestamp DESC';
#
#	#todo fix hardcoded limit #todo pagination
#	$queryParams{'limit_clause'} = "LIMIT 100";
#
#	@files = DBGetItemList(\%queryParams); #used below in listing
#
#	if (GetConfig('setting/zip/author')) {
#		$zipName = "author/$authorKey.zip";
#		#todo move this somewhere else
#		if ($zipName) {
#			require_once('make_zip.pl');
#			my %zipOptions;
#			$zipOptions{'where_clause'} = "WHERE author_key = '$authorKey'";
#			my @zipFiles = DBGetItemList(\%zipOptions);
#			MakeZipFromItemList($zipName, \@zipFiles);
#		}
#	}
#
#	# Generate page
#
#	my $txtIndex = ""; # contains html output
#
#	# this will hold the title of the page
#
#	if (!$title) {
#		$title = GetConfig('html/home_title');
#	}
#
#	chomp $title;
#
#	$title = HtmlEscape($title);
#
#	my $htmlStart = '';
#
#	#require_once('get_page_header.pl');
#
#	#$htmlStart .= GetPageHeader('read_' . $pageType);

}








#
#	if (!$itemHash) {
#		WriteLog('AttachLogToItem: warning: $itemHash is false');
#		return;
#	}
#
#	if (!$logText) {
#		WriteLog('AttachLogToItem: warning: $logText is false');
#		return;
#	}
#
#	if (!IsItem($itemHash)) {
#		WriteLog('AttachLogToItem: warning: $itemHash failed sanity check');
#		return;
#	}
#
#	if ($logText =~ m/^([0-9a-zA-Z\.\-_\/\s]+)$/) {
#		$logText = $1;
#	} else {
#		WriteLog('AttachLogToItem: warning: $logText failed sanity check');
#		return;
#	}
#
#	my $logTextHash = GetFileHash($logText);
#
#	if (!$logTextHash) {
#		WriteLog('AttachLogToItem: warning: $logTextHash is false');
#		return;
#	}
#
#	if (!IsItem($logTextHash)) {
#		WriteLog('AttachLogToItem: warning: $logTextHash failed sanity check');
#		return;
#	}
#
#	my $logTextPath = GetPathFromHash($logTextHash);
#
#	if (!$logTextPath) {
#		WriteLog('AttachLogToItem: warning: $logTextPath is false');
#		return;
#	}
#
#	if (!-e $logTextPath) {
#		WriteLog('AttachLogToItem: warning: $logTextPath does not exist');
#		return;
#	}
#
#	my $logTextMessage = GetFile($logTextPath);
#
#	if (!$logTextMessage) {
#		WriteLog('AttachLogToItem: warning: $logTextMessage is false');
#		return;
#	}
#
#	my $itemMessage = GetItemDetokenedMessage($itemHash);
#
#	if (!$itemMessage) {
#		WriteLog('AttachLogToItem: warning: $itemMessage is false');
#		return;
#	}
#
#	$itemMessage .= "\n\n" . $logTextMessage;
#
#	my $itemMessageHash = GetFileHash($itemMessage);
#
#	if (!$itemMessageHash) {
#		WriteLog('AttachLogToItem: warning: $itemMessageHash is false');
#		return;
#	}
#
#	if (!IsItem($itemMessageHash)) {
#		WriteLog('AttachLogToItem: warning: $itemMessageHash failed sanity


###### ADD STUFF ABOVE HERE ######


sub WalkComments { # $fileHash, $currentStack ; walks up parent comments, combining the series of responses into one flat text file, with timestamps, separators between items, and user names
# sub ThreadSummaryUpwardsFromChildComment {
# takes a comment and walks up parent comments,
#combining the series of responses into one flat text file,
#with timestamps, separators between items, and user names
#recursively implemented

	my $fileHash = shift;
	my $currentStack = shift;

	if (!$fileHash) {
		WriteLog('WalkComments: warning: $fileHash is FALSE; caller = ' . join(',', caller));
		return '';
	}

	if (!$currentStack) {
		$currentStack = '';
	}

	if (!IsItem($fileHash)) {
		WriteLog('WalkComments: warning: $fileHash failed sanity check; caller = ' . join(',', caller));
		return '';
	}

	my $message = GetItemDetokenedMessage($fileHash);

	if (!$message) {
		WriteLog('WalkComments: warning: $message is FALSE; caller = ' . join(',', caller));
		return '';
	}

	$currentStack = $message . "\n---\n" . $currentStack;

	#my $parentHash = DBGetItemAttributeValue($fileHash, 'parent_hash');
	my $parentHash = SqliteGetValue("SELECT parent_hash FROM item WHERE hash = '$fileHash' LIMIT 1");

	if (!$parentHash) {
		WriteLog('WalkComments: warning: $parentHash is FALSE; caller = ' . join(',', caller));
		return $currentStack;
	} else {
		return WalkComments($parentHash, $currentStack);
	}
}




#for author_replies GetAuthorReplies:
	#if ($dialog) {
	#	$dialog = AddAttributeToTag($dialog, 'table', 'class', 'Inbox');
	#}




#sub RunPyItem {
## sub RunFile {
## sub RunPyFile {
## sub RunPythonFile {
#
#	my $item = shift;
#
#	WriteLog("RunPyItem($item)");
#
#	my $runLog = 'run_log/' . $item;
#
#	my $filePath = DBGetItemFilePath($item);
#	my $fileBinaryPath = $filePath;
#
#	if (-e $fileBinaryPath) {
#		if ($fileBinaryPath =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
#			$fileBinaryPath = $1;
#			`chmod +x $fileBinaryPath`;
#			my $runStart = time();
#			my $result = `$fileBinaryPath`;
#			my $runFinish = time();
#
#			DBAddItemAttribute($item, 'run_start', $runStart);
#			DBAddItemAttribute($item, 'run_finish', $runFinish);
#
#			PutCache($runLog, $result);
#			return 1;
#		} else {
#			WriteLog('RunPyItem: warning: $fileBinaryPath failed sanity check');
#			return '';
#		}
#	} else {
#		PutCache($runLog, 'error: run failed, file not found: ' . $fileBinaryPath);
#		return 1;
#	}
#} # RunPyItem()





	if ($address eq '/write.html' && GetConfig('setting/admin/js/translit')) {
		#todo make it more clear how to change this
		$address = '/frame.html';
	}

			if ($tagName eq 'todo') {
				$queryParams{'where_clause'} = $queryParams{'where_clause'} . " AND item_flat.labels_list NOT LIKE '%,done,%' ";
			}

	if ($pageType eq 'tag' && $pageParam eq 'todo') {
		# for todo items, list items that are todo+done at the bottom
		my $queryDone = "SELECT file_hash, item_title FROM item_flat WHERE labels_list LIKE '%,todo,%' AND labels_list LIKE '%,done,%'";
		$txtIndex .= GetQueryAsDialog($queryDone, 'Completed');
	}



	WriteLog('DBGetItemList: scalar(@resultsArray) = ' . scalar(@resultsArray));






sub DBGetItemTitle { # $itemHash ; get title for item
	my $itemHash = shift;

	if (!$itemHash || !IsItem($itemHash)) {
		WriteLog('DBGetItemTitle: warning: $itemHash failed sanity check; caller = ' . join(',', caller));
		return '';
	}

	WriteLog('DBGetItemTitle(' . $itemHash . '); caller = ' . join(',', caller));

	#my $query = 'SELECT title FROM item_title WHERE file_hash = ?';
	my @queryParams = ();
	#push @queryParams, $itemHash;

	my $query = 'SELECT title FROM item_title WHERE file_hash LIKE \'' . $itemHash . '%\' LIMIT 1';
	#todo improve this query

	#my $itemTitle = SqliteGetValue($query, @queryParams);
	my $resultRef = SqliteQueryDBH($query, @queryParams);

	if ($resultRef) {
		my @result = @{$resultRef};
		shift @result;
		my $firstRowRef = shift @result;
		if ($firstRowRef) {
			my %firstRow = %{$firstRowRef};
			my $itemTitle = $firstRow{'title'};
			#todo SqliteGetValueDBH()

			if ($itemTitle) {
				my $maxLength = shift;
				if ($maxLength) {
					if ($maxLength > 0 && $maxLength < 255) {
						#todo sanity check failed message
						if (length($itemTitle) > $maxLength) {
							$itemTitle = TrimUnicodeString($itemTitle, $maxLength);
							# $itemTitle = substr($itemTitle, 0, $maxLength) . '...';
						}
					}
				}

				return $itemTitle;
			} else {
				return '';
			}
		} else {
			#todo handle this
		}
	} else {
		#todo handle this
	}
} # DBGetItemTitle()



sub GetAuthorPendingKeysDialog {
	my $authorKey = shift;

	if (!IsFingerprint($authorKey)) {
		WriteLog('GetAuthorPendingKeysDialog: warning: $authorKey failed sanity check; caller = ' . join(',', caller));
		return '';
	}

	WriteLog('GetAuthorPendingKeysDialog(' . $authorKey . '); caller = ' . join(',', caller));

	my $dialogTitle = 'Keys Pending Approval';

	my @queryParams;
	push @queryParams, $authorKey;

	my $authorPendingKeysQuery = SqliteGetNormalizedQueryString('author_pending_keys', @queryParams);

	require_once('dialog/query_as_dialog.pl');

	my %dialogFlags;
	$dialogFlags{'no_no_results'} = 1;

	my $dialog = GetQueryAsDialog($authorPendingKeysQuery, $dialogTitle, '', \%dialogFlags);

	WriteLog('GetAuthorPendingKeysDialog: $dialog is ' . ($dialog ? 'TRUE' : 'FALSE'));

	return $dialog;
} # GetAuthorPendingKeysDialog()




		if (1) {
			# list all other authors with the same alias

			# get query from template and replace ? with authorKey
			my $queryAuthorThreads =
				"SELECT
                 	author_key author_id,
                 	author_seen,
                 	item_count,
                 	author_score
                 FROM
                 	author_flat
                 WHERE
                 	author_key IN (
                 		SELECT author_key
                 		FROM author_flat WHERE author_key = ?
                 	)
                 	AND author_key NOT IN (?)"; #todo template it in template/query
			#todo properly template the parameters
			$queryAuthorThreads = str_replace('?', "'$authorKey'", $queryAuthorThreads);
			$queryAuthorThreads = str_replace('?', "'$authorKey'", $queryAuthorThreads);
			my $sameAliasDialog = GetQueryAsDialog(
				$queryAuthorThreads,
				'Other Authors with Alias ' . GetAlias($authorKey),
				'',
				\%queryFlags
			);
			$txtIndex .= $sameAliasDialog;
		}




		if (1) {
			# list all other authors with the same alias

			# get query from template and replace ? with authorKey
			my $queryAuthorThreads =
				"SELECT
                 	author_key author_id,
                 	author_seen,
                 	item_count,
                 	author_score,
                    (author_key = ?) AS this_row
                 FROM
                 	author_flat
                 WHERE
                 	author_key IN (
                 		SELECT author_key
                 		FROM author_flat WHERE author_key = ?
                 	)
                ";
			#todo properly template the parameters
			$queryAuthorThreads = str_replace('?', "'$authorKey'", $queryAuthorThreads);
			$queryAuthorThreads = str_replace('?', "'$authorKey'", $queryAuthorThreads);

			WriteLog('queryAuthorThreads: ' . $queryAuthorThreads);

			my %queryFlags;
			my $sameAliasDialog = GetQueryAsDialog(
				$queryAuthorThreads,
				'Related Authors',
				#'Other Authors with Alias ' . GetAlias($authorKey),
				'',
				\%queryFlags
			);
			$txtIndex .= $sameAliasDialog;
		}





			#my $normalizedHash = sha1_hex(trim($detokenedMessage));
			#v1
			#
			# {#v2
			# 	my $hash = sha1_hex('');
			# 	#draft better normalized hash
			# 	my @lines = split("\n", $detokenedMessage);
			# 	my @lines2;
			# 	for my $line (@lines) {
			# 		$line = trim($line);
			# 		if ($line ne '') {
			# 			push @lines2, lc($line);
			# 		}
			# 	}
			# 	my @lines3 = uniq(sort(@lines2));
			# 	for my $line (@lines3) {
			# 		$hash = sha1_hex($hash . $line);
			# 	}
			# 	$normalizedHash = $hash;
			# }


#====


#!/usr/bin/perl -T
#freebsd: #!/usr/local/bin/perl -T
#
# utils.pl BEGIN
# utilities which haven't found their own file yet
# typically used by another file
# performs basic state validation whenever run
#


$ENV{PATH}="/bin:/usr/bin"; #this is needed for -T to work
#gitbash: $ENV{PATH}="/bin:/usr/bin:/mingw64/bin"; #this is needed for -T to work
# /mingw64/bin is default location for gitbash on windows

#freebsd: $ENV{PATH}="/bin:/usr/bin:/usr/local/bin"; #this is needed for -T to work

use strict;
use warnings;
use utf8;
use 5.010;

use lib qw(lib); #needed for when we use included libs, such as on dreamhost
use POSIX 'strftime';
use Data::Dumper;
use Cwd qw(cwd);
use Digest::MD5 qw( md5_hex );
use File::Basename qw( fileparse );
use URI::Encode qw( uri_decode uri_encode );
use URI::Escape;
use Storable;
use Digest::SHA qw( sha1_hex );
use File::Spec qw( abs2rel );
use Time::HiRes qw(time);
use POSIX qw(strftime);

sub trim { # trims whitespace from beginning and end of $string
	my $s = shift;

	if (defined($s)) {
		$s =~ s/\s+$//g;
		$s =~ s/^\s+//g;
		return $s;
	}

	return;
} # trim()

require('./config/template/perl/config.pl');
# config.pl is required for looking up the paths using require_once()

#todo these may not need to be included for every load of utils.pl?
my @modules = qw(
	string
	cache
	html
	file
	sqlite
	gpgpg
	makepage
	token_defs
	page/calendar
	render_field
	resultset_as_dialog
	item_page
	format_message
	item_template
	widget
	index_text_file
);
# 	compare_page

for my $module (@modules) {
	require_once("$module.pl");
} # for my $module (@modules)

sub ensure_module { # $path ; ensures module is available under config/
# sub EnsureModule {
# the reason it is not EnsureModule() is to match reuquire_once(),
# which is styled after PHP's function of the same name
	my $module = shift;
	chomp $module;

	if (!$module) {
		WriteLog('ensure_module: warning: module was FALSE, returning; caller = ' . join(',', caller));
		return 0;
	}

	WriteLog('ensure_module(' . $module . ')');

	my $path = GetDir('config') . '/template/perl/' . $module;
	my $localPath = './' . $module;
	my $moduleContent = GetTemplate("perl/$module");

	WriteLog('ensure_module: $path = ' . $path);

	if (!-e $path) {
		WriteLog('ensure_module: -e $path was TRUE');
		if ($moduleContent) {
			my $templatePath = "template/perl/$path";
			WriteLog('ensure_module: writing $moduleContent to $path = ' . $templatePath . '; caller = ' . join(',', caller));
			PutConfig($templatePath, $moduleContent);
			return 1;
		} else {
			WriteLog('ensure_module: warning: $moduleContent is FALSE; caller = ' . join(',', caller));
			return 0;
		}
	} else {
		WriteLog('ensure_module: -e $path was FALSE');
	}

	if (!-e $localPath) {
		# PutFile($localPath, $moduleContent);
	}

	if (!$path || !-e $path) {
		WriteLog('ensure_module: warning sanity check failed');
		return 0;
	}
} # ensure_module()

sub require_once { # $path ; use require() unless already done
# sub RequireOnce {
# styled after PHP's require_once()
	my $module = shift;
	chomp $module;

	if (!$module) {
		WriteLog('require_once: warning sanity check failed; $module is FALSE; caller = ' . join(',', caller));
		return 0;
	}

	if ($module =~ m/^([a-zA-Z0-9_\/\\]+\.pl)$/) {
		# sanity check passed
		$module = $1;
	} else {
		WriteLog('require_once: warning: sanity check failed; $module = ' . $module);
		return '';
	}

	WriteLog('require_once(' . $module . ')');

	my $path = GetDir('config') . '/template/perl/' . $module;

	#todo my $path = GetTemplateFilePath("perl/$module");

	#todo state?

	ensure_module($module); # this ensures module is copied to config

	state %state;
	if (defined($state{$module})) {
		WriteLog('require_once: already required: ' . $module);
		return 0;
	}

	# sanity check $path
	# path should be restricted to typical path characters
	# and should not contain any '..' or other path traversal characters
	# if ($path =~ m/^(.+)$/) { #gitbash on windows doesn't work with below yet
	if ($path =~ m/[^a-zA-Z0-9_\/\.]/) {
		WriteLog('require_once: sanity check on $path passed, $path = ' . $path);
		$path = $1;
	} else {
		WriteLog('require_once: warning: sanity check failed on $path; $caller = ' . join(',', caller));
		WriteLog('require_once: warning: $path = ' . $path);
		return '';
	}

	if (-e $path) {
		require $path;
		$state{$module} = 1;
		return 1;
	} else {
		WriteLog('require_once: warning: not found: $path = ' . $path . '; caller = ' . join(',', caller));
	}
} # require_once()

sub EscapeShellChars { # $string ; escapes string for including as parameter in shell command
	#todo #security this is still probably not safe and should be improved upon #security

	my $string = shift;
	chomp $string;

	$string =~ s/([\"|\$`\\])/\\$1/g;
	# chars are: " | $ ` \

	return $string;
} # EscapeShellChars()

sub GetDir { # $dirName ; returns path to special directory specified
# 'html' = html root
# 'script'
# 'txt'
# 'image'
# 'php'
# 'cache'
# 'config'
# 'default'
# 'log'

	my $dirName = shift;
	if (!$dirName) {
		WriteLog('GetDir: warning: $dirName missing');
		return '';
	}
	WriteLog('GetDir: $dirName = ' . $dirName);

	#my $scriptDir = cwd();
	#my $scriptDir = `pwd`;
	#$scriptDir = trim($scriptDir);

	state $scriptDir = trim(`pwd`); #todo replace this?

	if ($scriptDir =~ m/^([\.0-9a-zA-Z_\/]+)$/) {
		$scriptDir = $1;
		WriteLog('GetDir: $scriptDir sanity check passed');
	} else {
		WriteLog('GetDir: warning: sanity check failed on $scriptDir');
		return '';
	}
	WriteLog('GetDir: $scriptDir = ' . $scriptDir);

	if ($dirName eq 'script') {
		WriteLog('GetDir: return ' . $scriptDir);
		return $scriptDir;
	}

	if ($dirName eq 'html') {
		WriteLog('GetDir: return ' . $scriptDir . '/html');
		return $scriptDir . '/html';
	}

	if ($dirName eq 'php') {
		WriteLog('GetDir: return ' . $scriptDir . '/html');
		return $scriptDir . '/html';
	}

	if ($dirName eq 'txt') {
		WriteLog('GetDir: return ' . $scriptDir . '/html/txt');
		return $scriptDir . '/html/txt';
	}

	if ($dirName eq 'image') {
		WriteLog('GetDir: return ' . $scriptDir . '/html/image');
		return $scriptDir . '/html/image';
	}

	if ($dirName eq 'cache') {
		WriteLog('GetDir: return ' . $scriptDir . '/cache');
		return $scriptDir . '/cache';
	}

	if ($dirName eq 'config') {
		WriteLog('GetDir: return ' . $scriptDir . '/config');
		return $scriptDir . '/config';
	}

	if ($dirName eq 'default') {
		WriteLog('GetDir: return ' . $scriptDir . '/default');
		return $scriptDir . '/default';
	}

	if ($dirName eq 'log') {
		WriteLog('GetDir: return ' . $scriptDir . '/log');
		return $scriptDir . '/log';
	}

	WriteLog('GetDir: warning: fallthrough on $dirName = ' . $dirName);
	#todo WriteLog('GetDir: warning: fallthrough on $dirName = ' . $dirName . '; caller = ' . join(',', caller));
	return '';
} # GetDir()

#my $SCRIPTDIR = GetDir('script');
my $SCRIPTDIR = cwd();
if (!$SCRIPTDIR) {
	die ('Sanity check failed: $SCRIPTDIR is false!');
} # (!$SCRIPTDIR)

#my $SCRIPTDIR = cwd();
#if (!$SCRIPTDIR) {
#	die ('Sanity check failed: $SCRIPTDIR is false!');
#} # (!$SCRIPTDIR)


#my $HTMLDIR = $SCRIPTDIR . '/html';
#my $TXTDIR = $HTMLDIR . '/txt';
#my $IMAGEDIR = $HTMLDIR . '/txt';

sub WriteLog { # $text; Writes timestamped message to console (stdout) AND log/log.log
	my $text = shift;
	if (!$text) {
		$text = '(empty string)';
	}
	chomp $text;

	my $callerInfo = join(',', ((caller 1)[3]));
	$callerInfo = (split('::', $callerInfo))[1];

	if ($text && $callerInfo && (substr($text, 0, length($callerInfo)) ne $callerInfo)) {
		$text = $callerInfo . ': ' . $text;
	}

	if ($text && index(lc($text), 'warning') != -1) {
		if (index(lc($text), 'caller') == -1 && caller(1)) {
			#$text .= '; caller = ' . join(',', caller(1));
			#todo
		}
	}

	# Only if debug mode is enabled
	state $debugOn;
	#todo state $debugOn = -e 'config/debug'; #todo this path should not be hardcoded?
	my $timestamp = '';

	#todo if ($debugOn) {
	if ($debugOn || -e 'config/debug') {
		$timestamp = GetTime(); # set timestamp

		# adjust timestamp formatating to always have the same number
		# of digits after the decimal point, if included
		if ($timestamp =~ m/^[0-9]+\.[0-9]{1}$/) {
			$timestamp .= '0';
		}
		if ($timestamp =~ m/^[0-9]+\.[0-9]{2}$/) {
			$timestamp .= '0';
		}
		if ($timestamp =~ m/^[0-9]+\.[0-9]{3}$/) {
			$timestamp .= '0';
		}
		if ($timestamp =~ m/^[0-9]+\.[0-9]{4}$/) {
			$timestamp .= '0';
		}

		if (0) { # debug use milliseconds #featureflag
			#deprecated feature which gets differently formatted timestamp
			my $t = time;
			my $date = $timestamp;#strftime "%Y%m%d %H:%M:%S", localtime $t;
			$date .= sprintf ".%03d", ($t-int($t))*1000; # without rounding
			$timestamp = $date;
		}

		#AppendFile("log/log.log", $timestamp . " " . $text); # (happens later)
		$debugOn = 1; #verbose #quiet mode #quietmode #featureflag
	}

	my $charPrefix = '';

	if ($debugOn) { # this is the part which prints the snow #snow
		my $firstWord = substr($text, 0, index($text, ' '));
		if (index($firstWord, '(') != -1) {
			$firstWord = substr($firstWord, 0, index($firstWord, '('));
		}
		if (index($firstWord, ':') != -1) {
			$firstWord = substr($firstWord, 0, index($firstWord, ':'));
		}
		if ($firstWord ne 'WriteMessage') {
			# add one character to the snow

			my $firstWordHash = md5_hex($firstWord);
			my $firstWordHashFirstChar = substr($firstWordHash, 0, 1);
			$firstWordHashFirstChar =~ tr/0123456789abcdef/.;]\-,<">'+[:`_|+/; #brainfuckXL
			#todo use 2 characters of the hash, convert to 1 out of 64 characters

			WriteMessage($firstWordHashFirstChar); #todo make config/

			# FOR DEBUGGING PURPOSES
			#		print('$firstWord = ' . $firstWord . "\n");
			#		print('$firstWordHash = ' . $firstWordHash . "\n");
			#		print('$firstWordHashFirstChar = ' . $firstWordHashFirstChar . "\n");
			#		print("\n");

			if (!$firstWordHashFirstChar && !($firstWordHashFirstChar == 0)) {
				$firstWordHashFirstChar = '?';
			}

			$charPrefix = $firstWordHashFirstChar;
		} # if ($firstWord ne 'WriteMessage')
	} # if ($debugOn)

	if ($debugOn) {
		if ($charPrefix eq '') {
			$charPrefix = '$';
		}
		if (1) {
			#fully verbose
			AppendFile("log/log.log", $timestamp . " " . $charPrefix . " " . $text);
		} else {
			#only print first line
			$text = trim($text);
			if (index($text, "\n") != -1) {
				$text = substr($text, 0, index($text, "\n"));
			}
			if (length($text) >= 60) {
				#$text = substr($text, 0, 80);
			}
			AppendFile("log/log.log", $timestamp . " " . $charPrefix . " " . $text);
		}
	} # if ($debugOn)
} # WriteLog()

sub WriteMessage { # Writes timestamped message to console (stdout)
	#todo fix WriteLog('WriteMessage: caller = ' . join(',', caller));

	my $timestamp = GetTime();
	my $text = shift;

	if ($timestamp =~ m/^[0-9]+\.[0-9]{1}$/) {
		$timestamp .= '0';
	}
	if ($timestamp =~ m/^[0-9]+\.[0-9]{2}$/) {
		$timestamp .= '0';
	}
	if ($timestamp =~ m/^[0-9]+\.[0-9]{3}$/) {
		$timestamp .= '0';
	}
	if ($timestamp =~ m/^[0-9]+\.[0-9]{4}$/) {
		$timestamp .= '0';
	}

	if (!$text) {
		print('WriteMessage: warning: $text is false; caller = ' . join(',', caller) . "\n");
		return '';
	}

	chomp $text;
	state $previousText = '';

	state $snowPrinted;
	state $snowPrintedBefore = 0;

	if ($text eq '.' || length($text) == 1) {
		$previousText = $text;

		state @chars;
		if (!@chars) {
			#@chars = qw(, . - ' `); # may generate warning
			#@chars = (',', '.', '-', "'", '`');
			#@chars = ('.', ',');
			#@chars = (qw(0 1 2 3 4 5 6 7 8 9 A B C D E F));
		}

		#my @chars=('a'..'f','0'..'9');
		#print $chars[rand @chars];

		#print "\b";
		print $text;
		# my $randomString;
		# foreach (1..40) {
		# 	$randomString.=$chars[rand @chars];
		# }
		# return $randomString;

		if (!$snowPrinted) {
			$snowPrinted = $text;
		} else {
			$snowPrinted .= $text;
		}

		if (!$snowPrintedBefore || length($snowPrinted) >= 60) {
			## this starts a new line in the snow
			## this is NOT the part that prints a text message
			print "\n$timestamp ";
			WriteLog('WriteMessage: ' . $snowPrinted);
			$snowPrinted = '';
			$snowPrintedBefore = 1;
		}

		return;
	}
	if ($snowPrinted) {
		#WriteLog($snowPrinted);
	}
	$snowPrinted = '';

	# just an idea
	# doesn't seem to work well because the console freezes up if there's no \n coming
	# if ($text =~ m/^[0-9]+$/) {
	# 	$previousText = $text;
	# 	print $text . " ";
	# 	return;
	# }

	#WriteLog('WriteMessage: ' . $timestamp . ' ' . $text);

	WriteLog('WriteMessage: ' . $timestamp . ' ' . $text);

	my $output = "$text";
	if (0 && length($output) > 60) {
		$output = substr($output, 0, 60) . '...';
	}

#todo
#	print("\n");
#	print($timestamp);
#	print($output);
#
#	print("\n");
#	print($timestamp);
#	print(" =======================================================");
#
#	print("\n");
#	print($timestamp);
#	print(" ");

	# THIS is the part that prints the message
	# this code is not approved for public viewing
	#todo print "\n================================================================================\n";
	print "\n$timestamp $output\n$timestamp =======================================================\n$timestamp ";

	$previousText = $text;
} # WriteMessage()

sub MakePath { # $newPath ; ensures all subdirs for path exist
	my $newPath = shift;
	chomp $newPath;

	if (! $newPath) {
		#todo WriteLog('MakePath: warning: failed sanity check, $newPath missing; caller = ' . join(',', caller));
		WriteLog('MakePath: warning: failed sanity check, $newPath missing');
		return '';
	}

	if (-e $newPath) {
		WriteLog('MakePath: path already exists, returning');
		#todo WriteLog('MakePath: path already exists, returning; caller = ' . join(',', caller));
		return '';
	}

	if (! $newPath =~ m/^[0-9a-zA-Z\/]+$/) {
		#todo WriteLog('MakePath: warning: failed sanity check; caller = ' . join(',', caller));
		WriteLog('MakePath: warning: failed sanity check');
		return '';
	}

	WriteLog("MakePath($newPath)");

	my @newPathArray = split('/', $newPath);
	my $newPathCreated = '';

	while (@newPathArray) {
		$newPathCreated .= shift @newPathArray;
		if ($newPathCreated && !-e $newPathCreated) {
			WriteLog('MakePath: mkdir ' . $newPathCreated);
			mkdir $newPathCreated;
		}
		if (1 || $newPathCreated) { #todo
			$newPathCreated .= '/';
		}
	}
} # MakePath()

sub EnsureSubdirs { # $fullPath ; ensures that subdirectories for a file exist
	# takes file's path as argument
	# returns 0 for failure, 1 for success
	my $fullPath = shift;
	chomp $fullPath;

	state $scriptDir = GetDir('script');

	if (
		substr($fullPath, 0, 1) eq '/' &&
		substr($fullPath, 0, length($scriptDir)) ne $scriptDir
	) {
		WriteLog('EnsureSubdirs: warning: $fullPath begins with / AND does not begin with $scriptDir = ' . $scriptDir);
		#todo WriteLog('EnsureSubdirs: warning: $fullPath begins with / AND does not begin with $scriptDir = ' . $scriptDir . '; caller = ' . join(',', caller));
	}

	if (index($fullPath, '..') != -1 ) {
		WriteLog('EnsureSubdirs: warning: $fullPath contains .. ' . $fullPath);
		#todo WriteLog('EnsureSubdirs: warning: $fullPath contains .. ' . $fullPath . '; ' . join(',', caller));
	}

	WriteLog("EnsureSubdirs($fullPath)");

	#todo remove requirement of external module
	my ( $file, $dirs ) = fileparse $fullPath;

	if ( !$file ) {
		WriteLog('EnsureSubdirs: warning: $file was not set; $file = ' . $file . '; caller = ' . join(',', caller));
		#return 0;
		#this return is commented out because sometimes we want to ensure a subdir without a file
		#this is done from GetConfig() when inflating javascript library templates

		#$fullPath = File::Spec->catfile($fullPath, $file);
	}

	if ( !-d $dirs && !-e $dirs ) {
		if ( $dirs =~ m/^([^\s]+)$/ ) { #security #taint
			$dirs = $1; #untaint
			MakePath($dirs);
			return 1;
		} else {
			WriteLog('EnsureSubdirs: warning: $dirs failed sanity check, returning');
			return 0;
		}
	}
} # EnsureSubdirs()

sub TrimUnicodeString { # $string, $maxLength ; trims string to $maxLength in a unicode-friendly way
# sub SubstrUnicode {
# sub UnicodeSubstr {
# sub TrimTitle {
# sub trim {
# sub substr {
# this subprocedure is meant to address the issue with substr() cutting unicode characters apart
	my $string = shift;
	my $maxLength = shift;

	#todo sanity

	# code below tries to account for environments where Unicode::String is missing
	# it falls back on regular substr(), which has the downside of sometimes cutting
	# unicode characters in half. this can probably be detected and remedied, but I don't know how yet
	eval(
		'require Unicode::String qw(utf8);'
	);
	if (exists(&{'utf8'})) {
		my $us = utf8($string);
		my $stringLength = $us->length;
		WriteLog('TrimUnicodeString: $string = ' . $string . '; $stringLength = ' . $stringLength);

		if ($stringLength > $maxLength) {
			my $stringNew = $us->substr(0, $maxLength) . '...';
			WriteLog('TrimUnicodeString: $stringNew = ' . $stringNew);

			return $stringNew;
		} else {
			WriteLog('TrimUnicodeString: not trimming');
		}
	} else {
		my $stringLength = length($string);
		if ($stringLength > $maxLength) {
			my $stringNew = substr($string, 0, $maxLength);
			WriteLog('TrimUnicodeString: fallback mode: $stringNew = ' . $stringNew);
			return $stringNew;
		} else {
			WriteLog('TrimUnicodeString: fallback mode: not trimming');
		}
	}

	return $string;
} # TrimUnicodeString()

sub GetMyVersion { # Get the currently checked out version (current commit's hash from git)
# sub GetVersion {

	state $gitExists = !!`which git 2>/dev/null`;

	if ($gitExists) {
		# ok
	} else {
		return '7dc8eb9d3b1573755aec2f5c5e2af0ea10082f02';
	}

	state $myVersion;
	my $ignoreSaved = shift;

	if (!$ignoreSaved && $myVersion) {
		# if we already looked it up once, return that
		return $myVersion;
	}

	$myVersion = `git rev-parse HEAD`;
	#todo windows gitbash doesn't like this, even though `which git` works
	#

	#freebsd: $myVersion = `/usr/local/bin/git rev-parse HEAD`;
	if (!$myVersion) {
		WriteLog('GetMyVersion: warning: sanity check failed, returning default');
		$myVersion = sha1_hex('hello, world!');
	}
	chomp($myVersion);
	return $myVersion;
} # GetMyVersion()

sub GetFileHash { # $fileName ; returns hash of file contents
# sub GetItemHash {
# sub GetHash {
	WriteLog("GetFileHash()");

	my $fileName = shift;

	if (!$fileName) {
		WriteLog('GetFileHash: warning: $fileName is FALSE; caller = ' . join(',', caller));
		return '';
	}

	chomp $fileName;
	WriteLog("GetFileHash($fileName)");
	#todo normalize path (static vs full)
	state %memoFileHash;
	if ($memoFileHash{$fileName}) {
		WriteLog('GetFileHash: memo hit ' . $memoFileHash{$fileName});
		return $memoFileHash{$fileName};
	}
	WriteLog('GetFileHash: memo miss for $fileName = ' . $fileName);

	if (-e $fileName) {
		my $fileContent = GetFile($fileName);
		# if (!utf8::is_utf8($fileContent)) {
		# 	$fileContent = Encode::encode_utf8($fileContent);
		# }
		# $memoFileHash{$fileName} = sha1_hex(GetFile($fileName));
		# $memoFileHash{$fileName} = sha1_hex(Encode::encode_utf8($fileContent));
		$memoFileHash{$fileName} = GetSHA1(GetFile($fileName));
		return $memoFileHash{$fileName};
	} else {
		return '';
	}

	return '';
} # GetFileHash()

sub GetSHA1 {
	my $string = shift;
	my $hash = sha1_hex(Encode::encode_utf8($string));
	return $hash;
} # GetSHA1()

sub GetMD5 {
	my $string = shift;
	my $hash = md5_hex(Encode::encode_utf8($string));
	return $hash;
} # GetMD5()

sub GetFileMessageHash { # $fileName ; returns hash of file contents
# sub GetItemHash {
# sub GetHash {
# sub GetMessageHash {
# tries to hash the text rather than the exact bytes
# meaning that similar messages with minor differences would get the same hash

	my $fileName = shift;
	if (!$fileName) {
		WriteLog('GetFileMessageHash: warning: $fileName is FALSE; caller = ' . join(',', caller));
		return '';
	}

	chomp $fileName;
	WriteLog("GetFileMessageHash($fileName)");

	my $memoPath = GetAbsolutePath($fileName);

	state %memoFileHash;
	if ($memoFileHash{$memoPath}) {
		WriteLog('GetFileMessageHash: memo hit on $fileName = ' . $fileName);
		WriteLog('GetFileMessageHash: returning ' . $memoFileHash{$fileName});
		return $memoFileHash{$fileName};
	}
	WriteLog('GetFileMessageHash: memo miss for $fileName = ' . $fileName);

	if (-e $fileName) {
		if ((lc(substr($fileName, length($fileName) - 4, 4)) eq '.txt')) {
			my $fileContent = GetFile($fileName);
			WriteLog('GetFileMessageHash: text file detected; length = ' . length($fileContent));
			while (index($fileContent, "\n-- \n") > -1) { #\n--
				# exclude footer content from hashing
				$fileContent = substr($fileContent, 0, index($fileContent, "\n-- \n")); #\n--
			}
			$fileContent = trim($fileContent);
			WriteLog('GetFileMessageHash: length after removing signature and trim = ' . length($fileContent));
			WriteLog('GetFileMessageHash: $fileContent = ' . $fileContent);
			# $memoFileHash{$fileName} = sha1_hex($fileContent);
			$memoFileHash{$fileName} = GetSHA1($fileContent);
			WriteLog('GetFileMessageHash: returning ' . $memoFileHash{$fileName});
			return $memoFileHash{$fileName};
		} else {
			$memoFileHash{$fileName} = sha1_hex(GetFile($fileName));
			return $memoFileHash{$fileName};
		}
	} else {
		return '';
	}

	WriteLog('GetFileMessageHash: warning: unreachable reached');
	return '';
} # GetFileMessageHash()

sub GetRandomHash { # returns a random sha1-looking hash, lowercase
	my @chars=('a'..'f','0'..'9');
	my $randomString;
	foreach (1..40) {
		$randomString .= $chars[rand @chars];
	}
	return $randomString;
} # GetRandomHash()

sub GetTemplateFilePath { # $templateName, like 'perl/dialog/write.pl'
# sub GetTemplatePath {
	#todo
	#simple way:
	# check for each theme's config
	# if not, look in top config
	# if not ??
	my $template = shift;
	chomp $template;
	#todo sanity checks

	#todo this should also look in default?

	WriteLog("GetTemplateFilePath($template)");

	my $CONFIG = GetDir('config');

	my @activeThemes = GetActiveThemes();
	for my $theme (@activeThemes) {
		if (file_exists("$CONFIG/theme/$theme/template/$template")) {
			WriteLog('GetTemplateFilePath: returning ' . "$CONFIG/theme/$theme/template/$template");
			return "$CONFIG/theme/$theme/template/$template";
		}
	}
	if (file_exists("$CONFIG/template/$template")) {
		#todo should use GetDir('template')
		WriteLog('GetTemplateFilePath: returning ' . "$CONFIG/template/$template");
		return "$CONFIG/template/$template";
	}

	WriteLog('GetTemplateFilePath: warning: fallthrough for $template = ' . $template);
	return '';

} # GetTemplateFilePath()

sub GetTemplate { # $templateName ; returns specified template from template directory
# returns empty string if template not found
# here is how the template file is chosen:
# 1. template's existence is checked in config/template/ or default/template/
#    a. if it is found, it is THEN looked up in the config/theme/template/ and default/theme/template/
#    b. if it is not found in the theme directory, then it is looked up in config/template/, and then default/template/
# this allows themes to override existing templates, but not create new ones
#
	my $filename = shift;
	chomp $filename;
	#	$filename = "$SCRIPTDIR/template/$filename";

	my $isHtmlTemplate = 0;
	if ($filename =~ m/^html/) {
		$isHtmlTemplate = 1;
	}

	state $CONFIGDIR = GetDir('config');
	state $DEFAULTDIR = GetDir('default');

	WriteLog("GetTemplate($filename) caller: " . join(', ', caller));
	state %templateMemo; #stores local memo cache of template
	if ($templateMemo{$filename}) {
		#if already been looked up, return memo version
		WriteLog('GetTemplate: returning from memo for ' . $filename);
		if (trim($templateMemo{$filename}) eq '') {
			WriteLog('GetTemplate: warning: returning empty string for ' . $filename);
		}
		return $templateMemo{$filename};
	}

	if (!-e ($CONFIGDIR . '/template/' . $filename) && !-e ($DEFAULTDIR . '/template/' . $filename)) {
		#todo this should not fail if there is a template in the current theme
		#shim for rename
		if (-e ($CONFIGDIR . '/html/' . $filename) || -e ($DEFAULTDIR . '/html/' . $filename)) {
			WriteLog('GetTemplate: warning: template reference needs to be prepended with html: ' . $filename);
			return GetTemplate('html/' . $filename);
		}

		# if template doesn't exist
		# and we are in debug mode
		# report the issue
		WriteLog('GetTemplate: warning: template missing; $filename = ' . $filename . '; $DEFAULTDIR = ' . $DEFAULTDIR . '; $CONFIGDIR = ' . $CONFIGDIR);
		WriteLog('GetTemplate: warning: template missing; $filename = ' . $filename . '; caller = ' . join(',', caller));
		#WriteLog('GetTemplate: warning: template missing; ' . ($CONFIGDIR . '/template/' . $filename));
		#WriteLog('GetTemplate: warning: template missing; ' . ($DEFAULTDIR . '/template/' . $filename));
	}

	#information about theme
#	my $themeName = GetConfig('theme');
#	my $themePath = 'theme/' . $themeName . '/template/' . $filename;

	my $template = '';
	if (GetThemeAttribute('template/' . $filename)) {
		WriteLog('GetTemplate: Found GetThemeAttribute(template/' . $filename . ')');
		#if current theme has this template, override default
		$template = GetThemeAttribute('template/' . $filename);
	} elsif (GetConfig('template/' . $filename)) {
		WriteLog('GetTemplate: found GetConfig(template/' . $filename . ')');
		#otherwise use regular template
		$template = GetConfig('template/' . $filename);
	} else {
		WriteLog('GetTemplate: warning: found neither GetThemeAttribute(template/' . $filename . ') nor GetConfig(template/' . $filename . '); caller = ' . join(',', caller));
		$template = '';
	}

	# add \n to the end because it makes the resulting html look nicer
	# and doesn't seem to hurt anything else
	$template .= "\n";

	if ($isHtmlTemplate && GetConfig('debug')) {
		#todo this is buggy
		#$template .= '<!-- ' . join(', ', caller) . '-->' . "\n";
	}

	if ($isHtmlTemplate) {
		if (substr($template, 0, 4) eq '<!--') {
			# add newline to make it look nicer in the html source
			$template = "\n" . $template;
		}
	}

	if ($template) {
		#if template contains something, cache it
		$templateMemo{$filename} = $template;
		return $template;
	} else {
		#if result is blank, report it
		WriteLog("GetTemplate: warning: GetTemplate() returning empty string for $filename.");
		return '';
	}
} # GetTemplate()

sub GetList { # $listName ; reads a list from a template and returns it as an array
# GetTagSet {
# tagsets are also lists, so use this
# Examples:
# my @menu = GetList('list/menu');
# my @tagsForMe = GetList('tagset/me');

	my $listName = shift;
	#todo sanity

	chomp $listName;
	if (!$listName) {
		WriteLog('GetList: warning: sanity check failed on $listName');
		return '';
	}

	WriteLog('GetList(' . $listName . '); caller = ' . join(',', caller));

	my $templateContents = GetTemplate($listName);
	#todo sanity

	my @arrayReturn = split("\n", $templateContents);

	return @arrayReturn;
} # GetList()

sub RenameFile { # $filePrevious, $fileNew, $hashNew ; renames file with a bit of sanity checking and logging
# sub FileRename {

	my $filePrevious = shift;
	my $fileNew = shift;
	my $hashNew = shift;
	#todo sanity

	chomp $filePrevious;
	chomp $fileNew;

	if ($hashNew) {
		# ok
		chomp $hashNew;
	} else {
		# hash not specified, get it
		$hashNew = GetFileHash($filePrevious);
	}

	WriteLog("RenameFile: $filePrevious, $fileNew); caller = " . join(',', caller));
	my $hashPrevious = SqliteGetValue("SELECT file_hash FROM item WHERE file_path = '$filePrevious'"); #todo safety

	if ($hashPrevious) {
		WriteLog('RenameFile: $hashPrevious = ' . $hashPrevious . '; $hashNew = ' . $hashNew);
		#todo sanity check on $hashPrevious
		DBAddItemParent($hashNew, $hashPrevious);
		AppendFile("log/rename.log", $hashNew . "|" . $hashPrevious); #todo proper path
		#todo log and sanity check on $renameResult
	} else {
		WriteLog('RenameFile: warning: $hashPrevious was FALSE');
		#return '';
	}

	my $renameResult = rename($filePrevious, $fileNew);
	return $renameResult;
} # RenameFile()

sub encode_entities2 { # returns $string with html entities <>"& encoded
	my $string = shift;
	if (!$string) {
		return;
	}

	WriteLog('encode_entities2() BEGIN, length($string) is ' . length($string));
	#WriteLog('encode_entities2() BEGIN, $string = ' . $string);

	$string =~ s/&/&amp;/g;
	$string =~ s/\</&lt;/g;
	$string =~ s/\>/&gt;/g;
	$string =~ s/"/&quot;/g;

	return $string;
} # encode_entities2()

sub GetAlias { # $fingerprint, $noCache ; Returns alias for an author
	my $fingerprint = shift;

	if (!$fingerprint) {
		WriteLog('GetAlias: warning: $fingerprint was missing; caller = ' . join(',', caller));
		return '';
	}

	chomp $fingerprint;

	WriteLog("GetAlias($fingerprint)");

	my $noCache = shift;
	$noCache = ($noCache ? 1 : 0);

	state %aliasCache;
	if (!$noCache) {
		if (exists($aliasCache{$fingerprint})) {
			return $aliasCache{$fingerprint};
		}
	}

	my $alias = DBGetAuthorAlias($fingerprint);

	if ($alias) {
		{ # remove email address, if any
			$alias =~ s|<.+?>||g;
			$alias = trim($alias);
			chomp $alias;
		}

		if ($alias && length($alias) > 24) {
			$alias = substr($alias, 0, 24);
		}

		$aliasCache{$fingerprint} = $alias;
		return $aliasCache{$fingerprint};
	} else {
		#return $fingerprint;
		return '';
		#		return 'unregistered';
	}
} # GetAlias()

sub GetFileExtension { # $fileName ; returns file extension, naively
	my $fileName = shift;

	if ($fileName) {
		if ($fileName =~ m/.+\/.+\.(.+)/) {
			return $1;
		} else {
			return '';
		}
	} else {
		return '';
	}
} # GetFileExtension()

sub GetFile { # Gets the contents of file $fileName
	my $fileName = shift;
	if (!$fileName) {
		WriteLog('GetFile: warning: $fileName missing or false');
		return '';
	}

	chomp $fileName;

	if ($fileName =~ m/^([0-9a-zA-Z\/._-]+)$/) {
		$fileName = $1;
		WriteLog('GetFile: $fileName passed sanity check: ' . $fileName);
	} else {
		WriteLog('GetFile: warning: $fileName FAILED sanity check: ' . $fileName);
		return '';
	}

	my $length = shift || 209715200;
	# default to reading a max of 2MB of the file. #scaling #bug #todo

	WriteLog('GetFile: trying to open file...');
	use open qw(:utf8);
	if (
		-e $fileName # file exists
			&&
		!-d $fileName # not a directory
			&&
		open(my $file, "<", $fileName) # opens successfully
	) {
		WriteLog('GetFile: opened successfully, trying to read...');
		my $return;
		read($file, $return, $length);
		#WriteLog('GetFile: read success, returning.');
		#WriteLog('GetFile: read success, returning. $return = ' . $return);
		#WriteLog('GetFile: read success, returning. length($return) = ' . ($return ? length($return) : 'FALSE'));
		return $return;
	} else {
		WriteLog('GetFile: warning: open failed! $fileName = ' . $fileName);
	}

	return;
	#todo do something for a file which is missing
} # GetFile()

sub GetTime () { # Returns time in epoch format.
	# Just returns time() for now, but allows for converting to 1900-epoch time
	# instead of Unix epoch

	#	return (time() + 2207520000);
	return (time());
} # GetTime()

sub GetClockFormattedTime() { # returns current time in appropriate format from config
	# this formats the user-facing time, like the clock on the pages (if enabled)
	# formats supported: 24hour, union, epoch (default)

	my $clockFormat = GetConfig('setting/html/clock_format');
	chomp $clockFormat;

	if ($clockFormat eq '24hour') {
		my $time = GetTime();
		my $hours = strftime('%H', localtime $time);
		my $minutes = strftime('%M', localtime $time);
		my $clockFormattedTime = $hours . ':' . $minutes;

		if (0) { # 24-hour with seconds
			my $seconds = strftime('%S', localtime $time);
			my $clockFormattedTime = $hours . ':' . $minutes . ':' . $seconds;
		}

		return $clockFormattedTime;
	}

	if ($clockFormat eq 'union') {
		my $time = GetTime();

		#todo implement this, for now it's only js
		#$clockFormattedTime = 'union_clock_format';
		# my $timeDate = strftime '%Y/%m/%d %H:%M:%S', localtime $time;
		#
		# var hours = now.getHours();
		# var minutes = now.getMinutes();
		# var seconds = now.getSeconds();
		my $hours = strftime('%H', localtime $time);
		my $minutes = strftime('%M', localtime $time);
		my $seconds = strftime('%S', localtime $time);
		#

		my $milliseconds = '000';
		# if (now.getMilliseconds) {
		# 	milliseconds = now.getMilliseconds();
		# } else if (Math.floor && Math.random) {
		# 	milliseconds = Math.floor(Math.random() * 999)
		# }
		#
		# var hoursR = 23 - hours;
		# if (hoursR < 10) {
		# 	hoursR = '0' + '' + hoursR;
		# }
		my $hoursR = 23 - $hours;
		if ($hoursR < 10) {
			$hoursR = '0' . $hoursR;
		}

		# var minutesR = 59 - minutes;
		# if (minutesR < 10) {
		# 	minutesR = '0' + '' + minutesR;
		# }
		my $minutesR = 59 - $minutes;
		if ($minutesR < 10) {
			$minutesR = '0' . $minutesR;
		}

		# var secondsR = 59 - seconds;
		# if (secondsR < 10) {
		# 	secondsR = '0' + '' + secondsR;
		# }
		my $secondsR = 59 - $seconds;
		if ($secondsR < 10) {
			$secondsR = '0' . $secondsR;
		}

		#
		# if (milliseconds < 10) {
		# 	milliseconds = '00' + '' + milliseconds;
		# } else if (milliseconds < 100) {
		# 	milliseconds = '0' + '' + milliseconds;
		# }
		#

		my $clockFormattedTime = $hours . $minutes . $seconds . $milliseconds . $secondsR . $minutesR . $hoursR;

		return $clockFormattedTime;
	}

	# this is fallback, with sanity check
	my $fallbackTime = time();
	if (
		$fallbackTime =~ m/^([0-9]+)\.([0-9]+)$/ ||
		$fallbackTime =~ m/^([0-9]+)$/
	) {
		# sanity check passed
		$fallbackTime = $1;
	}
	else {
		# sanity check failed
		$fallbackTime = '';
	}

	return $fallbackTime;
} # GetClockFormattedTime()

sub PutFile { # Writes content to a file; $file, $content, $binMode
# sub PutTextFile {
	# $file = file path
	# $content = content to write
	# $binMode = whether or not to use binary mode when writing
	# ensures required subdirectories exist
	#
	WriteLog("PutFile(...)");

	my $file = shift;

	if (!$file) {
		return;
	}

	WriteLog("PutFile($file)");

	# keep track of files written so we can report them to user
	state @debugFilesWritten;
	# my $timeBegin = GetTime(); #todo
	if ($file eq 'report_files_written') {
		return @debugFilesWritten;
	}
	push @debugFilesWritten, GetPaddedEpochTimestamp() . ' ' . $file;

	WriteLog("PutFile: EnsureSubdirs($file)");

	EnsureSubdirs($file);

	WriteLog("PutFile: $file, ...");

	my $content = shift;
	my $binMode = shift;

	if (!defined($content)) {
		WriteLog('PutFile: $content not defined, returning');
		return;
	}

	#	if (!$content) {
	#		return;
	#	}
	if (!$binMode) {
		$binMode = 0;
		WriteLog('PutFile: $binMode: 0');
	} else {
		$binMode = 1;
		WriteLog('PutFile: $binMode: 1');
	}

	WriteLog('PutFile: $file = ' . $file . ', $content = (' . length($content) . 'b), $binMode = ' . $binMode);
	#WriteLog("==== \$content ====");
	#WriteLog($content);
	#WriteLog("====");

	#todo use temp file and rename (see php version)

	if ($file =~ m/^([^\s]+)$/) { #todo this is overly permissive #security #taint
		$file = $1;
		use open qw(:utf8);
		if (open(my $fileHandle, ">", $file)) {
#		if (open(my $fileHandle, ">:encoding(UTF-8)", $file)) {
			WriteLog('PutFile: file handle opened, $file = ' . $file);
			if ($binMode) {
				WriteLog('PutFile: binmode $fileHandle = ' . $fileHandle . ', :utf8;');
				#binmode $fileHandle, ':utf8';
			}

			# if ($content =~ m/[^\x00-\xFF]/) {
			# 	WriteLog('PutFile: warning: $content contains wide characters, setting :utf8; caller = ' . join(',', caller));
			# 	binmode $fileHandle, ':utf8';
			# }

			if ($content =~ m/[^\x00-\xFF]/) {
				#WriteLog('PutFile: warning: $content contains wide characters, setting :utf8; caller = ' . join(',', caller));
				#binmode $fileHandle, ':utf8';
			}

			WriteLog('PutFile: print $fileHandle $content;');
			print $fileHandle $content; #todo wide character warning here why??

			WriteLog('PutFile: close $fileHandle;');
			close $fileHandle;

			return 1;
		}
	} else {
		WriteLog('PutFile: warning: sanity check failed: $file contains space');
	}
} # PutFile()

sub EpochToHuman { # returns epoch time as human readable time
	my $time = shift;

	return strftime('%F %T', localtime($time));
} # EpochToHuman()

sub EpochToHuman2 { # not sure what this is supposed to do, and it's unused
	my $time = shift;

	my ($seconds, $minutes, $hours, $day_of_month, $month, $year, $wday, $yday, $isdst) = localtime($time);
	$year = $year + 1900;
	$month = $month + 1;

} # EpochToHuman2()

sub GetPaddedEpochTimestamp { # returns zero-padded formatted epoch time
	# this is used to get log timestamps to line up nicely when float/millisecond is used
	# if there is no period, it should return unchanged.

	my $time = GetTime();

	if ($time =~ m/^[0-9]+\.[0-9]{1}$/) {
		$time .= '0';
	}
	if ($time =~ m/^[0-9]+\.[0-9]{2}$/) {
		$time .= '0';
	}
	if ($time =~ m/^[0-9]+\.[0-9]{3}$/) {
		$time .= '0';
	}
	if ($time =~ m/^[0-9]+\.[0-9]{4}$/) {
		$time .= '0';
	}

	return $time;
} # GetPaddedEpochTimestamp()

sub str_replace { # $replaceWhat, $replaceWith, $string ; emulates some of str_replace() from php
#props http://www.bin-co.com/perl/scripts/str_replace.php
	# fourth $count parameter not implemented yet
	my $replace_this = shift;
	my $with_this  = shift;
	my $string   = shift;

	my $stringLength = length($string);

	if (!defined($string) || !$string) {
		#todo edge cases like '0', 0, ''
		#what to do for ''??
		WriteLog('str_replace: warning: $string not supplied; caller = ' . join(',', caller));
		return "";
	}

	if (length($replace_this) < 32 && length($with_this) < 32) {
		WriteLog("str_replace($replace_this, $with_this, ($stringLength)); caller = " . join(',', caller));
	} else {
		WriteLog('str_replace($replace_this = ' . length($replace_this) . 'b, $with_this = ' . length($with_this) . 'b , ($stringLength = ' . $stringLength . ')); caller = ' . join (',', caller));
	}

	if (!defined($replace_this) || !defined($with_this)) {
		WriteLog('str_replace: warning: sanity check failed, missing $replace_this or $with_this');
		return $string;
	}

	if ($replace_this eq $with_this) {
		WriteLog('str_replace: warning: $replace_this eq $with_this; caller: ' . join(', ', caller));
		return $string;
	}

	#WriteLog("str_replace: sanity check passed, proceeding");

	WriteLog('str_replace: sanity check passed, proceeding');
	$string =~ s/\Q$replace_this/$with_this/g;
	WriteLog('str_replace: length($string) = ' . length($string));
	# WriteLog('str_ireplace: $string = ' . $string);

	# RETURN ###############
	# RETURN ###############
	# RETURN ###############
	# RETURN ###############
	# RETURN ###############
	return $string;


	if (0) { #buggy code, not used
		my $length = length($string);
		my $target = length($replace_this);

		for (my $i = 0; $i < $length - $target + 1; $i++) {
			#todo there is a bug here
			if (!defined(substr($string, $i, $target))) {
				WriteLog("str_replace: warning: !defined(substr($string, $i, $target))");
			}
			elsif (substr($string, $i, $target) eq $replace_this) {
				$string = substr ($string, 0, $i) . $with_this . substr($string, $i + $target);
				$i += length($with_this) - length($replace_this); # when new string contains old string
				$length += length($with_this) - length($replace_this); # string is getting shorter or longer
			} else {
				# do nothing
			}
		}

		WriteLog('str_replace: length($string) = ' . length($string));

		return $string;
	}
} # str_replace()

sub str_ireplace { # $replaceWhat, $replaceWith, $string ; emulates some of str_ireplace() from php
#props http://www.bin-co.com/perl/scripts/str_replace.php
	# fourth $count parameter not implemented yet
	#todo this definitely has a performance problem
	# and also possible bugs
	#todo
	my $replace_this = shift;
	my $with_this  = shift;
	my $string   = shift;

	# this workaround has a problem with regex syntax
	# $string =~ s/$replace_this/$with_this/gi;
	# return $string;

	#todo make below more efficient

	if (!defined($string) || !$string) {
		WriteLog('str_ireplace: warning: $string not supplied');
		return "";
	}

	my $stringLength = length($string);

	if (length($replace_this) < 32 && length($with_this) < 32) {
		WriteLog("str_ireplace($replace_this, $with_this, ($stringLength))");
	} else {
		WriteLog('str_ireplace($replace_this = ' . length($replace_this) . 'b, $with_this = ' . length($with_this) . 'b , ($stringLength = ' . $stringLength . ')); caller = ' . join (',', caller));
	}

	if ($replace_this eq $with_this) {
		WriteLog('str_ireplace: warning: $replace_this eq $with_this');
		WriteLog('str_ireplace: caller: ' . join(', ', caller));
		return $string;
	}

	WriteLog('str_ireplace: sanity check passed, proceeding');
	$string =~ s/\Q$replace_this/$with_this/gi;
	WriteLog('str_ireplace: length($string) = ' . length($string));
	# WriteLog('str_ireplace: $string = ' . $string);
	return $string;

	######## below is old code, not used
	######## below is old code, not used
	######## below is old code, not used
	######## below is old code, not used
	######## below is old code, not used

	my $length = length($string);
	my $target = length($replace_this);

	my $loopCounter = 0;

	for (my $i = 0; $i < $length - $target + 1; $i++) {
		if (lc(substr($string, $i, $target)) eq lc($replace_this)) {
			$string = substr ($string, 0, $i) . $with_this . substr($string, $i + $target);
			$i += length($with_this) - length($replace_this); # when new string contains old string
		}

		$loopCounter++;

		if ($loopCounter > 1000) {
			WriteLog('str_ireplace: warning: loop has reached 1000 iterations, stopping');
			last;
		}
	}

	WriteLog('str_ireplace: length($result) = ' . length($string));

	return $string;
} # str_replace()

sub ReplaceStrings { # automatically replaces strings in html with looked up values
#todo finish it
	my $content = shift;
	my $newLanguage = shift;

	if (!$newLanguage) {
		$newLanguage = GetConfig('language');
	}

	my $contentStripped = $content;
	$contentStripped =~ s/\<[^>]+\>/<>/sg;
	my @contentStrings = split('<>', $contentStripped);

	foreach my $string (@contentStrings) {
		$string = trim($string);
		if ($string && length($string) >= 5) {
			my $stringHash = md5_hex($string);
			WriteLog('ReplaceStrings, replacing ' . length($string) . '-char-long string (' . $stringHash . ')');
			#WriteLog('ReplaceStrings, replacing ' . $string . ' (' . $stringHash . ')');
			my $newString = GetConfig('string/' . $newLanguage . '/' . $stringHash);
			if ($newString) {
				if ($string ne $newString) {
					$content = str_replace($string, $newString, $content);
				}
			} else {
				PutConfig('string/' . $newLanguage . '/' . $stringHash, $string);
			}
		}
	}

	return $content;
} # ReplaceStrings()

sub ServerSign { # $filePath
	return '';
	#todo sanity
	my $newFilePath = shift;
	chomp $newFilePath;
	`gpg --clearsign $newFilePath`;
	`mv $newFilePath.asc $newFilePath`;
	IndexRecentTextFiles();
}

sub IsUrl { # add basic isurl()
	return 1;
} # IsUrl()

sub PutHtmlFile { # $file, $content ; writes content to html file, with special rules; parameters: $file, $content
# sub WriteHtmlFile {

	# * if config/admin/html/ascii_only is set, all non-ascii characters are stripped from output to file
	# * if $file matches config/html/home_page, the output is also written to index.html
	# * if config/html/relativize_urls is true, rewrites links to be relative, e.g. /foo.html to ./foo.html
	#
	#   also keeps track of whether home page has been written, and returns the status of it
	#   if $file is 'check_homepage'
	#
	#   also keeps track of all files written and returns the list as an array
	#   if $file is 'report_files_written'

	my $file = shift;
	my $content = shift;

	if (!$file) {
		return;
	}

	#todo more sanity

	# keep track of files written so we can report them to user
	state @debugFilesWritten;
	# my $timeBegin = GetTime(); #todo
	if ($file eq 'report_files_written') {
		return @debugFilesWritten;
	}
	push @debugFilesWritten, GetPaddedEpochTimestamp() . ' ' . $file;

	WriteLog("PutHtmlFile($file) ; caller = " . join(',', caller));

	state $HTMLDIR = GetDir('html');
	#todo sanitycheck $HTMLDIR

	WriteLog('PutHtmlFile: $HTMLDIR = ' . $HTMLDIR);
	#WriteLog('PutHtmlFile: caller = ' . join(',', caller));

	if ($HTMLDIR && !-e $HTMLDIR) {
		WriteLog('PutHtmlFile: warning: $HTMLDIR was missing, trying to mkdir(' . $HTMLDIR . ')');
		mkdir($HTMLDIR);
	}

	if (!$HTMLDIR || !-e $HTMLDIR) {
		WriteLog('PutHtmlFile: $HTMLDIR is missing: ' . $HTMLDIR);
		return '';
	}

	if (!$content) {
		WriteLog('PutHtmlFile: warning: $content missing; caller = ' . join(',', caller));
		$content = '';
	}

	# remember what the filename provided is, so that we can use it later
	my $fileProvided = $file;
	$file = "$HTMLDIR/$file";

	my $postUrl = GetConfig('admin/post/post_url');
	if ($postUrl) {
		# replace target for form submissions from current site to somewhere else
		if ($postUrl ne '/post.html') {
			#todo sanity
			if (index($content, '/post.html') != -1) {
				str_replace('/post.html', $postUrl, $content);
				$content =~ s/\/post.html/$postUrl/g;
			}
		}
	}

	# controls whether linked urls are converted to relative format
	# meaning they go from e.g. /write.html to ./write.html
	# this breaks the 404 page links so disable that for now

	my $relativizeUrls = (GetConfig('html/relativize_urls') ? 1 : 0);
	if (TrimPath($file) eq '404') {
		$relativizeUrls = 0;
	}
	if ($file eq "$HTMLDIR/stats-footer.html") {
		#note this means footer links will be broken if hosted on non-root dir on a domain
		$relativizeUrls = 0;
	}

	WriteLog('PutHtmlFile: $file = ' . $file . ', $content = (' . length($content) . 'b)');

	# $stripNonAscii remembers value of admin/html/ascii_only
	# this might be duplicate work
	state $stripNonAscii;
	if (!defined($stripNonAscii)) {
		$stripNonAscii = GetConfig('admin/html/ascii_only');
		if (!defined($stripNonAscii)) {
			$stripNonAscii = 0;
		}
		if ($stripNonAscii != 1) {
			$stripNonAscii = 0;
		}
	}

	# if $stripNonAscii is on, strip all non-ascii characters from the output
	# in the future, this can, perhaps, for example, convert unicode-cyrillic to ascii-cyrillic
	if ($stripNonAscii == 1) {
		WriteLog('PutHtmlFile: $stripNonAscii == 1, removing non-ascii characters');
		my $lengthBefore = length($content);
		$content =~ s/[^[:ascii:]]//g;
		if (length($content) != $lengthBefore) {
			if (index(lc($content), '</body>') != -1) {
				my $messageNotification = 'Non-ASCII characters removed during page printing: ' . ($lengthBefore - length($content));
				if (GetConfig('debug')) {
					#$messageNotification .= '<br><form><textarea>'.HtmlEscape('<script>alert()</script>').'</textarea></form>';
				}
				$content = str_ireplace('</body>', GetDialogX($messageNotification, 'Notice') . '</body>', $content);
			}
		}
	}


	if (0) { #todo quick-write setting #quickwrite #quick-write #quick_write
		my $quickWriteWindow = GetDialogX(GetTemplate('html/form/write/write-quick.template'), 'Quick-Write');
		$quickWriteWindow =
			'<form action="/post.html" method=GET id=compose class=submit name=compose target=_top>' . #todo
			$quickWriteWindow .
			'</form>';

		$quickWriteWindow = '<span class=advanced>' . $quickWriteWindow . '</span>';

		$content = str_ireplace('</body>', $quickWriteWindow . '</body>', $content);
	}

	# convert urls to relative if $relativizeUrls is set
	if ($relativizeUrls == 1) {
		WriteLog('PutHtmlFile: $relativizeUrls == 1, relativizing urls');
		# only the following *exact* formats are converted
		# thus it is important to maintain this exact format throughout the html and js templates
		# src="/
		# href="/
		# .src = '/
		# .location = '/

		# first we determine how many levels deep our current file is
		# we do this by counting slashes in $file
		my $count = ($fileProvided =~ s/\//\//g) + 1;

		# then we build the path prefix.
		# the same prefix is used on all links
		# this can be done more efficiently on a per-link basis
		# but most subdirectory-located files are of the form /aa/bb/aabbcc....html anyway
		my $subDir;
		if ($count == 1) {
			$subDir = './';
		} else {
			if ($count < 1) {
				WriteLog('PutHtmlFile: relativize_urls: sanity check failed, $count is < 1');
			} else {
				# $subDir = '../' x ($count - 1);
				$subDir = str_repeat('../', ($count - 1));
			}
		}

		# here is where we do substitutions
		# it may be wiser to use str_replace() here
		#todo test this more

		# html
		$content =~ s/src="\//src="$subDir/ig;
		$content =~ s/href="\//href="$subDir/ig;
		$content =~ s/background="\//background="$subDir/ig;
		$content =~ s/action="\//action="$subDir/ig;
		$content =~ s/src=\//src=$subDir/ig;
		$content =~ s/href=\//href=$subDir/ig;
		$content =~ s/background=\//background=$subDir/ig;
		$content =~ s/action=\//action=$subDir/ig;

		# javascript
		$content =~ s/\.src = '\//.src = '$subDir/ig;
		$content =~ s/\.location = '\//.location = '$subDir/ig;

		# css
		$content =~ s/url\(\/\//url=$subDir/ig;
	} # if ($relativizeUrls)

	# fill in colors
	{
		my $colorTopMenuTitlebarText = GetThemeColor('top_menu_titlebar_text') || GetThemeColor('titlebar_text');
		$content =~ s/\$colorTopMenuTitlebarText/$colorTopMenuTitlebarText/g;#

		my $colorTopMenuTitlebar = GetThemeColor('top_menu_titlebar') || GetThemeColor('titlebar');
		$content =~ s/\$colorTopMenuTitlebar/$colorTopMenuTitlebar/g;

		my $colorTitlebarText = GetThemeColor('titlebar_text');#
		$content =~ s/\$colorTitlebarText/$colorTitlebarText/g;#

		my $colorTitlebar = GetThemeColor('titlebar');#
		$content =~ s/\$colorTitlebar/$colorTitlebar/g;#

		my $borderDialog = GetThemeAttribute('color/border_dialog');
		#todo rename it in all themes and then here
		# not actually a color, but the entire border definition
		$content =~ s/\$borderDialog/$borderDialog/g;

		my $colorWindow = GetThemeColor('window');
		$content =~ s/\$colorWindow/$colorWindow/g;
	}

	# #internationalization #i18n
	if (GetConfig('language') ne 'en') {
		$content = ReplaceStrings($content);
	}

	# this allows adding extra attributes to the body tag
	my $bodyAttr = GetThemeAttribute('tag/body');
	if ($bodyAttr) {
		$bodyAttr = FillThemeColors($bodyAttr);
		$content =~ s/\<body/<body $bodyAttr/i;
		$content =~ s/\<body>/<body $bodyAttr>/i;
	}

	#if (GetConfig('html/debug')) {
		# this would make all one-liner html comments visible if it worked
		#$content =~ s/\<\!--(.+)--\>/<p class=advanced>$1<\/p>/g;
	#}

	# if (GetConfig('debug')) {
	# 	my $hashSetting = trim(GetFile(GetDir('config') . '/hash_setting'));
	# 	if ($hashSetting) {
	# 		$content .= '' . $hashSetting . '';
	# 	}
	# }

	{ # tests and warnings
		if (index($content, '$') > -1) {
			# test for $ character in html output, warn/crash if it is there
			if (!($fileProvided eq 'openpgp.js')) {
				# except for openpgp.js, most files should not have $ characters
				WriteLog('PutHtmlFile: warning: $content contains $ symbol! $file = ' . ($file ? $file : '-'));
				# $content = GetPageHeader('error') . GetDialogX('This page is under construction.', 'Under Construction') . GetPageFooter('error');
			}
		}
		if (index($content, 'maincontent') == -1) {
			# ensure document contains a mainconvent-tagged element
			# typically: <MAIN ID=maincontent><A NAME=maincontent></A>
			if (index($fileProvided, '.js') != -1) {
				# it's cool
			} else {
				WriteLog('PutHtmlFile: warning: "maincontent" not found in file! $file = ' . ($file ? $file : '-'));
			}
		}
		if (
			index(lc($content), '<td></td>') != -1 ||
			index(lc($content), '<td class=advanced></td>') != -1 #||
			#$content =~ m|<td[^>]+></td>| #todo make this work
		) {
			# empty table cells present rendering issues in netscape,
			# and may also be a sign of larger problems.
			WriteLog('PutHtmlFile: warning: content has empty table cells <td></td> ; caller = ' . join(',', caller));
			$content = str_ireplace('<td></td>', '<td>-</td>', $content);
			$content = str_ireplace('<td class=advanced></td>', '<td class=advanced>-</td>', $content);
			#$content =~ s|(<td[^>]+>)(</td>)|$1-$2|i; #todo make this work
		}
		if ($content =~ m/<html.+<html/i) {
			# test for duplicate <html> tag
			WriteLog('PutHtmlFile: warning: $content contains duplicate <html> tags');
		}
	} # tests and warnings

	if (GetConfig('admin/js/enable') && GetConfig('admin/js/debug')) {
		if ($file =~ m/dialog/) {
			# do not inject js debug button
		} else {
			# add "jsdebug" button if js debugging is enabled
			if (index(lc($content), '<script') != -1 && index($content, 'debug_button') == -1) {
				$content = GetTemplate('html/widget/debug_button.template') . $content;
			} else {
				WriteLog('InjectJs: warning: wanted to inject debug_button, but it is already in $html');
			}
			#todo make nicer
		}
	} # jsdebug button

	if (GetConfig('html/generator_meta')) {
		# add generator meta tag to head
		if (index(lc($content), '</head>')) {
			#die;
			my $progName = 'Pollyanna';
			my $versionSeq = '1337';
			my $versionGit = '01234abc';

			my $generatorMeta = '<meta name="GENERATOR" content="' . $progName . ' ' . $versionSeq . ' (' . $versionGit . ')">';
			my $contentPrev = $content;
			#$content = str_ireplace('</head>', $generatorMeta . "\n" . '</head>', $content); #todo retain capitalization of head tag
			$content =~ s|(</head>)|$generatorMeta\n$1|;
		}
	} # html/generator_meta

	#############################################
	## WRITE TO FILE ############################
	#############################################
	my $putFileResult = PutFile($file, $content);
	#############################################
	############################ WRITE TO FILE ##
	#############################################

	if (!-e ($HTMLDIR . '/index.html')) {
		# if index is missing replace it with anything that comes along
		if (
			$file =~ m/profile/ ||
			$file =~ m/welcome/ ||
			$file =~ m/read/ ||
			$file =~ m/write/ ||
			$file =~ m/help/
		) {
			WriteLog('PutHtmlFile: warning: index.html was missing, fixing it with $file = ' . $file);
			my $putIndexFileName = PutHtmlFile("$HTMLDIR/index.html", $content);
			WriteLog('PutHtmlFile: $putIndexFileName = ' . $putIndexFileName);
		}
	} # missing /index.html

	return $putFileResult;
} # PutHtmlFile()

sub GetFileAsHashKeys { # returns file as hash of lines
	# currently not used, can be used for detecting matching lines later
	my $fileName = shift;
	my @lines = split('\n', GetFile($fileName));
	my %hash;
	foreach my $line (@lines) {
		$hash{$line} = 0;
	}
	return %hash;
} # GetFileAsHashKeys()

sub AppendFile { # appends something to a file; $file, $content to append
	# mainly used for writing to log files
	my $file = shift;
	my $content = shift;

	# uncomment this for debugging AppendFile()
	# cannot use WriteLog() here because it calls this sub
	#print('AppendFile($file = ' . $file . '; $content = ' . length($content) . ' bytes)');

	#use open qw(:utf8);
	#if (open(my $fileHandle, ">>", $file)) {
	if (open(my $fileHandle, ">>:encoding(UTF-8)", $file)) {
		say $fileHandle $content; #note that this appends \n automatically
		close $fileHandle;
	}
} # AppendFile()

sub AuthorHasLabel { # $key ; returns 1 if user is admin, otherwise 0
	# will probably be redesigned in the future
	my $key = shift;
	my $tagInQuestion = shift;

	if (!IsFingerprint($key)) {
		WriteLog('AuthorHasLabel: warning: $key failed sanity check, returning 0; caller = ' . join(',', caller));
		return 0;
	}

	if (!trim($tagInQuestion)) {
		WriteLog('AuthorHasLabel: warning: $tagInQuestion failed sanity check, returning 0; caller = ' . join(',', caller));
		return 0;
	}

	#todo $tagInQuestion sanity check

	WriteLog("AuthorHasLabel($key, $tagInQuestion)");

	my $pubKeyHash = DBGetAuthorPublicKeyHash($key);
	if ($pubKeyHash) {
		WriteLog('AuthorHasLabel: $pubKeyHash = ' . $pubKeyHash);

		my $pubKeyVoteTotalsRef = DBGetItemLabelTotals2($pubKeyHash);
		my %pubKeyVoteTotals = %{$pubKeyVoteTotalsRef};
		WriteLog('AuthorHasLabel: join(",", keys(%pubKeyVoteTotals)) = ' . join(",", keys(%pubKeyVoteTotals)));

		if ($pubKeyVoteTotals{$tagInQuestion}) {
			WriteLog('AuthorHasLabel: $tagInQuestion FOUND, return 1');
			return 1;
		} else {
			WriteLog('AuthorHasLabel: $tagInQuestion NOT found, return 0');
			return 0;
		}
	} else {
		WriteLog('AuthorHasLabel: warning, no $pubKeyHash, how did we even get here? caller = ' . join(',', caller));
		return 0;
	}

	WriteLog('AuthorHasLabel: warning: unreachable fallthrough');
	return 0;
} # AuthorHasLabel()

sub IsAdmin { # $key ; returns 1 if user is admin, otherwise 0
# sub UserIsAdmin {
	# returns 2 if user is root admin.

	my $key = shift;
	if (!$key || !IsFingerprint($key)) {
		WriteLog('IsAdmin: warning: $key failed sanity check, returning 0');
		return 0;
	}
	WriteLog("IsAdmin($key)");

	my $rootAdminKey = ''; #GetRootAdminKey();
	if (!$rootAdminKey) {
		$rootAdminKey = '';
	}

	if ($key eq $rootAdminKey) {
		WriteLog('IsAdmin: $key eq $rootAdminKey, return 2 ');
		return 2; # is admin, return true;
	} else {
		if (GetConfig('admin/allow_admin_permissions_tag_lookup')) {
			WriteLog('IsAdmin: not root admin, checking tags');
			return AuthorHasLabel($key, 'admin');
		} else {
			WriteLog('IsAdmin: allow_admin_permissions_tag_lookup is false, stopping here');
			return 0;
		}
	}

	WriteLog('IsAdmin: warning: unreachable reached'); #should never reach here
} # IsAdmin()

sub TrimPath { # $string ; Trims the directories AND THE FILE EXTENSION from a file path
# sub GetFileName {
# sub RemovePath {
# sub StripPath {

	my $string = shift;
	while (index($string, "/") >= 0) {
		$string = substr($string, index($string, "/") + 1);
	}
	if (rindex($string, ".") != -1) {
		$string = substr($string, 0, rindex($string, ".") + 0);
	}
	return $string;
} # TrimPath()

sub IsSha1 { # returns 1 if parameter is in sha1 hash format, 0 otherwise
	my $string = shift;

	if (!$string) {
		return 0;
	}

	if ($string =~ m/[a-fA-F0-9]{40}/) {
		return 1;
	} else {
		return 0;
	}
} # IsSha1()

sub IsImageFile { # $file ; returns 1 if image file, 0 if not
	my $file = shift;
	if (!$file) {
		return 0;
	}
	chomp $file;
	if (!$file) {
		return 0;
	}

	if (
		-e $file
			&&
		(
			substr(lc($file), length($file) -4, 4) eq ".jpg" ||
			substr(lc($file), length($file) -5, 5) eq ".jpeg" ||
			substr(lc($file), length($file) -4, 4) eq ".gif" ||
			substr(lc($file), length($file) -4, 4) eq ".png" ||
			substr(lc($file), length($file) -4, 4) eq ".bmp" ||
			substr(lc($file), length($file) -4, 4) eq ".svg" ||
			substr(lc($file), length($file) -5, 5) eq ".jfif" ||
			substr(lc($file), length($file) -5, 5) eq ".webp"
		)
	) {
		return 1;
	} else {
		return 0;
	}
	return 0;
} # IsImageFile()

sub IsTextFile { # $file ; returns 1 if txt file, 0 if not
	my $file = shift;
	if (!$file) {
		return 0;
	}
	chomp $file;
	if (!$file) {
		return 0;
	}

	if (
		-e $file
			&&
		(
			substr(lc($file), length($file) -4, 4) eq ".txt"
		)
	) {
		return 1;
	} else {
		return 0;
	}
	return 0;
} # IsTextFile()

sub IsSaneFilename {
# sub IsValidFile {
# sub IsFile {
	my $fileName = shift;

	if ($fileName) {
		if ($fileName =~ m/^([0-9a-zA-Z\/\._:\-]+)$/) {
			return 1;
		} else {
			return 0;
		}
	} else {
		return 0;
	}
} # IsSaneFilename()

sub IsItem { # $string ; returns untained string, 0 if not item
#sub IsHash {
# should be called IsValidItemHash {
# todo more validation
	my $string = shift;

	if (!$string) {
		return 0;
	}

	if ($string =~ m/^([0-9a-f]{40})$/) {
		return $1;
	}

	if ($string =~ m/^([0-9a-f]{8})$/) {
		return $1;
	}

	return 0;
} # IsItem()

sub IsItemPrefix { # $string ; returns sanitized value if parameter is in item prefix format (4 lowercase hex chars), 0 otherwise
# todo more validation
	WriteLog('IsItemPrefix()');

	my $string = shift;

	if (!$string) {
		return 0;
	}

	chomp $string;

	WriteLog('IsItemPrefix: $string = ' . $string);

	if ($string =~ m/^([0-9a-f]{8})$/) {
		WriteLog('IsItemPrefix: returning $1 = ' . $1);

		return $1; # returned sanitized value, in case it is needed
	}

	return 0;
} # IsItemPrefix()

sub IsMd5 { # returns 1 if parameter is md5 hash, 0 otherwise
	my $string = shift;

	if (!$string) {
		return 0;
	}

	if ($string =~ m/[a-fA-F0-9]{32}/) {
		return 1;
	} else {
		return 0;
	}
} # IsMd5()

sub IsDate {
	my $string = shift;

	if (!$string) {
		return 0;
	}

	if ($string =~ m/[0-9]{4}-[0-9]{2}-[0-9]{2}/) {
		return 1;
	} else {
		return 0;
	}
} # IsDate()

sub IsFingerprint { # returns valid fingerprint if parameter is a valid user fingerprint, 0 otherwise
# sub IsAuthor {
# sub IsPubKey {
	my $string = shift;

	if (!$string) {
		WriteLog('IsFingerprint: warning: $string is FALSE; caller = ' . join(',', caller));
		return 0;
	}

	if ($string =~ m/^([A-F0-9]{16})$/) {
		WriteLog('IsFingerprint(' . $string . ') = ' . $1 . '; caller = ' . join(',', caller));
		return $1;
	} else {
		WriteLog('IsFingerprint(' . $string . ') = FALSE; caller = ' . join(',', caller));
		return 0;
	}
} # IsFingerprint()

sub AddItemToConfigList { # Adds a line to a list stored in config
	# $configPath = reference to setting stored in config
	# $item = item to add to the list (appended to the file)

	my $configPath = shift;
	chomp($configPath);

	my $item = shift;
	chomp($item);

	# get existing list
	my $configList = GetConfig($configPath);

	if ($configList) {
		# if there is something already there, go through all this stuff
		my @configListAsArray = split("\n", $configList);

		foreach my $h (@configListAsArray) {
			# loop through each item on list and check if already exists
			if ($h eq $item) {
				# item already exists in list, nothing else to do
				return;
			}
		}

		#append to list
		$configList .= "\n";
		$configList .= $item;
		$configList = trim($configList);
		$configList .= "\n";
	} else {
		# if nothing is there, just add the requested item
		$configList = $item . "\n";
	}

	# remove any blank lines
	$configList =~ s/\n\n/\n/g;

	# put it back
	PutConfig($configPath, $configList);
} # AddItemToConfigList()

sub CheckForInstalledVersionChange {
	WriteLog('CheckForInstalledVersionChange() begin');

	my $lastVersion = GetConfig('current_version');
	my $currVersion = GetMyVersion();

	if (!$lastVersion) {
		$lastVersion = 0;
	}

	if (!$currVersion) {
		WriteLog('CheckForInstalledVersionChange: warning: sanity check failed, no $currVersion');
		return '';
	}

	if ($lastVersion ne $currVersion) {
		WriteLog("CheckForInstalledVersionChange: $lastVersion ne $currVersion, posting changelog");

		#my $serverKey = `gpg --list-keys hikeserver`;

		#WriteLog("gpg --list-keys CCEA3752");
		#WriteLog($serverKey);

		my $changeLogFilename = 'changelog_' . GetTime() . '.txt';
		#todo this should be a template;
		my $changeLogMessage =
			'Software Updated to Version ' . substr($currVersion, 0, 8) . '..' . "\n\n" .
			'Installed software version has changed from ' . $lastVersion . ' to ' . $currVersion . "\n\n";

		WriteLog('CheckForInstalledVersionChange: $changeLogFilename = ' . $changeLogFilename);

		if (!$lastVersion) {
			$lastVersion = 0;
		}

		if ($lastVersion) {
			#my $changeLogList = "Version has changed from $lastVersion to $currVersion";
			if ($lastVersion =~ m/^([0-9a-f]+)$/) {
				$lastVersion = $1;
			}
			if ($currVersion =~ m/^([0-9a-f]+)$/) {
				$currVersion = $1;
			}
			my $changeLogListCommand = "git log --oneline $lastVersion..$currVersion";
			my $changeLogList = ''; # `$changeLogListCommand`;
			$changeLogList = trim($changeLogList);
			$changeLogMessage .= "$changeLogList";
		} else {
			$changeLogMessage .= 'This is the initial install of the software, so no changelog is generated.';
			#$changeLogMessage .= 'No changelog will be generated because $lastVersion is false';
		}

		$changeLogMessage .= "\n\n#changelog";
		state $TXTDIR = GetDir('txt');
		my $newChangelogFile = "$TXTDIR/$changeLogFilename";

		WriteLog('About to PutFile() to $newChangelogFile = ' . $newChangelogFile);

		PutFile($newChangelogFile, $changeLogMessage);

		if (GetConfig('setting/admin/gpg/sign_git_changelog')) {
			ServerSign($newChangelogFile);
		}

		#my $changelogIndexResult = IndexFile($newChangelogFile);
		#if (!$changelogIndexResult) {
		#	WriteLog('CheckForInstalledVersionChange: warning: $changelogIndexResult was FALSE');
		#}

		PutConfig('current_version', $currVersion);

		return $currVersion;
	} else {
		return 0;
	}
} # CheckForInstalledVersionChange()

sub IsFileDeleted { # $file, $fileHash ; checks for file's hash in deleted.log and removes it if found
#todo rename to IsFileMarkedAsDeleted()
# only one or the other is required
	my $file = shift;
	WriteLog("IsFileDeleted($file)");

	if ($file && !-e $file) {
		# file already doesn't exist
		WriteLog('IsFileDeleted: file already gone, returning 1');
		return 1;
	}

	my $fileHash = shift;
	if (!$fileHash) {
		WriteLog('IsFileDeleted: $fileHash not specified, calling GetFileHash()');
		$fileHash = GetFileHash($file);
	}
	WriteLog("IsFileDeleted($file, $fileHash)");

	if ($file && $file =~ m/^([0-9a-zA-Z.\-_\/]+)$/) {
		$file = $1;
	} else {
		WriteLog('IsFileDeleted: warning: $file failed sanity check: $file = ' . $file);
		return '';
	}


	if ($fileHash && -e 'log/deleted.log' && GetFile('log/deleted.log') =~ $fileHash) {
		# if the file is present in deleted.log, get rid of it and its page, return
		# write to log
		WriteLog("IsFileDeleted: MATCHED! $fileHash exists in deleted.log, removing $file");

		# unlink the file itself
		if (-e $file) {
			if (GetConfig('setting/admin/index/unlink_deleted_files')) {
				if ($file =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
					my $fileSafe = $1;
					WriteLog("IsFileDeleted: warning: file exists, calling unlink($fileSafe)");

					my $LOGDIR = GetDir('log');
					if ( ! -d "$LOGDIR/deleted" ) {
						WriteLog('IsFileDeleted: mkdir(' . "$LOGDIR/deleted" . ')');
						mkdir("$LOGDIR/deleted");
					}

					if (-d "$LOGDIR/deleted") {
						#unlink($fileSafe); #todo -T
						my $justFilename = TrimPath($fileSafe);
						my $newFilename = "$LOGDIR/deleted/$justFilename";

						WriteLog('IsFileDeleted: rename(' . $fileSafe . ', ' . $newFilename . ')');

						rename($fileSafe, $newFilename);
					} else {
						WriteLog('IsFileDeleted: warning: $LOGDIR/deleted does not exist, even after attempt to create');
					}
				} else {
					WriteLog('IsFileDeleted: warning: did not unlink, sanity check failed on $file = ' . $file);
				}
			} else {
				WriteLog("IsFileDeleted: warning: file exists, would call unlink($file)");
			}
		}

		WriteLog("IsFileDeleted($file, $fileHash) = YES (via deleted.log)");
		WriteLog('IsFileDeleted: $fileHash = ' . $fileHash);

		my $htmlFilename = GetHtmlFilename($fileHash); # IsFileDeleted()

		if ($htmlFilename) {
			if ($htmlFilename =~ m/^([a-zA-Z0-9._\/]+\.html)/) {
				$htmlFilename = $1;

				state $HTMLDIR = GetDir('html');
				$htmlFilename = $HTMLDIR . '/' . $htmlFilename; #todo this could be a sub?
				if (-e $htmlFilename) {
					WriteLog('IsFileDeleted: warning: calling unlink: $htmlFilename = ' . $htmlFilename);
					unlink($htmlFilename);
				} else {
					WriteLog('IsFileDeleted: warning: file NOT exist: $htmlFilename = ' . $htmlFilename);
				}
			} else {
				WriteLog('IsFileDeleted: warning: failed sanity check: $htmlFilename = ' . $htmlFilename);
			}
		}

		return 1;
	} # $fileHash is in 'log/deleted.log'

	WriteLog("IsFileDeleted($file, $fileHash) = FALSE");

	return 0;
} # IsFileDeleted()

sub file_exists { # $file ; port of php file_exists()
	my $file = shift;
	if (!$file) {
		return 0;
	}
	if (-e $file && -f $file && !-d $file) {
		return 1;
	} else {
		return 0;
	}
	return 0; #unreachable code
} # file_exists()

sub GetItemDetokenedMessage { # $itemHash, $filePath ; retrieves item's message using cache or file path
	WriteLog('GetItemDetokenedMessage()');

	my $itemHash = shift;
	if (!$itemHash) {
		WriteLog('GetItemDetokenedMessage: warning: missing $itemHash');
		return '';
	}

	chomp $itemHash;

	if (!IsItem($itemHash)) {
		WriteLog('GetItemDetokenedMessage: warning: $itemHash failed sanity check');
		return '';
	}

	WriteLog("GetItemDetokenedMessage($itemHash)");

	my $message = '';
	my $messageCacheName = GetMessageCacheName($itemHash);

	if (!-e $messageCacheName) {
		WriteLog('GetItemDetokenedMessage: warning: NO FILE: $messageCacheName = ' . $messageCacheName);

	} else {
		WriteLog('GetItemDetokenedMessage: $message = GetFile(' . $messageCacheName . ');');
		$message = GetFile($messageCacheName);
		if (!$message) {
			WriteLog('GetItemDetokenedMessage: cache exists, but $message was missing');

			my $filePath = shift;
			if (!$filePath) {
				$filePath = '';
			}

			WriteLog('GetItemDetokenedMessage: $filePath = ' . $filePath);

			if (!$filePath) {
				$filePath = GetPathFromHash($itemHash);
				WriteLog('GetItemDetokenedMessage: missing $filePath, using GetPathFromHash(): ' . $filePath);
			}

			if (!$filePath || !-e $filePath) {
				$filePath = DBGetItemAttributeValue($itemHash, 'file_path');
				chomp $filePath;
				WriteLog('GetItemDetokenedMessage: missing $filePath, using DBGetItemAttributeValue(): ' . $filePath);
			}

			WriteLog('GetItemDetokenedMessage: $filePath = ' . $filePath);

			if ($filePath && -e $filePath) {
				WriteLog('GetItemDetokenedMessage = GetFile(' . $filePath . ');');
				$message = GetFile($filePath);
			} else {
				WriteLog('GetItemDetokenedMessage: warning: no $filePath or file is missing');
				$message = '';
			}
		}
	}

	if (!$message) {
		WriteLog('GetItemDetokenedMessage: warning: $message is false');
	}

	return $message;
} # GetItemDetokenedMessage()

sub GetItemMeta { # retrieves item's metadata
	# $itemHash, $filePath

	WriteLog('GetItemMeta()');

	my $itemHash = shift;
	if (!$itemHash) {
		return;
	}

	chomp $itemHash;
	if (!IsItem($itemHash)) {
		return;
	}

	WriteLog("GetItemMeta($itemHash)");

	my $filePath = shift;
	if (!$filePath) {
		return;
	}

	chomp $filePath;

	if (-e $filePath) {
		my $fileHash = GetFileHash($filePath);

		if ($fileHash eq $filePath) {
			my $metaFileName = $filePath . '.nfo';

			if (-e $metaFileName) {
				my $metaText;

				$metaText = GetFile($metaFileName);

				return $metaText;
			}
			else {
				return; # no meta file
			}
		} else {
			WriteLog('GetItemMeta: WARNING: called with hash which did not match file hash');

			return;
		}
	} else {
		return; # file doesn't exist
	}
} # GetItemMeta()

sub GetPrefixedUrl { # returns url with relative prefix
	my $url = shift;
	chomp $url;
	return $url;
} # GetPrefixedUrl()

sub UpdateUpdateTime { # updates cache/system/last_update_time, which is used by the stats page
	my $lastUpdateTime = GetTime();
	PutCache("system/last_update_time", $lastUpdateTime);
} # UpdateUpdateTime()

sub RemoveEmptyDirectories { #looks for empty directories under $path and removes them
	my $path = shift;
	#todo probably more sanitizing
	$path = trim($path);
	if (!$path) {
		return;
	}
	#system('find $path -type d -empty -delete'); #todo uncomment when bugs fixed
} # RemoveEmptyDirectories()

sub GetFileHashPath { # $file ; Returns text file's standardized path given its filename
# GetFilename {
	# e.g. /01/23/0123abcdef0123456789abcdef0123456789a.txt
	my $file = shift;

	# file should exist and not be a directory
	if (!-e $file || -d $file) {
		WriteLog('GetFileHashPath: warning: $file sanity check failed, $file = ' . $file . '; caller = ' . join(',', caller));
		return '';
	}
	# WriteLog("GetFileHashPath($file)");

	if ($file) {
		WriteLog('GetFileHashPath: $file = ' . $file);
		my $fileHash = GetFileHash($file);
		#my $fileHash = GetFileMessageHash($file); #todo
		my $fileHashPath = GetPathFromHash($fileHash);
		WriteLog('GetFileHashPath: $file = ' . $file . '; $fileHash = ' . $fileHash . '; $fileHashPath = ' . $fileHashPath);

		return $fileHashPath;
	} else {
		WriteLog('GetFileHashPath: warning: $file was FALSE; caller = ' . join(',', caller));
		return '';
	}
} # GetFileHashPath()

sub GetPathFromHash { # guesses path of text file based on hash
# sub GetFilePath {
# sub GetHashPath {

	# relies on config/admin/organize_files = 1
	#todo fix
	my $fileHash = shift;
	chomp $fileHash;

	if (!$fileHash) {
		WriteLog('GetPathFromHash: warning: $fileHash is false');
		return '';
	}

	chomp $fileHash;
	WriteLog('GetPathFromHash: $fileHash = '. $fileHash);

	state $TXTDIR = GetDir('txt');

	WriteLog('GetPathFromHash: $TXTDIR = '. $TXTDIR);

#	state $TXTDIR = GetDir('txt');


	if ($fileHash =~ m/^([0-9a-f]+)$/) { #todo should this be unlimited length?
		$fileHash = $1;
		WriteLog('GetPathFromHash: $fileHash sanity check passed: ' . $fileHash);
	} else {
		WriteLog('GetPathFromHash: warning: $fileHash sanity check failed!');
		return '';
	}

	if (!-e $TXTDIR . '/' . substr($fileHash, 0, 2)) {
		WriteLog('GetPathFromHash: mkdir ' . $TXTDIR . '/' . substr($fileHash, 0, 2));
		system('mkdir ' . $TXTDIR . '/' . substr($fileHash, 0, 2));
	}

	if (!-e $TXTDIR . '/' . substr($fileHash, 0, 2) . '/' . substr($fileHash, 2, 2)) {
		system('mkdir ' . $TXTDIR . '/' . substr($fileHash, 0, 2) . '/' . substr($fileHash, 2, 2));
	}

	my $fileHashSubDir = substr($fileHash, 0, 2) . '/' . substr($fileHash, 2, 2);

	if ($fileHash) {
		my $fileHashPath = $TXTDIR . '/' . $fileHashSubDir . '/' . $fileHash . '.txt';
		WriteLog('GetPathFromHash: $fileHashPath = ' . $fileHashPath);
		return $fileHashPath;
	}
} # GetPathFromHash()

sub array_unique { # @array ; returns array of unique items from @array
# modeled after php's array_unique()
	my @list = @_;
	my %finalList;
	foreach(@list) {
		$finalList{$_} = 1; # delete double values
	}
	return (keys(%finalList));
} # array_unique()

sub in_array { # $needle, @haystack ; emulates php's in_array()
# sub array_contains {
	my $needle = shift;
	my @haystack = @_;

#	if($needle ~~ @haystack) {
#		return 1;
#	} else {
#		return 0;
#	}
	WriteLog('in_array: caller = ' . join(',', caller));

	my %params = map { $_ => 1 } @haystack;
	if(exists($params{$needle})) {
		WriteLog('in_array: $needle = ' . $needle . '; @haystack = ' . join(',', @haystack) . ' = 1');
		return 1;
	} else {
		WriteLog('in_array: $needle = ' . $needle . '; @haystack = ' . join(',', @haystack) . ' = 0');
		return 0;
	}
} # in_array()

sub Sha1Test {
	print "\n";
	print GetFileHash('utils.pl');
	print "\n";
	print(`sha1sum utils.pl | cut -f 1 -d ' '`);
	# print "\n";
	print(`php -r "print(sha1_file('utils.pl'));"`);
	print "\n";
} # Sha1Test()

sub GetPasswordLine { # $username, $password ; returns line for .htpasswd file
	my $username = shift;
	chomp $username;

	my $password = shift;
	chomp $password;

	return $username.":".crypt($password,$username)."\n";
} # GetPasswordLine()

sub VerifyThirdPartyAccount {
	my $fileHash = shift;
	my $thirdPartyUrl = shift;
} # verify token

sub ProcessTextFile { # $file ; add new text file to index
	my $file = shift;
	if ($file eq 'flush') {
		IndexFile('flush');
	}
	my $relativePath = File::Spec->abs2rel($file, $SCRIPTDIR); #todo this shouldn't have a ::
	if ($file ne $relativePath) {
		$file = $relativePath;
	}
	my $addedTime = GetTime2();
	WriteLog('ProcessTextFile: $file = ' . $file . '; $addedTime = ' . $addedTime);

	# get file's hash from git
	my $fileHash = GetFileHash($file);
	if (!$fileHash) {
		return 0;
	}

	WriteLog('ProcessTextFile: $fileHash = ' . $fileHash);

	# if deletion of this file has been requested, skip
	if (IsFileDeleted($file, $fileHash)) {
		WriteLog('ProcessTextFile: IsFileDeleted() returned true, skipping');
		WriteLog('ProcessTextFile: return 0');

		return 0;
	}

	if (GetConfig('admin/organize_files')) {
		my $fileNew = OrganizeFile($file); # ProcessTextFile()
		if ($fileNew eq $file) {
			WriteLog('ProcessTextFile: $fileNew eq $file');
		} else {
			WriteLog('ProcessTextFile: changing $file to new value per OrganizeFile()');
			$file = $fileNew;
			WriteLog('ProcessTextFile: $file = ' . $file);
		}
	} else {
		WriteLog("ProcessTextFile: organize_files is off, continuing");
	}

	if (!GetCache('indexed/' . $fileHash)) { #todo this should be replaced with IsFileAlreadyIndexed()
		WriteLog('ProcessTextFile: ProcessTextFile(' . $file . ') not in cache/indexed, calling IndexFile');

		IndexFile($file);
		IndexFile('flush');
	} else {
		# return 0 so that this file is not counted
		WriteLog('ProcessTextFile: already indexed ' . $fileHash . ', return 0');
		return 0;
	}

	WriteLog('ProcessTextFile: return ' . $fileHash);
	return $fileHash;

	# run commands to
	#	  add changed file to git repo
	#    commit the change with message 'hi' #todo
	#    cd back to pwd


	#		# below is for debugging purposes
	#
	#		my %queryParams;
	#		$queryParams{'where_clause'} = "WHERE file_hash = '$fileHash'";
	#
	#		my @files = DBGetItemList(\%queryParams);
	#
	#		WriteLog("Count of new items for $fileHash : " . scalar(@files));

} # ProcessTextFile()

sub EnsureDirsThatShouldExist { # creates directories expected later
# sub EnsureDirs {
	WriteLog('EnsureDirsThatShouldExist() begin');
	# make a list of some directories that need to exist
	state $HTMLDIR = GetDir('html');
	state $CACHEDIR = GetDir('cache');
	state $CONFIGDIR = GetDir('config');

	state $cacheVersion = GetMyCacheVersion();

	WriteLog('EnsureDirsThatShouldExist: $HTMLDIR = ' . $HTMLDIR . '; $CACHEDIR = ' . $CACHEDIR . '; $CONFIGDIR = ' . $CONFIGDIR);

	#todo this should be ... improved upon
	my @dirsThatShouldExist = (
		"log",
		"$HTMLDIR",
		"$HTMLDIR/utils",
		"$HTMLDIR/txt",
		"$HTMLDIR/image",
		"$HTMLDIR/cpp",
		"$HTMLDIR/py",
		"$HTMLDIR/perl",
		"$HTMLDIR/mp4",
		"$HTMLDIR/thumb", #thumbnails
		"$CACHEDIR/$cacheVersion", #ephemeral data
		"$HTMLDIR/author",
		"$HTMLDIR/dialog/replies",
		"$HTMLDIR/action",
		"$HTMLDIR/tag", #tag items for tags
		"$CONFIGDIR",
		"$CONFIGDIR/template",
		"$CONFIGDIR/setting/admin",
		"$CONFIGDIR/setting/admin/php",
		"$CONFIGDIR/setting/admin/php/post",
		"$CONFIGDIR/setting/admin/php/upload",
		"$HTMLDIR/upload", #uploaded files go here
		"$HTMLDIR/error", #error pages
		"$SCRIPTDIR/once" #used for registering things which should only happen once e.g. scraping
	);

	push @dirsThatShouldExist, $CACHEDIR;
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion;
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/key';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/file';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/avatar';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/message';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/gpg';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/gpg_message';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/gpg_stderr';
	push @dirsThatShouldExist, $CACHEDIR . '/' . $cacheVersion . '/response';

	# create directories that need to exist
	foreach my $dir (@dirsThatShouldExist) {
		if ($dir =~ m/^([a-zA-Z0-9_\/]+)$/) {
			$dir = $1;
		} else {
			WriteLog('EnsureDirsThatShouldExist: warning: sanity check failed during @dirsThatShouldExist');
			WriteLog('EnsureDirsThatShouldExist: $dir = ' . $dir);
			next;
		}
		if (-e $dir && !-d $dir) {
			WriteLog('EnsureDirsThatShouldExist: warning: file exists where directory should be: ' . $dir);
			next;
		}
		if (!-d $dir && !-e $dir) {
			WriteLog('EnsureDirsThatShouldExist: directory does not exist, creating: ' . $dir);
			mkdir $dir;
		}
		if (!-e $dir || !-d $dir) {
			WriteLog('EnsureDirsThatShouldExist: warning: $dir should exist, but does not: $dir = ' . $dir);
		}
	}
} # EnsureDirsThatShouldExist()

sub PopulateResource { # populate resources needed by all active themes
# this is a rather naive way of doing it, but it works for now
# searches for each resource in active themes and copies to html root if found
	my $themesValue = GetConfig('theme');
	$themesValue =~ s/[\s]+/ /g;
	my @activeThemes = split(' ', $themesValue);

	#my @activeThemes = split("\n", GetConfig('theme'));
	my @resources = split("\n", `find default/res`);

	use File::Basename;
	use File::Copy qw(copy);
	state $htmlDir = GetDir('html');

	foreach my $themeName (@activeThemes) {
		foreach my $resource (@resources) {
			if ($resource =~ m/^([0-9a-zA-Z.\/]+)$/) {
				$resource = $1;
				if (-e $resource && !-d $resource) {
					my $resourceFilename = basename($resource);

					if ($themeName =~ m/^([0-9a-zA-Z]+)$/) {
						$themeName = $1;

						if ($resourceFilename =~ m/^([0-9a-zA-Z.]+)$/) {
							$resourceFilename = $1;

							if (`grep -ri "$resourceFilename" default/theme/$themeName`) {
								#print $resourceFilename . "-" . $themeName . "\n";
								copy($resource, $htmlDir);
							}
						}
					}
				}
			}
		}
	}
} # PopulateResource()

sub StorePostUrl {
	# this exists to synchronize two redundant ways of getting the url to post things
	# config/setting/admin/post/post_url and GetTargetPath('post')
	if (GetConfig('setting/admin/post/post_url') ne GetTargetPath('post')) {
		WriteLog('StorePostUrl: warning: config/setting/admin/post/post_url did not match GetTargetPath(post), updating it');
		PutConfig('setting/admin/post/post_url', GetTargetPath('post'));
	}
}

StorePostUrl();

EnsureDirsThatShouldExist();

CheckForInstalledVersionChange();

my $utilsPl = 1;

1;



===


			return GetDialogX('
				<fieldset>
					<p>This space reserved for future content.</p>
					<p class=advanced>Query: ' . $flags{'page_query'} . '</p>
				</fieldset>
			', $title);



===


						if (
							isset($_GET['chkUpdate']) &&
							isset($_GET['btnUpdate'])
						) {
							$updateStartTime = time();
							DoUpdate();
							$fileUrlPath = '';
							$updateFinishTime = time();
							$updateDuration = $updateFinishTime - $updateStartTime;

							RedirectWithResponse('/stats.html', "Update finished! <small>in $updateDuration"."s</small>");
						}



						#
#sub GetServerKey { # Returns server's public key, 0 if there is none
#	state $serversKey;
#
#	if ($serversKey) {
#		return $serversKey;
#	}
#
#	state $TXTDIR = GetDir('txt');
#
#	if (-e "$TXTDIR/server.key.txt") { #server's pub key should reside here
#		my %adminsInfo = GpgParse("$TXTDIR/server.key.txt");
#
#		if ($adminsInfo{'isSigned'}) {
#			if ($adminsInfo{'key'}) {
#				$serversKey = $adminsInfo{'key'};
#
#				return $serversKey;
#			} else {
#				return 0;
#			}
#		} else {
#			return 0;
#		}
#	} else {
#		return 0;
#	}
#
#	WriteLog('GetServerKey: warning: fallthrough!');
#	return 0;
#} # GetServerKey()





						if ($tokenFound{'token'} eq 'operator_pleace') {
							push @indexMessageLog, 'found operator request';
						}


							if (scalar(@files)) {
		foreach my $row (@files) {
			my $file = $row->{'file_path'};

			if ($pageType eq 'tag' && $pageParam) {
				$row->{'vote_return_to'} = '/tag/' . $pageParam . '.html'; #todo unhardcode
			}

			WriteLog('GetReadPage: calling DBAddItemPage (1)'); #GetReadPage()
			DBAddItemPage($row->{'file_hash'}, $pageType, $pageParam);

			if ($file && -e $file) {
				my $itemHash = $row->{'file_hash'};
				my $gpgKey = $row->{'author_key'};
				my $isSigned;
				if ($gpgKey) {
					$isSigned = 1;
				} else {
					$isSigned = 0;
				}

				my $alias;
				my $isAdmin = 0;
				my $message;
				my $messageCacheName = GetMessageCacheName($itemHash);

				WriteLog('GetReadPage: $row->{file_hash} = ' . $row->{'file_hash'});
				if ($gpgKey) {
					WriteLog('GetReadPage: $message = GetFile('.$messageCacheName.')');
					$message = GetFile($messageCacheName);
				} else {
					WriteLog('GetReadPage: $message = GetFile('.$file.')');
					$message = GetFile($file);
				}
				if (!$message) {
					WriteLog('GetReadPage: warning: $message is false!');
				} else {
					WriteLog('GetReadPage: $message is true!');
				}

				#$message = FormatForWeb($message);
				my $signedCss = "";
				if ($isSigned) {
					if (IsAdmin($gpgKey)) {
						$isAdmin = 1;
					}
					if ($isAdmin) {
						$signedCss = "signed admin";
					} else {
						$signedCss = "signed";
					}
				} # $isSigned

				#todo $alias = GetAlias($gpgKey);

				$alias = HtmlEscape($alias);

				my $itemTemplate = '';
				if ($message) {
	#				$row->{'show_quick_vote'} = 1;
					$row->{'trim_long_text'} = 1;
					$row->{'format_avatars'} = 1;

					WriteLog('GetReadPage: GetItemTemplate($row)');

					$itemTemplate = GetItemTemplate($row); # GetReadPage() $message
				}
				else {
					$itemTemplate = GetItemTemplate($row); # GetReadPage() missing $message
					WriteLog('GetReadPage: warning: missing $message');
				}

				if ($itemComma eq '') {
					#$itemComma = '<br><hr size=7>';
					$itemComma = ' ';
				} else {
					$itemTemplate = $itemComma . $itemTemplate;
				}

				$txtIndex .= $itemTemplate;
			} # $file
			else {
				WriteLog('GetReadPage: warning: file not found, $file = ' . $file);
			}
		} # foreach my $row (@files)
	} # if (scalar(@files))
	else {
		$txtIndex .= GetDialogX('<p>No items found to display on this page.</p>', 'No results');
	}





sub GetTopItemsPage { # returns page with top items listing
	WriteLog("GetTopItemsPage()");

	my $htmlOutput = ''; # stores the html

	my $title = 'Topics';
	my $titleHtml = 'Topics';

	$htmlOutput = GetPageHeader('read'); # <html><head>...</head><body>
	$htmlOutput .= GetTemplate('html/maincontent.template'); # where "skip to main content" goes

	$htmlOutput .= GetItemListing('top');

	$htmlOutput .= GetPageFooter('read'); # </body></html>

	if (GetConfig('admin/js/enable')) {
		# add necessary js
		$htmlOutput = InjectJs($htmlOutput, qw(settings voting timestamp profile avatar utils));
	}

	return $htmlOutput;
} # GetTopItemsPage()


	if (scalar(@files)) {
		foreach my $row (@files) {
			my $file = $row->{'file_path'};

			if ($pageType eq 'tag' && $pageParam) {
				$row->{'vote_return_to'} = '/tag/' . $pageParam . '.html'; #todo unhardcode
			}

			WriteLog('GetReadPage: calling DBAddItemPage (1)'); #GetReadPage()
			DBAddItemPage($row->{'file_hash'}, $pageType, $pageParam);

			if ($file && -e $file) {
				my $itemHash = $row->{'file_hash'};
				my $gpgKey = $row->{'author_key'};
				my $isSigned;
				if ($gpgKey) {
					$isSigned = 1;
				} else {
					$isSigned = 0;
				}

				my $alias;
				my $isAdmin = 0;
				my $message;
				my $messageCacheName = GetMessageCacheName($itemHash);

				WriteLog('GetReadPage: $row->{file_hash} = ' . $row->{'file_hash'});
				if ($gpgKey) {
					WriteLog('GetReadPage: $message = GetFile('.$messageCacheName.')');
					$message = GetFile($messageCacheName);
				} else {
					WriteLog('GetReadPage: $message = GetFile('.$file.')');
					$message = GetFile($file);
				}
				if (!$message) {
					WriteLog('GetReadPage: warning: $message is false!');
				} else {
					WriteLog('GetReadPage: $message is true!');
				}

				#$message = FormatForWeb($message);
				my $signedCss = "";
				if ($isSigned) {
					if (IsAdmin($gpgKey)) {
						$isAdmin = 1;
					}
					if ($isAdmin) {
						$signedCss = "signed admin";
					} else {
						$signedCss = "signed";
					}
				} # $isSigned

				#todo $alias = GetAlias($gpgKey);

				$alias = HtmlEscape($alias);

				my $itemTemplate = '';
				if ($message) {
	#				$row->{'show_quick_vote'} = 1;
					$row->{'trim_long_text'} = 1;
					$row->{'format_avatars'} = 1;

					WriteLog('GetReadPage: GetItemTemplate($row)');

					$itemTemplate = GetItemTemplate($row); # GetReadPage() $message
				}
				else {
					$itemTemplate = GetItemTemplate($row); # GetReadPage() missing $message
					WriteLog('GetReadPage: warning: missing $message');
				}

				if ($itemComma eq '') {
					#$itemComma = '<br><hr size=7>';
					$itemComma = ' ';
				} else {
					$itemTemplate = $itemComma . $itemTemplate;
				}

				$txtIndex .= $itemTemplate;
			} # $file
			else {
				WriteLog('GetReadPage: warning: file not found, $file = ' . $file);
			}
		} # foreach my $row (@files)
	} # if (scalar(@files))
	else {
		$txtIndex .= GetDialogX('<p>No items found to display on this page.</p>', 'No results');
	}





#
##require('default/template/perl/config.pl');
#if (-e './config/template/perl/config.pl') {
#	require('./config/template/perl/config.pl');
#} else {
#	if (-e './default/template/perl/config.pl') {
#		use File::Copy;
#		copy('./default/template/perl/config.pl', './config/template/perl/config.pl');
#		if (-e './config/template/perl/config.pl') {
#			require('./config/template/perl/config.pl');
#		} else {
#			exit; #todo warning
#		}
#	} else {
#		exit; #todo warning
#	}
#}

#
#        my @queryChoices;
#        push @queryChoices, 'read';
#        push @queryChoices, 'compost';
#        push @queryChoices, 'chain';

#
#		$html .= '<span class=advanced><form action=/post.html>'; #todo templatify
#		$html .= GetDialogX($queryWindowContents, 'View Selector');
#		$html .= '</form></span>';


# this is from GetPageLinks()
		#	my $beginExpando;
		#	my $endExpando;
		#
		#	if ($lastPageNum > 15) {
		#		if ($currentPageNumber < 5) {
		#			$beginExpando = 0;
		#		} elsif ($currentPageNumber < $lastPageNum - 5) {
		#			$beginExpando = $currentPageNumber - 2;
		#		} else {
		#			$beginExpando = $lastPageNum - 5;
		#		}
		#
		#		if ($currentPageNumber < $lastPageNum - 5) {
		#			$endExpando = $lastPageNum - 2;
		#		} else {
		#			$endExpando = $currentPageNumber;
		#		}
		#	}



		if (0) {
			#todo
			my @queryChoices = split("\n", `ls config/template/query`); #todo sanity
			my $querySelectorWidget = GetWidgetSelect('query', $pageName, @queryChoices);
			my $button = '<input type=submit value=Go>';
			$queryWindowContents .= '<label for=query>' . $querySelectorWidget . '</label> ' . $button; #todo templatify
		}




		if (
			$pageType eq 'item'
		) {



			#print "\n          Hare Krishna, Hare Krishna, Krishna Krishna Hare Hare,";
			#print "\n                Hare Rama, Hare Rama, Rama Rama Hare Hare.";



if (GetConfig('setting/html/menu_advanced')) {
	$topMenuTemplate = '<span class=advanced>' . $topMenuTemplate . '</span>';
}



# if (GetConfig('admin/js/enable') && GetConfig('admin/js/dragging')) {
# 	$tagLink = AddAttributeToTag(
# 		$tagLink,
# 		'a ',
# 		'onclick',
# 		"
# 			if (
# 				(!(window.GetPrefs) || GetPrefs('draggable_spawn')) &&
# 				(window.FetchDialogFromUrl) &&
# 				document.getElementById
# 			) {
# 				if (document.getElementById('top_$tag')) {
# 					SetActiveDialog(document.getElementById('top_$tag'));
# 					return false;
# 				} else {
# 					return FetchDialogFromUrl('/dialog/tag/$tag');
# 				}
# 			}
# 		"
# 	);
# }
#



#sub FormatMessage { # $message, \%file
#	my $message = shift;
#	my %file = %{shift @_}; #todo should be better formatted
#	#todo sanity checks
#
#	if ($file{'remove_token'}) {
#		my $removeToken = $file{'remove_token'};
#		$message =~ s/$removeToken//g;
#		$message = trim($message);
#	}
#
#	my $isTextart = 0;
#	my $isSurvey = 0;
#	my $isTooLong = 0;
#
#	if ($file{'labels_list'}) {
#		# if there is a list of tags, check to see if there is a 'textart' tag
#
#		# split the tags list into @itemTags array
#		my @itemTags = split(',', $file{'labels_list'});
#
#		# loop through all the tags in @itemTags
#		while (scalar(@itemTags)) {
#			my $thisTag = pop @itemTags;
#			if ($thisTag eq 'textart') {
#				$isTextart = 1; # set isTextart to 1 if 'textart' tag is present
#			}
#			if ($thisTag eq 'survey') {
#				$isSurvey = 1; # set $isSurvey to 1 if 'survey' tag is present
#			}
#		}
#	}
#
#	if ($isTextart) {
#		# if textart, format with extra spacing to preserve character arrangement
#		#$message = TextartForWeb($message);
#		$message = TextartForWeb(GetFile($file{'file_path'}));
#	} else {
#		# if not textart, just escape html characters
#		WriteLog('FormatMessage: calling FormatForWeb');
#		$message = FormatForWeb($message);
#	}
#
#	return $message;
#} # FormatMessage()


							if (GetConfig('setting/admin/index/multiple_parent_means_no_parent') && scalar(@itemParents) > 1) {




#			if (!-e "$HTMLDIR/thumb/squared_42_$fileHash.gif") {
#				my $convertCommand = "convert \"$fileShellEscaped\" -crop 42x42 -strip $HTMLDIR/thumb/squared_42_$fileHash.gif";
#				WriteLog('IndexImageFile: ' . $convertCommand);
#
#				my $convertCommandResult = `$convertCommand`;
#				WriteLog('IndexImageFile: convert result: ' . $convertCommandResult);
#			}

	# # make 48x48 thumbnail
	# if (!-e "$HTMLDIR/thumb/thumb_48_$fileHash.gif") {
	# 	my $convertCommand = "convert \"$file\" -thumbnail 48x48 -strip $HTMLDIR/thumb/thumb_48_$fileHash.gif";
	# 	WriteLog('IndexImageFile: ' . $convertCommand);
	#
	# 	my $convertCommandResult = `$convertCommand`;
	# 	WriteLog('IndexImageFile: convert result: ' . $convertCommandResult);
	# }

#			if (!-e "$HTMLDIR/thumb/squared_512_$fileHash.gif") {
#				my $convertCommand = "convert \"$fileShellEscaped\" -crop 512x512 -strip $HTMLDIR/thumb/squared_512_$fileHash.gif";
#				WriteLog('IndexImageFile: ' . $convertCommand);
#
#				my $convertCommandResult = `$convertCommand`;
#				WriteLog('IndexImageFile: convert result: ' . $convertCommandResult);
#			}

		#my $convertCommand = "convert \"$fileShellEscaped\" -scale 5% -blur 0x25 -resize 5000% -colorspace Gray -blur 0x8 -thumbnail 512x512 -strip $HTMLDIR/thumb/thumb_512_$fileHash.gif";

#			if (!-e "$HTMLDIR/thumb/squared_800_$fileHash.gif") {
#				my $convertCommand = "convert \"$fileShellEscaped\" -crop 800x800 -strip $HTMLDIR/thumb/squared_800_$fileHash.gif";
#				WriteLog('IndexImageFile: ' . $convertCommand);
#
#				my $convertCommandResult = `$convertCommand`;
#				WriteLog('IndexImageFile: convert result: ' . $convertCommandResult);
#			}


	# # make 1024x1024 thumbnail
	# if (!-e "$HTMLDIR/thumb/thumb_1024_$fileHash.gif") {
	# 	my $convertCommand = "convert \"$file\" -thumbnail 1024x1024 -strip $HTMLDIR/thumb/thumb_1024_$fileHash.gif";
	# 	WriteLog('IndexImageFile: ' . $convertCommand);
	#
	# 	my $convertCommandResult = `$convertCommand`;
	# 	WriteLog('IndexImageFile: convert result: ' . $convertCommandResult);
	# }




if (GetConfig('setting/admin/js/enable') && GetConfig('setting/admin/js/dragging')) {
	#todo add more things to this template and make it not hard-coded
	$htmlStart = str_replace('</head>', '<script src="/dragging.js"></script></head>', $htmlStart);
}






# if (!$statusBar && index($file{'labels_list'}, 'speaker') != -1) {
# 	#$statusBar = $file{'item_title'};
# }



if (GetConfig('admin/expo_site_mode') && $file{'labels_list'} && index($file{'labels_list'}, 'sponsor') != -1) {
	$statusBar = '<a href="' . $file{'item_title'} . '" target=_blank>' . $file{'item_title'} . '</a>';
}




if (GetConfig('admin/expo_site_mode') && !GetConfig('admin/expo_site_edit')) { #expo
	WriteLog('GetItemTemplate: $statusBar expo_site_mode override activated');
	if ($file{'item_title'} =~ m/^http/) {
		my $permalinkHtml = $file{'item_title'};
		$statusBar =~ s/\$permalinkHtml/$permalinkHtml/g;
	}

	if ($file{'no_permalink'}) {
		$statusBar = $file{'item_title'};
	}
} else {



	my @timestampsArray; #todo initialize?



push @timestampsArray, $iaValue;


if (1) { # todo attribute_statistics flag
	$itemAttributesTable .= '<tr><td>';
	$itemAttributesTable .= 'Timestamp Statistics'; #todo GetString('item_attribute/item_score');
	$itemAttributesTable .= '</td><td>';
	$itemAttributesTable .= join(',', @timestampsArray);# todo'';
	$itemAttributesTable .= '</td></tr>';
}

if (1) {
	$itemAttributesTable .= '<tr><td>';
	$itemAttributesTable .= 'Hash Collisions'; #todo GetString('item_attribute/item_score');
	$itemAttributesTable .= '</td><td>';
	$itemAttributesTable .= '0'; #$file{'item_score'};
	$itemAttributesTable .= '</td></tr>';
}




sub GetSecondsHtml {# takes number of seconds as parameter, returns the most readable approximate time unit
	# 5 seconds = 5 seconds
	# 65 seconds = 1 minute
	# 360 seconds = 6 minutes
	# 3600 seconds = 1 hour
	# etc

	my $seconds = shift;

	if (!$seconds) {
		return;
	}

	chomp $seconds;

	my $secondsString = $seconds;

	if ($secondsString >= 60) {
		$secondsString = $secondsString / 60;

		if ($secondsString >= 60 ) {
			$secondsString = $secondsString / 60;

			if ($secondsString >= 24) {
				$secondsString = $secondsString / 24;

				if ($secondsString >= 365) {
					$secondsString = $secondsString / 365;

					$secondsString = floor($secondsString) . ' years';
				}
				elsif ($secondsString >= 30) {
					$secondsString = $secondsString / 30;

					$secondsString = floor($secondsString) . ' months';
				}
				else {
					$secondsString = floor($secondsString) . ' days';
				}
			}
			else {
				$secondsString = floor($secondsString) . ' hours';
			}
		}
		else {
			$secondsString = floor($secondsString) . ' minutes';
		}
	} else {
		$secondsString = floor($secondsString) . ' seconds';
	}
} # GetSecondsHtml()



sub GetVersionPage { # returns html with version information for $version (git commit id)
	#todo refactor to be a call to GetItemPage
	my $version = shift;

	if (!IsSha1($version)) {
		return;
	}

	my $txtPageHtml = '';

	my $pageTitle = "Information page for version $version";

	my $htmlStart = GetPageHeader('version');

	$txtPageHtml .= $htmlStart;

	$txtPageHtml .= GetTemplate('html/maincontent.template');

	my $versionInfo = GetTemplate('html/versioninfo.template');
	my $shortVersion = substr($version, 0, 8);

	$versionInfo =~ s/\$version/$version/g;
	$versionInfo =~ s/\$shortVersion/$shortVersion/g;

	$txtPageHtml .= $versionInfo;

	$txtPageHtml .= GetPageFooter('version');

	$txtPageHtml = InjectJs($txtPageHtml, qw(settings avatar));

	return $txtPageHtml;
} # GetVersionPage()



sub MakeInputExpandable {
#		if (GetConfig('admin/js/enable')) {
#			$html = AddAttributeToTag($html, 'input name=comment', onpaste, "window.inputToChange=this; setTimeout('ChangeInputToTextarea(window.inputToChange); return true;', 100);");
#		} #input_expand_into_textarea

#todo
}


sub MakePage2 {
	my @arg = @_;
	my $useThreads = 0;

	WriteLog('MakePage: $useThreads = ' . $useThreads);

	if ($useThreads) {
		my $thr = threads->create('MakePage2', @arg);
		my $result = $thr->join();
		return $result;
	} else {
		my $result = MakePage2(@arg);
		return $result;
	}
}




WriteMessage('=======================================');
WriteMessage('   Welcome! Please make a selection:   ');
WriteMessage('=======================================');
WriteMessage(' [0] Install dependency packages       ');
WriteMessage(' [1] Local use for taking notes        ');
WriteMessage(' [2] Local development of application  ');
WriteMessage(' [3] Local use, static HTML output     ');
WriteMessage(' [4] Deploy on private server          ');
WriteMessage(' [5] Deploy on public server           ');
WriteMessage(' [6] Deploy with minimal options       ');
WriteMessage(' [7] Deploy with TOR                   ');
WriteMessage('=======================================');

my $installType = GetChoice('Enter a number 1-7: ');



#
#	my $schemaHash = `sqlite3 "$SqliteDbName" ".schema" | sha1sum | awk '{print \$1}' > config/setting/sqlite3_schema_hash`;
#	# this can be used as schema "version"
#	# only problem is first time it changes, now cache must be regenerated
#	# so need to keep track of the previous one and recursively call again or copy into new location



sub WriteIndexedConfig { # writes config indexed in database into config/
# WRITES CONFIG INDEXED IN DATABASE INTO CONFIG/
# this should ideally filter for the "latest" config value in database
# but that's more challenging than i thought using sql
# so instead of that, it filters here, and only prints the topmost value
# for each key

	WriteLog('WriteIndexedConfig() begin');
	WriteLog('WriteIndexedConfig: warning: it is off pending some testing');
	return '';

	# author must be admin or must have completed puzzle
	my @indexedConfig = SqliteQueryHashRef('indexed_config');
	my %configDone;

	shift @indexedConfig;

	foreach my $configLineReference (@indexedConfig) {
		my %configLine = %{$configLineReference};

		my $configLineKey = $configLine{'key'};
		my $configLineValue = $configLine{'value'};
		my $configLineResetFlag = $configLine{'reset_flag'};

		if (!$configDone{$configLineKey}) {
			if ($configLineResetFlag) {
				ResetConfig($configLineKey);
			} else {
				PutConfig($configLineKey, $configLineValue);
			}
			$configDone{$configLineKey} = 1;
		}
	}


#	WriteLog('WriteIndexedConfig: warning: it is skipped, because needs fixing');
#	WriteMessage('WriteIndexedConfig() skipped');
#	print('WriteIndexedConfig() skipped');
#	return '';
#
#	my @indexedConfig = DBGetLatestConfig();
#
#	WriteLog('WriteIndexedConfig: scalar(@indexedConfig) = ' . scalar(@indexedConfig));
#
#	foreach my $configLine(@indexedConfig) {
#		my $configKey = $configLine->{'key'};
#		my $configValue = $configLine->{'value'};
#
#		chomp $configValue;
#		$configValue = trim($configValue);
#
#		if (IsSha1($configValue)) {
#			WriteLog('WriteIndexedConfig: Looking up hash: ' . $configValue);
#
#			if (-e 'cache/' . GetMyCacheVersion() . "/message/$configValue") { #todo make it cleaner
#				WriteLog('WriteIndexedConfig: success: lookup of $configValue = ' . $configValue);
#				$configValue = GetCache("message/$configValue");#todo should this be GetItemMessage?
#			} else {
#				WriteLog('WriteIndexedConfig: warning: no result for lookup of $configValue = ' . $configValue);
#			}
#		}
#
#		if ($configLine->{'reset_flag'}) {
#			ResetConfig($configKey);
#		} else {
#			PutConfig($configKey, $configValue);
#		}
#	}

	WriteLog('WriteIndexedConfig: finished, calling GetConfig(unmemo)');

	GetConfig('unmemo');

	return '';
} # WriteIndexedConfig()




#	if (defined($pageLinks{$pageQuery})) {
#		WriteLog('GetPaginationLinks: $pageLinks{$pageQuery} already exists, doing search and replace');
#
#		my $currentPageTemplate = GetPageLink($currentPageNumber, $itemCount);
#
#		my $currentPageStart = $currentPageNumber * $perPage;
#		my $currentPageEnd = $currentPageNumber * $perPage + $perPage;
#		if ($currentPageEnd > $itemCount) {
#			$currentPageEnd = $itemCount - 1;
#		}
#
#		my $currentPageCaption = $currentPageStart . '-' . $currentPageEnd;
#		my $pageLinksReturn = $pageLinks; # make a copy of $pageLinks which we'll modify
#		$pageLinksReturn = str_replace($currentPageTemplate, '<b>$currentPageCaption</b>', $currentPageTemplate);
#
#		return $pageLinksReturn;
#	} else {
#		# we've ended up here because we haven't generated $pageLinks yet
#		WriteLog('GetPaginationLinks: $itemCount = ' . $itemCount);
#



#use warnings FATAL => 'all';
#
# $SIG{__WARN__} = sub {
# 	if (open (my $fileHandle, ">>", 'log/log.log')) {
# 		say $fileHandle "\n" . time() . " ";
# 		say $fileHandle @_;
# 		say $fileHandle "\n";
# 		close $fileHandle;
# 	}
#
# 	if (-e 'config/debug') {
# 		die `This program does not tolerate warnings like: @_`;
# 	}
# };


sub DBCheckItemSurpass { # $a, $b
	my $a = shift;
	my $b = shift;
	#todo sanity

	state %memo;
	if (exists($memo{$a . $b})) {
		return $memo{$a . $b};
	}

	#todo add weights
	my $querySurpass = "select count(*) FROM item_attribute where attribute = 'surpass' AND
		file_hash = ?";
	my $querySurpassed = "select count(*) FROM item_attribute where attribute = 'surpass' AND
		value = ?";

	my @arrayA = ($a);
	my $valueA = SqliteGetValue($querySurpass, @arrayA) - SqliteGetValue($querySurpassed, @arrayA);


	my @arrayB = ($b);
	my $valueB = SqliteGetValue($querySurpass, @arrayB) - SqliteGetValue($querySurpassed, @arrayB);

	WriteLog('DBCheckItemSurpass: $a = ' . $a . '; $b = ' . $b . '; $valueA = ' . $valueA . '; $valueB = ' . $valueB);

	if ($valueA > $valueB) {
		$memo{$a . $b} = 1;
		return 1;
	} else {
		$memo{$a . $b} = 0;
		return 0;
	}
}


sub DBCheckItemSurpass2 { # $a, $b
	my $a = shift;
	my $b = shift;
	#todo sanity

	state %memo;
	if (exists($memo{$a . $b})) {
		return $memo{$a . $b};
	}

	#todo add weights
	my $query = "select count(*) FROM item_attribute where attribute = 'surpass' AND
		file_hash = ? AND value = ?";
	my @arrayAtoB = ($a, $b);
	my $valueAtoB = SqliteGetValue($query, @arrayAtoB);

	my @arrayBtoA = ($b, $a);
	my $valueBtoA = SqliteGetValue($query, @arrayBtoA);

	WriteLog('DBCheckItemSurpass: $a = ' . $a . '; $b = ' . $b . '; $valueAtoB = ' . $valueAtoB . '; $valueBtoA = ' . $valueBtoA);

	if ($valueBtoA > $valueAtoB) {
		$memo{$a . $b} = 1;
		return 1;
	} else {
		$memo{$a . $b} = 0;
		return 0;
	}
}






	my $pageName = shift;
	if (!$pageName) {
		return;
	}
	chomp $pageName;
	if (!$pageName =~ m/^[a-z]+$/) {
		WriteLog('MakeSimplePage: warning: $pageName failed sanity check');
		return '';
	}







#
#sub SqliteMakeItemFlatTable {
#	state $tableBeenMade;
#	if (!$tableBeenMade) {
#		$tableBeenMade = 1;
#		my $itemFlatQuery = "create temp table item_flat as select * from item_flat_view";
#		SqliteQuery($itemFlatQuery);
#	}
#}

#	SqliteQuery("CREATE UNIQUE INDEX config_unique ON config(key, value, reset_flag);");
#	SqliteQuery("
#   		CREATE VIEW config_latest
#   		AS
#   			SELECT
#   				key,
#   				value,
#   				reset_flag,
#   				file_hash FROM config
#			GROUP BY key
#    	;");
#
#	SqliteQuery("
#		CREATE VIEW config_bestest
#		AS
#			SELECT
#				config.key,
#				config.value,
#				MAX(config.timestamp) config_timestamp,
#				config.reset_flag,
#				config.file_hash,
#				item_score.item_score
#			FROM config
#				 LEFT JOIN item_score ON (config.file_hash = item_score.file_hash)
#			GROUP BY config.key
#			ORDER BY item_score.item_score DESC, timestamp DESC
#	;");
#
#	SqliteQuery("
#		CREATE VIEW config_latest_timestamp
#		AS
#			SELECT
#				key,
#				max(add_timestamp) max_timestamp
#			FROM
#				config
#				LEFT JOIN item_flat ON (config.file_hash = item_flat.file_hash)
#			GROUP BY
#				key
#	");


















		my $message = '';
		if ($isTextart) {
			# if textart, format with extra spacing to preserve character arrangement
			#$message = TextartForWeb($message);

			$message = TextartForWeb(GetFile($file{'file_path'}));
			WriteLog('GetItemTemplate: textart: $message = TextartForWeb(GetFile(' . $file{'file_path'} . ')) = ' . length($message));
		} else {
			# get formatted/post-processed message for this item
			$message = GetItemDetokenedMessage($file{'file_hash'}, $file{'file_path'});

			if (!$message) {
				#message is missing, try to find fallback
				WriteLog('GetItemTemplate: warning: $message is empty, trying original source');

				if (!$sourceFileHasGoneAway && -e $file{'file_path'}) {
					#original file still exists
					$message = GetFile($file{'file_path'});

					if ($message) {
						$isTextart = 1;
					} else {
						WriteLog('GetItemTemplate: warning: $message is empty even after getting file contents!');
						$message = '[Message is blank.]';
					}
				} else {
					WriteLog('GetItemTemplate: warning: $sourceFileHasGoneAway is TRUE');
					$message = '[Unable to retrieve message. Source file has gone away.]';
				}
			}

			$message =~ s/\r//g;

			if (GetConfig('admin/expo_site_mode')) {
				#trim signature/header-footer
				if (index($message, "\n-- \n") != -1) {
					$message = substr($message, 0, index($message, "\n-- \n"));
				}
			}


			if ($file{'remove_token'}) {
				# if remove_token is specified, remove it from the message
				WriteLog('GetItemTemplate: $file{\'remove_token\'} = ' . $file{'remove_token'});

				$message =~ s/$file{'remove_token'}//g;
				$message = trim($message);

				#todo there is a #bug here, but it is less significant than the majority of cases
				#  the bug is that it removes the token even if it is not by itself on a single line
				#  this could potentially be mis-used to join together two pieces of a forbidden string
				#todo make it so that post does not need to be trimmed, but extra \n\n after the token is removed
			} else {
				WriteLog('GetItemTemplate: $file{\'remove_token\'} is not set');
			}

			# if not textart, just escape html characters
			WriteLog('GetItemTemplate: calling FormatForWeb');
			$message = FormatForWeb($message);


			# WriteLog($message);


			if ($file{'item_type'}) {
				$itemType = $file{'item_type'};
			} else {
				$itemType = 'txt';
			}

			if (!$file{'item_title'}) {
				#hack #todo
				$file{'item_title'} = 'Untitled';
				#$file{'item_title'} = '';
			}

			# } elsif ($isSurvey) {
			# 	# if survey, format with text fields for answers
			# 	$message = SurveyForWeb($message);


			#hint GetHtmlFilename()
			#todo verify that the items exist before turning them into links,
			# so that we don't end up with broken links
			# can be done here or in the function (return original text if no item)?
			#$message =~ s/([a-f0-9]{40})/GetItemHtmlLink($1)/eg;
			#$message =~ s/([a-f0-9]{40})/GetItemTemplateFromHash($1)/eg;

			# if format_avatars flag is set, replace author keys with avatars
			if ($file{'format_avatars'}) {
				$message =~ s/([A-F0-9]{16})/GetHtmlAvatar($1)/eg;
			}
		} # NOT $isTextart



				if ($itemType eq 'txt') {
					WriteLog('GetItemTemplate: 2');
					if ($isTextart) {
						$itemText = 'asdfad';
					} else {
						$itemText = $message; # output for item's message (formatted text)
					}

					$itemClass = "txt";


					if ($isSigned) {
						# if item is signed, add "signed" css class
						$itemClass .= ' signed';
					}

					if ($isAdmin) {
						# if item is signed by an admin, add "admin" css class
						$itemClass .= ' byadmin';

						my $adminContainer = GetTemplate('html/item/container/admin.template');

						my $colorAdmin = GetThemeColor('admin') || '#c00000';
						$adminContainer =~ s/\$colorAdmin/$colorAdmin/g;

						$adminContainer =~ s/\$message/$itemText/g;

						$itemText = $adminContainer;
					} # $isAdmin
				} # $itemType eq 'txt'

				if ($itemType eq 'image') {
					if (GetConfig('admin/image/enable')) {
						my $imageContainer = '';
						if ($file{'no_permalink'}) {
							$imageContainer = GetTemplate('html/item/container/image.template');
						} else {
							$imageContainer = GetTemplate('html/item/container/image_with_link.template');
						}

						my $imageUrl = "/thumb/thumb_800_$fileHash.gif"; #todo hardcoding no
						my $imageSmallUrl = "/thumb/thumb_42_$fileHash.gif"; #todo hardcoding no
						my $imageAlt = $itemTitle;

						if ($file{'image_large'}) {
						} else {
						}
		#				my $imageUrl = "/thumb/squared_800_$fileHash.gif"; #todo hardcoding no
		#				my $imageSmallUrl = "/thumb/squared_42_$fileHash.gif"; #todo hardcoding no

						# $imageSmallUrl is a smaller image, used in the "lowsrc" attribute for img tag

						if ($file{'image_large'}) {
							#$imageContainer = AddAttributeToTag($imageContainer, 'img', 'width', '500');
							#$imageContainer = AddAttributeToTag($imageContainer, 'img', 'width', '100%');
						} else {
							if ($file{'item_score'} > 0) {
								$imageUrl = "/thumb/thumb_512_$fileHash.gif"; #todo hardcoding no
							} else {
								$imageUrl = "/thumb/thumb_512_g_$fileHash.gif"; #todo hardcoding no
							}
							$imageContainer = AddAttributeToTag($imageContainer, 'img', 'width', '300');
						}

						$imageContainer =~ s/\$imageUrl/$imageUrl/g;
						$imageContainer =~ s/\$imageSmallUrl/$imageSmallUrl/g;
						$imageContainer =~ s/\$imageAlt/$imageAlt/g;
						$imageContainer =~ s/\$permalinkHtml/$permalinkHtml/g;


						$itemText = $imageContainer;

						$itemClass = 'image';
					} else {
						$itemText = '[image]';
						WriteLog('GetItemTemplate: warning: $itemType eq image, but images disabled');
					}
				} # $itemType eq 'image'


				if ($isTextart) {
					WriteLog('GetItemTemplate: 3');
					# if item is textart, add "item-textart" css class
					#todo this may not be necessary anymore
					$itemClass = 'item-textart';

					#die $itemText;

					my $textartContainer = GetTemplate('html/item/container/textart.template');
					$textartContainer =~ s/\$message/$itemText/g;

					$itemText = $textartContainer;

					$windowBody = GetTemplate('html/item/item.template'); # GetItemTemplate() #textart

					$windowBody =~ s/\$itemName/$itemName/g;
					$windowBody =~ s/\$itemText/$itemText/g;
				} else {

					$windowBody = GetTemplate('html/item/item.template'); # GetItemTemplate() NOT #textart

					$windowBody =~ s/\$itemName/$itemName/g;
					$windowBody =~ s/\$itemText/$itemText/g;
				}


		my $itemHash = $file{'file_hash'}; # file hash/item identifier
		my $gpgKey = $file{'author_key'}; # author's fingerprint

		my $isTextart = 0; # if textart, need extra formatting
		my $isSurvey = 0; # if survey, need extra formatting
		my $isTooLong = 0; # if survey, need extra formatting

		my $alias; # stores author's alias / name
		my $isAdmin = 0; # author is admin? (needs extra styles)

		my $itemType = '';

		my $isSigned = 0; # is signed by user (also if it's a pubkey)
		if ($gpgKey) { # if there's a gpg key, it's signed
			$isSigned = 1;
		} else {
			$isSigned = 0;
		}

		if ($file{'labels_list'}) {
			# if there is a list of tags, check to see if there is a 'textart' tag

			# split the tags list into @itemTags array
			my @itemTags = split(',', $file{'labels_list'});

			# loop through all the tags in @itemTags
			while (scalar(@itemTags)) {
				my $thisTag = pop @itemTags;
				if ($thisTag eq 'textart') {
					$isTextart = 1; # set isTextart to 1 if 'textart' tag is present
				}
				if ($thisTag eq 'survey') {
					$isSurvey = 1; # set $isSurvey to 1 if 'survey' tag is present
				}
				if ($thisTag eq 'toolong') {
					$isTooLong = 1; # set $isTooLong to 1 if 'survey' tag is present
				}
			}
		}
		if ($file{'labels_list'}) {
			# if there is a list of tags, check to see if there is a 'textart' tag

			# split the tags list into @itemTags array
			my @itemTags = split(',', $file{'labels_list'});

			# loop through all the tags in @itemTags
			while (scalar(@itemTags)) {
				my $thisTag = pop @itemTags;
				if ($thisTag eq 'textart') {
					$isTextart = 1; # set isTextart to 1 if 'textart' tag is present
				}
				if ($thisTag eq 'survey') {
					$isSurvey = 1; # set $isSurvey to 1 if 'survey' tag is present
				}
				if ($thisTag eq 'toolong') {
					$isTooLong = 1; # set $isTooLong to 1 if 'survey' tag is present
				}
			}
		}
		my $isTextart = 0; # if textart, need extra formatting
		my $isSurvey = 0; # if survey, need extra formatting
		my $isTooLong = 0; # if survey, need extra formatting

		my $alias; # stores author's alias / name
		my $isAdmin = 0; # author is admin? (needs extra styles)

		my $itemType = '';

		my $isSigned = 0; # is signed by user (also if it's a pubkey)
		if ($gpgKey) { # if there's a gpg key, it's signed
			$isSigned = 1;
		} else {
			$isSigned = 0;
		}

		if ($file{'labels_list'}) {
			# if there is a list of tags, check to see if there is a 'textart' tag

			# split the tags list into @itemTags array
			my @itemTags = split(',', $file{'labels_list'});

			# loop through all the tags in @itemTags
			while (scalar(@itemTags)) {
				my $thisTag = pop @itemTags;
				if ($thisTag eq 'textart') {
					$isTextart = 1; # set isTextart to 1 if 'textart' tag is present
				}
				if ($thisTag eq 'survey') {
					$isSurvey = 1; # set $isSurvey to 1 if 'survey' tag is present
				}
				if ($thisTag eq 'toolong') {
					$isTooLong = 1; # set $isTooLong to 1 if 'survey' tag is present
				}
			}
		}













































































#
#			DBAddItemPage($$replyItem{'file_hash'}, 'item', $file{'file_hash'});
#
#			# use item-small template to display the reply items
#			#$$replyItem{'template_name'} = 'html/item/item.template';
#
#			# if the child item contains a reply token for our parent item
#			# we want to remove it, to reduce redundant information on the page
#			# to do this, we pass the remove_token parameter to GetItemTemplate() below
#			$$replyItem{'remove_token'} = '>>' . $file{'file_hash'};
#
#			# after voting, return to the main thread page
#			$$replyItem{'vote_return_to'} = $file{'file_hash'};
#
#			# trim long text items
#			$$replyItem{'trim_long_text'} = 1;
##
##			if (index(','.$$replyItem{'labels_list'}.',', ','.'notext'.',') != -1) {
##				$$replyItem{'template_name'} = 'html/item/item.template';
##			} else {
##				$$replyItem{'template_name'} = 'html/item/item.template';
##			}
#
#			# Get the reply template
#			my $replyTemplate = GetItemTemplate($replyItem); # GetItemPage()
#
#			# output it to debug
#			WriteLog('$replyTemplate for ' . $$replyItem{'template_name'} . ':');
#			WriteLog($replyTemplate);
#
#			# if the reply item has children also, output the children
#			# threads are currently limited to 2 steps
#			# eventually, recurdsion can be used to output more levels
#			if ($$replyItem{'child_count'}) {
#				my $subRepliesTemplate = ''; # will store the sub-replies html output
#
#				my $subReplyComma = ''; # separator for sub-replies, set to <hr on first use
#
#				my @subReplies = DBGetItemReplies($$replyItem{'file_hash'});
#				foreach my $subReplyItem (@subReplies) {
#					DBAddItemPage($$subReplyItem{'file_hash'}, 'item', $file{'file_hash'});
##
##					if (index(','.$$subReplyItem{'labels_list'}.',', ','.'notext'.',') != -1) {
##						$$subReplyItem{'template_name'} = 'html/item/item.template';
##						# $$subReplyItem{'template_name'} = 'html/item/item-mini.template';
##					} else {
##						$$subReplyItem{'template_name'} = 'html/item/item.template';
##						# $$subReplyItem{'template_name'} = 'html/item/item-small.template';
##					}
#					$$subReplyItem{'remove_token'} = '>>' . $$replyItem{'file_hash'};
#					$$subReplyItem{'vote_return_to'} = $file{'file_hash'};
#
#					WriteLog('$$subReplyItem{\'remove_token\'} = ' . $$subReplyItem{'remove_token'});
#					WriteLog('$$subReplyItem{\'template_name\'} = ' . $$subReplyItem{'template_name'});
#					WriteLog('$$subReplyItem{\'vote_return_to\'} = ' . $$subReplyItem{'vote_return_to'});
#
#					$$subReplyItem{'trim_long_text'} = 1;
#					my $subReplyTemplate = GetItemTemplate($subReplyItem); # GetItemPage()
#					if ($subReplyComma eq '') {
#						$subReplyComma = '<hr size=4>';
#					}
#					else {
#						$subReplyTemplate = $subReplyComma . $replyTemplate;
#					}
#					$subRepliesTemplate .= $subReplyTemplate;
#				}
#
#				# replace replies placeholder with generated html
#				$replyTemplate =~ s/<replies><\/replies>/$subRepliesTemplate/;
#			}
#			else {
#				# there are no replies, so remove replies placeholder
#				$replyTemplate =~ s/<replies><\/replies>//;
#			}
#
#			if ($replyTemplate) {
#				if ($replyComma eq '') {
#					$replyComma = '<hr size=5>';
#					# $replyComma = '<p>';
#				}
#				else {
#					$replyTemplate = $replyComma . $replyTemplate;
#				}
#
#				$allReplies .= $replyTemplate;
#			}
#			else {
#				WriteLog('Warning: replyTemplate is missing for some reason!');
#			}
#		} # foreach my $replyItem (@itemReplies)
#
#		if (GetConfig('reply/enable') && GetConfig('html/reply_form_after_reply_list') && !GetConfig('html/reply_form_before_reply_list')) {
#			# add reply form after replies
#			my $replyForm = GetReplyForm($file{'file_hash'});
#			# start with a horizontal rule to separate from above content
#			$allReplies .= '<hr size=6>';
#			$allReplies .= $replyForm;
#		}
#
#		$itemTemplate =~ s/<replies><\/replies>/$allReplies/;
#		$itemTemplate .= '<hr><br>';
#	} # $file{'child_count'}
#	else {
#		my $allReplies = '';
#		if (GetConfig('reply/enable')) {
#			# add reply form if no existing replies
#
#			{
#				my $voteButtons = GetItemLabelButtons($file{'file_hash'});
#				$allReplies .= '<hr>'.GetDialogX($voteButtons, 'Add Tags').'<hr>';
#			}
#
#
#			my $replyForm = GetReplyForm($file{'file_hash'});
#			$allReplies .= $replyForm;
#		}
#		$itemTemplate =~ s/<replies><\/replies>/$allReplies/;
#		$itemTemplate .= '<hr><br>';
#	} # replies and reply form






		$writeForm = str_replace('<span id=write_options></span>', $writeOptions, $writeForm);
		$writeForm = str_replace('<span id=write_options></span>', $writeOptions, $writeForm);





#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use DBD::SQLite;
use DBI;
use Data::Dumper;
use 5.010;

sub GetSqliteDbName {
	state $cacheDir = GetDir('cache');
	my $SqliteDbName = "$cacheDir/index.sqlite3"; # path to sqlite db
	return $SqliteDbName;
}

my $dbh; # handle for sqlite interface

sub SqliteConnect { # Establishes connection to sqlite db
	my $SqliteDbName = GetSqliteDbName();
	EnsureSubdirs($SqliteDbName);
	if (!
		(
			(
				GetConfig('debug')
					&&
				(
					$dbh = DBI->connect(
						"dbi:SQLite:dbname=$SqliteDbName",
						"", # username (unused)
						"", # password (unused)
						{
							RaiseError => 1,
							AutoCommit => 1
						}
					)
				)
			)
				||
			(
				$dbh = DBI->connect(
					"dbi:SQLite:dbname=$SqliteDbName",
					"", # username
					"", # password
					{
						AutoCommit => 1
					}
				)
			)
		) # ! (not)
	) { # if
		WriteLog('SqliteConnect: warning: problem connecting to database: ' . $DBI::errstr);

		state $retries;
		if (!$retries) {
			$retries = 1;
		} else {
			$retries = $retries + 1;
		}

		if ($retries < 5) {
			return SqliteConnect();
		}
	}
}
SqliteConnect();

sub DBMaxQueryLength { # Returns max number of characters to allow in sqlite query
	return 10240;
}

sub DBMaxQueryParams { # Returns max number of parameters to allow in sqlite query
	return 128;
}

sub SqliteUnlinkDb { # Removes sqlite database by renaming it to ".prev"
	my $SqliteDbName = GetSqliteDbName();
	if ($dbh) {
		$dbh->disconnect();
	}
	rename($SqliteDbName, "$SqliteDbName.prev");
	SqliteConnect();
}

sub SqliteMakeTables { # creates sqlite schema
	my $existingTables = SqliteQuery3('.tables');
	if ($existingTables) {
		WriteLog('SqliteMakeTables: warning: tables already exist');
		return;
	}

	# wal
	# this switches to write-ahead log mode for sqlite
	# reduces problems with concurrent access
	SqliteQuery("PRAGMA journal_mode=WAL;");

	# config
	SqliteQuery("CREATE TABLE config(key, value, timestamp, reset_flag, file_hash);");
	SqliteQuery("CREATE UNIQUE INDEX config_unique ON config(key, value, timestamp, reset_flag);");
	SqliteQuery("
		CREATE VIEW config_latest AS
		SELECT key, value, MAX(timestamp) config_timestamp, reset_flag, file_hash FROM config GROUP BY key ORDER BY timestamp DESC
	;");


	my @scripts = qw(setup schema item_attribute item author);
	foreach my $script (@scripts) {
		my $sql = GetConfig($script);
		if ($sql =~ m/(.+)/) {
			$sql = $1;
			#if ($sql =~ m/^[a-zA-Z'\n .. finish this #todo
		}
		SqliteQuery($script);
	}


	#
	# 	SqliteQuery("
	# 		CREATE VIEW item_title_latest AS
	# 		SELECT
	# 			file_hash,
	# 			title,
	# 			source_item_hash,
	# 			MAX(source_item_timestamp) AS source_item_timestamp
	# 		FROM item_title
	# 		GROUP BY file_hash
	# 		ORDER BY source_item_timestamp DESC
	# 	;");
	# 	#SqliteQuery("CREATE UNIQUE INDEX item_title_unique ON item_title(file_hash)");

	# item_parent
	SqliteQuery("CREATE TABLE item_parent(item_hash, parent_hash)");
	SqliteQuery("CREATE UNIQUE INDEX item_parent_unique ON item_parent(item_hash, parent_hash)");

	# child_count view
	SqliteQuery("
		CREATE VIEW child_count AS
		SELECT
			parent_hash AS parent_hash,
			COUNT(*) AS child_count
		FROM
			item_parent
		GROUP BY
			parent_hash
	");

#	# tag
#	SqliteQuery("CREATE TABLE tag(id INTEGER PRIMARY KEY AUTOINCREMENT, vote_value)");
#	SqliteQuery("CREATE UNIQUE INDEX tag_unique ON tag(vote_value);");

	# vote
	SqliteQuery("CREATE TABLE vote(id INTEGER PRIMARY KEY AUTOINCREMENT, file_hash, ballot_time, vote_value, author_key, source_hash);");
	SqliteQuery("CREATE UNIQUE INDEX vote_unique ON vote (file_hash, ballot_time, vote_value, author_key);");

	# item_page
	SqliteQuery("CREATE TABLE item_page(item_hash, page_name, page_param);");
	SqliteQuery("CREATE UNIQUE INDEX item_page_unique ON item_page(item_hash, page_name, page_param);");

	#SqliteQuery("CREATE TABLE item_type(item_hash, type_mask)");

	# event
	SqliteQuery("CREATE TABLE event(id INTEGER PRIMARY KEY AUTOINCREMENT, item_hash, author_key, event_time, event_duration);");
	SqliteQuery("CREATE UNIQUE INDEX event_unique ON event(item_hash, event_time, event_duration);");

	# location
	SqliteQuery("
		CREATE TABLE location(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			item_hash,
			author_key,
			latitude,
			longitude
		);
	");

	SqliteQuery("
		CREATE TABLE user_agent(
			user_agent_string
		);
	");

	# task
	SqliteQuery("CREATE TABLE task(id INTEGER PRIMARY KEY AUTOINCREMENT, task_type, task_name, task_param, touch_time INTEGER, priority DEFAULT 1);");
	SqliteQuery("CREATE UNIQUE INDEX task_unique ON task(task_type, task_name, task_param);");

	# # task/queue
	# SqliteQuery("CREATE TABLE task(id INTEGER PRIMARY KEY AUTOINCREMENT, action, param, touch_time INTEGER, priority DEFAULT 1);");
	# SqliteQuery("CREATE UNIQUE INDEX task_touch_unique ON task(action, param);");
	#
	# action      param           touch_time     priority
	# make_page   author/abc
	# index_file  path/abc.txt
	# read_log    log/access.log
	# find_new_files
	# make_thumb  path/abc.jpg
	# annotate_votes   (vote starts with valid=0, must be annotated)
	#





	### VIEWS BELOW ############################################
	############################################################

	# parent_count view
	SqliteQuery("
		CREATE VIEW parent_count AS
		SELECT
			item_hash AS item_hash,
			COUNT(parent_hash) AS parent_count
		FROM
			item_parent
		GROUP BY
			item_hash
	");


	SqliteQuery("
		CREATE VIEW
			item_labels_list
		AS
		SELECT
			file_hash,
			GROUP_CONCAT(DISTINCT vote_value) AS labels_list
		FROM vote
		GROUP BY file_hash
	");

	SqliteQuery("
		CREATE VIEW item_flat AS
			SELECT
				item.file_path AS file_path,
				item.item_name AS item_name,
				item.file_hash AS file_hash,
				IFNULL(item_author.author_key, '') AS author_key,
				IFNULL(child_count.child_count, 0) AS child_count,
				IFNULL(parent_count.parent_count, 0) AS parent_count,
				added_time.add_timestamp AS add_timestamp,
				IFNULL(item_title.title, '') AS item_title,
				IFNULL(item_score.item_score, 0) AS item_score,
				item.item_type AS item_type,
				labels_list AS labels_list
			FROM
				item
				LEFT JOIN child_count ON ( item.file_hash = child_count.parent_hash )
				LEFT JOIN parent_count ON ( item.file_hash = parent_count.item_hash )
				LEFT JOIN added_time ON ( item.file_hash = added_time.file_hash )
				LEFT JOIN item_title ON ( item.file_hash = item_title.file_hash )
				LEFT JOIN item_author ON ( item.file_hash = item_author.file_hash )
				LEFT JOIN item_score ON ( item.file_hash = item_score.file_hash )
				LEFT JOIN item_labels_list ON ( item.file_hash = item_labels_list.file_hash )
	");
	SqliteQuery("
		CREATE VIEW event_future AS
			SELECT
				*
			FROM
				event
			WHERE
				event.event_time > strftime('%s','now');
	");
#	SqliteQuery("
#		CREATE VIEW event_future AS
#			SELECT
#				event.item_hash AS item_hash,
#				event.event_time AS event_time,
#				event.event_duration AS event_duration
#			FROM
#				event
#			WHERE
#				event.event_time > strftime('%s','now');
#	");
	SqliteQuery("
		CREATE VIEW item_vote_count AS
			SELECT
				file_hash,
				vote_value AS vote_value,
				COUNT(file_hash) AS vote_count
			FROM vote
			GROUP BY file_hash, vote_value
			ORDER BY vote_count DESC
	");

	SqliteQuery("
		CREATE VIEW
			author_score
		AS
			SELECT
				item_flat.author_key AS author_key,
				SUM(item_flat.item_score) AS author_score
			FROM
				item_flat
			GROUP BY
				item_flat.author_key

	");

	SqliteQuery("
		CREATE VIEW
			author_flat
		AS
		SELECT
			author.key AS author_key,
			author_alias.alias AS author_alias,
			IFNULL(author_score.author_score, 0) AS author_score,
			MAX(item_flat.add_timestamp) AS author_seen,
			COUNT(item_flat.file_hash) AS item_count,
			author_alias.file_hash AS file_hash
		FROM
			author
			LEFT JOIN author_alias
				ON (author.key = author_alias.key)
			LEFT JOIN author_score
				ON (author.key = author_score.author_key)
			LEFT JOIN item_flat
				ON (author.key = item_flat.author_key)
		GROUP BY
			author.key, author_alias.alias, author_alias.file_hash
	");

	#todo deconfusify
	SqliteQuery("
		CREATE VIEW
			item_score
		AS
			SELECT
				vote.file_hash AS file_hash,
				SUM(IFNULL(vote_value.value, 0)) AS item_score
			FROM
				vote
				LEFT JOIN vote_value
					ON (vote.vote_value = vote_value.vote)
			GROUP BY
				vote.file_hash
	");

	my $SqliteDbName = GetSqliteDbName();

	my $schemaHash = `sqlite3 "$SqliteDbName" ".schema" | sha1sum | awk '{print \$1}' > config/sqlite3_schema_hash`;
	# this can be used as cache "version"
	# only problem is first time it changes, now cache must be regenerated
	# so need to keep track of the previous one and recursively call again or copy into new location
} # SqliteMakeTables()

sub SqliteQuery2 { # $query, @queryParams; calls sqlite with query, and returns result as array reference
	WriteLog('SqliteQuery() begin');

	my $query = shift;
	chomp $query;

	my @queryParams = @_;

	if ($query) {
		my $queryOneLine = $query;
		$queryOneLine =~ s/\s+/ /g;

		WriteLog('SqliteQuery2: $query = ' . $queryOneLine);
		WriteLog('SqliteQuery2: @queryParams: ' . join(', ', @queryParams));

		if ($dbh) {
			WriteLog('SqliteQuery2: $dbh was found, proceeding...');

			my $aref;
			my $sth;

			# try {
			#
			# } catch {
			# 	WriteMessage('SqliteQuery2: warning: error');
			# 	WriteMessage('SqliteQuery2: query: ' . $query);
			#
			# 	WriteLog('SqliteQuery2: warning: error');
			# 	WriteLog('SqliteQuery2: query: ' . $query);
			#
			# 	return;
			# };

			$sth = $dbh->prepare($query);
			my $execResult = $sth->execute(@queryParams);

			WriteLog('SqliteQuery2: $execResult = ' . $execResult);

			$aref = $sth->fetchall_arrayref();
			$sth->finish();

			return $aref;
		} else {
			WriteLog('SqliteQuery2: warning: $dbh is missing');
		}
	}
	else {
		WriteLog('SqliteQuery2: warning: $query is missing!');
		return '';
	}
}

sub EscapeShellChars { # $string ; escapes string for including as parameter in shell command
	#todo this is still probably not safe and should be improved upon #security
	my $string = shift;
	chomp $string;

	$string =~ s/([\"|\$`\\])/\\$1/g;
	# chars are: " | $ ` \

	return $string;
} # EscapeShellChars()

sub SqliteQuery { # performs sqlite query via sqlite3 command
#todo add parsing into array?
	my $query = shift;
	if (!$query) {
		WriteLog('SqliteQuery: warning: called without $query');
		return;
	}
	my $queryOneLine = $query;
	$queryOneLine =~ s/\s+/ /g;

	chomp $query;
	$query = EscapeShellChars($query);
	WriteLog('SqliteQuery: $query = ' . $queryOneLine);

	my $SqliteDbName = GetSqliteDbName();

	my $results = `sqlite3 "$SqliteDbName" "$query"`;
	return $results;
} # SqliteQuery()

sub SqliteQuery3 { # performs sqlite query via sqlite3 command
# CacheSqliteQuery { keyword
# #todo add parsing into array?
	my $query = shift;
	if (!$query) {
		WriteLog('SqliteQuery3: warning: called without $query');
		return;
	}
	chomp $query;
	$query = EscapeShellChars($query);
	WriteLog('SqliteQuery3: $query = ' . $query);

	my $cachePath = md5_hex($query);
	if ($cachePath =~ m/^([0-9a-f]{32})$/) {
		$cachePath = $1;
	} else {
		WriteLog('SqliteQuery3: warning: $cachePath sanity check failed');
	}
	my $cacheTime = GetTime();

	# this limits the cache to expiration of 1-100 seconds
	$cacheTime = substr($cacheTime, 0, length($cacheTime) - 2);
	$cachePath = "$cacheTime/$cachePath";

	WriteLog('SqliteQuery3: $cachePath = ' . $cachePath);
	my $results = GetCache("sqlitequery3/$cachePath");

	if ($results) {
		return $results;
	} else {

		my $SqliteDbName = GetSqliteDbName();
		$results = `sqlite3 "$SqliteDbName" "$query"`;
		PutCache('sqlitequery3/'.$cachePath, $results);
		return $results;
	}
} # SqliteQuery3()

#
#sub DBGetVotesTable {
#	my $fileHash = shift;
#
#	if (!IsSha1($fileHash) && $fileHash) {
#		WriteLog("DBGetVotesTable called with invalid parameter! returning");
#		WriteLog("$fileHash");
#		return '';
#	}
#
#	my $query;
#	my @queryParams = ();
#
#	if ($fileHash) {
#		$query = "SELECT file_hash, ballot_time, vote_value, author_key FROM vote_weighed WHERE file_hash = ?;";
#		@queryParams = ($fileHash);
#	} else {
#		$query = "SELECT file_hash, ballot_time, vote_value, author_key FROM vote_weighed;";
#	}
#
#	my $result = SqliteQuery($query, @queryParams);
#
#	return $result;
#}

sub DBGetLabelsForItem { # $fileHash ; Returns all labels (weighed) for item
	my $fileHash = shift;

	if (!IsSha1($fileHash)) {
		WriteLog("DBGetVotesTable called with invalid parameter! returning");
		WriteLog("$fileHash");
		return '';
	}

	my $query;
	my @queryParams;

	$query = "
		SELECT
			file_hash,
			ballot_time,
			vote_value,
			author_key
		FROM vote
		WHERE file_hash = ?
	";
	@queryParams = ($fileHash);

	my $result = SqliteQuery($query, @queryParams);

	return $result;
}
#
#sub DBGetEvents { #gets events list
#	WriteLog('DBGetEvents()');
#
#	my $query;
#
#	$query = "
#		SELECT
#			item_flat.item_title AS event_title,
#			event.event_time AS event_time,
#			event.event_duration AS event_duration,
#			item_flat.file_hash AS file_hash,
#			item_flat.author_key AS author_key,
#			item_flat.file_path AS file_path
#		FROM
#			event
#			LEFT JOIN item_flat ON (event.item_hash = item_flat.file_hash)
#		ORDER BY
#			event_time
#	";
#
#	my @queryParams = ();
##	push @queryParams, $time;
#
#	my $sth = $dbh->prepare($query);
#	$sth->execute(@queryParams);
#
#	my @resultsArray = ();
#
#	while (my $row = $sth->fetchrow_hashref()) {
#		push @resultsArray, $row;
#	}
#
#	return @resultsArray;
#}

sub DBGetAuthorFriends { # Returns list of authors which $authorKey has tagged as friend
# Looks for vote_value = 'friend' and items that contain 'pubkey' tag
	my $authorKey = shift;
	chomp $authorKey;
	if (!$authorKey) {
		return;
	}
	if (!IsFingerprint($authorKey)) {
		return;
	}

	my $query = "
		SELECT
			DISTINCT item_flat.author_key
		FROM
			vote
			LEFT JOIN item_flat ON (vote.file_hash = item_flat.file_hash)
		WHERE
			vote.author_key = ?
			AND vote_value = 'friend'
			AND ',' || item_flat.labels_list || ',' LIKE '%,pubkey,%'
		;
	";

	my @queryParams = ();
	push @queryParams, $authorKey;

	my $sth = $dbh->prepare($query);
	$sth->execute(@queryParams);

	my @resultsArray = ();

	while (my $row = $sth->fetchrow_hashref()) {
		push @resultsArray, $row;
	}

	return @resultsArray;
}

sub DBGetLatestConfig { # Returns everything from config_latest view
# config_latest contains the latest set value for each key stored
	my $query = "SELECT * FROM config_latest";
	#todo write out the fields

	if ($dbh) {
		my $sth = $dbh->prepare($query);
		$sth->execute();
		my @resultsArray = ();
		while (my $row = $sth->fetchrow_hashref()) {
			push @resultsArray, $row;
		}
		return @resultsArray;
	} else {
		WriteLog('DBGetLatestConfig: warning: $dbh was false');
		return 0;
	}
}


#sub SqliteGetHash {
#	my $query = shift;
#	chomp $query;
#
#	my @results = split("\n", SqliteQuery($query));
#
#	my %hash;
#
#	foreach (@results) {
#		chomp;
#
#		my ($key, $value) = split(/\|/, $_);
#
#		$hash{$key} = $value;
#	}
#
#	return %hash;
#}

sub SqliteGetValue { # Returns the first column from the first row returned by sqlite $query
	#todo perhaps use SqliteQuery() ?
	#todo perhaps add params array?

	my $query = shift;
	chomp $query;

	WriteLog('SqliteGetValue: ' . $query);

	my $sth = $dbh->prepare($query);
	$sth->execute(@_);

	my @aref = $sth->fetchrow_array();

	$sth->finish();

	return $aref[0];
}

sub DBGetAuthorCount { # Returns author count.
# By default, all authors, unless $whereClause is specified

	my $whereClause = shift;

	my $authorCount;
	if ($whereClause) {
		$authorCount = SqliteQueryCachedShell("SELECT COUNT(*) AS author_count FROM author_flat WHERE $whereClause LIMIT 1");
	} else {
		$authorCount = SqliteQueryCachedShell("SELECT COUNT(*) AS author_count FROM author_flat LIMIT 1");
	}
	chomp($authorCount);

	return $authorCount;

}

sub DBGetItemCount { # Returns item count.
# By default, all items, unless $whereClause is specified
	my $whereClause = shift;

	my $itemCount;
	if ($whereClause) {
		$itemCount = SqliteGetValue("SELECT COUNT(*) FROM item_flat WHERE $whereClause");
	} else {
		$itemCount = SqliteGetValue("SELECT COUNT(*) FROM item_flat");
	}
	chomp($itemCount);

	return $itemCount;
}

sub DBGetItemParents {# Returns all item's parents
# $itemHash = item's hash/identifier
# Sets up parameters and calls DBGetItemList
	my $itemHash = shift;

	if (!IsSha1($itemHash)) {
		WriteLog('DBGetItemParents called with invalid parameter! returning');
		return '';
	}

	$itemHash = SqliteEscape($itemHash);

	my %queryParams;
	$queryParams{'where_clause'} = "WHERE file_hash IN(SELECT item_hash FROM item_child WHERE item_hash = '$itemHash')";
	$queryParams{'order_clause'} = "ORDER BY add_timestamp"; #todo this should be by timestamp

	return DBGetItemList(\%queryParams);
}

sub DBGetItemReplies { # Returns replies for item (actually returns all child items)
# $itemHash = item's hash/identifier
# Sets up parameters and calls DBGetItemList
	my $itemHash = shift;
	if (!IsItem($itemHash)) {
		WriteLog('DBGetItemReplies: warning: sanity check failed, returning');
		return '';
	}
	if ($itemHash ne SqliteEscape($itemHash)) {
		WriteLog('DBGetItemReplies: warning: $itemHash contains escapable characters');
		return '';
	}
	WriteLog("DBGetItemReplies($itemHash)");

	my %queryParams;
	$queryParams{'where_clause'} = "WHERE file_hash IN(SELECT item_hash FROM item_parent WHERE parent_hash = '$itemHash') AND ','||labels_list||',' NOT LIKE '%,meta,%'";
	$queryParams{'order_clause'} = "ORDER BY (labels_list NOT LIKE '%hastext%'), add_timestamp";

	return DBGetItemList(\%queryParams);
}

sub SqliteEscape { # Escapes supplied text for use in sqlite query
# Just changes ' to ''
	my $text = shift;

	if (defined $text) {
		$text =~ s/'/''/g;
	} else {
		$text = '';
	}

	return $text;
}

#sub SqliteAddKeyValue {
#	my $table = shift;
#	my $key = shift;
#	my $value = shift;
#
#	$table = SqliteEscape ($table);
#	$key = SqliteEscape($key);
#	$value = SqliteEscape($value);
#
#	SqliteQuery("INSERT INTO $table(key, alias) VALUES ('$key', '$value');");
#
#}

# sub DBGetAuthor {
# 	my $query = "SELECT author_key, author_alias FROM author_flat";
#
# 	my $authorInfo = SqliteQuery($query);
#
# 	return $authorInfo;
# }

sub DBGetItemTitle { # get title for item ($itemhash)
	my $itemHash = shift;

	if (!$itemHash || !IsItem($itemHash)) {
		return;
	}

	my $query = 'SELECT title FROM item_title WHERE file_hash = ?';
	my @queryParams = ();

	push @queryParams, $itemHash;

	my $itemTitle = SqliteGetValue($query, @queryParams);

	return $itemTitle;
}

sub DBGetItemAuthor { # get author for item ($itemhash)
	my $itemHash = shift;

	if (!$itemHash || !IsItem($itemHash)) {
		return;
	}

	chomp $itemHash;

	WriteLog('DBGetItemAuthor(' . $itemHash . ')');

	my $query = 'SELECT author_key FROM item_author WHERE file_hash = ?';
	my @queryParams = ();
	#
	push @queryParams, $itemHash;

	WriteLog('DBGetItemAuthor: $query = ' . $query);

	my $authorKey = SqliteGetValue($query, @queryParams);

	if ($authorKey) {
		return $authorKey;
	} else {
		return;
	}
}

sub DBAddConfigValue { # add value to the config table ($key, $value)
	state $query;
	state @queryParams;

	my $key = shift;

	if (!$key) {
		WriteLog('DBAddConfigValue: warning: sanity check failed');
		return '';
	}

	if ($key eq 'flush') {
		WriteLog("DBAddConfigValue(flush)");

		if ($query) {
			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		$query = '';
		@queryParams = ();
	}

	my $value = shift;
	my $timestamp = shift;
	my $resetFlag = shift;
	my $sourceItem = shift;

	if ($key =~ m/^([a-z0-9_\/.]+)$/) {
		# sanity success
		$key = $1;
	} else {
		WriteLog('DBAddConfigValue: warning: sanity check failed on $key = ' . $key);
		return '';
	}

	if (!$query) {
		$query = "INSERT OR REPLACE INTO config(key, value, timestamp, reset_flag, file_hash) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= '(?, ?, ?, ?, ?)';
	push @queryParams, $key, $value, $timestamp, $resetFlag, $sourceItem;

	return;
}

sub DBGetTouchedPages { # Returns items from task table, used for prioritizing which pages need rebuild
# index, rss, authors, stats, tags, and top are returned first
	my $touchedPageLimit = shift;

	WriteLog("DBGetTouchedPages($touchedPageLimit)");

	# sorted by most recent (touch_time DESC) so that most recently touched pages are updated first.
	# this allows us to call a shallow update and still expect what we just did to be updated.
	my $query = "
		SELECT
			task_name,
			task_param,
			touch_time,
			priority
		FROM task
		WHERE task_type = 'page' AND priority > 0
		ORDER BY priority DESC, touch_time DESC
		LIMIT ?;
	";

	my @params;
	push @params, $touchedPageLimit;

	my $results = SqliteQuery($query, @params);

	return $results;
} # DBGetTouchedPages()


sub DBAddItemPage { # $itemHash, $pageType, $pageParam ; adds an entry to item_page table
# should perhaps be called DBAddItemPageReference
# purpose of table is to track which items are on which pages

	state $query;
	state @queryParams;

	my $itemHash = shift;

	if ($itemHash eq 'flush') {
		if ($query) {
			WriteLog("DBAddItemPage(flush)");

			if (!$query) {
				WriteLog('Aborting, no query');
				return;
			}

			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = "";
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddItemPage('flush');
		$query = '';
		@queryParams = ();
	}

	my $pageType = shift;
	my $pageParam = shift;

	if (!$pageType) {
		WriteLog('DBAddItemPage: warning: called without $pageType');
		return;
	}
	if (!$pageParam) {
		$pageParam = '';
	}

	WriteLog("DBAddItemPage($itemHash, $pageType, $pageParam)");

	if (!$query) {
		$query = "INSERT OR REPLACE INTO item_page(item_hash, page_name, page_param) VALUES ";
	} else {
		$query .= ',';
	}

	$query .= '(?, ?, ?)';
	push @queryParams, $itemHash, $pageType, $pageParam;
}

sub DBResetPageTouch { # Clears the task table
# Called by clean-build, since it rebuilds the entire site
	WriteMessage("DBResetPageTouch() begin");

	my $query = "DELETE FROM task WHERE task_type = 'page'";
	my @queryParams = ();

	SqliteQuery($query, @queryParams);

	WriteMessage("DBResetPageTouch() end");
}

sub DBDeletePageTouch { # $pageName, $pageParam
#todo optimize
	#my $query = 'DELETE FROM task WHERE page_name = ? AND page_param = ?';
	my $query = "UPDATE task SET priority = 0 WHERE task_type = 'page' AND task_name = ? AND task_param = ?";

	my $pageName = shift;
	my $pageParam = shift;

	my @queryParams = ($pageName, $pageParam);

	SqliteQuery($query, @queryParams);
}

sub DBDeleteItemReferences { # delete all references to item from tables
	WriteLog('DBDeleteItemReferences() ...');

	my $hash = shift;
	if (!IsSha1($hash)) {
		return;
	}

	WriteLog('DBDeleteItemReferences(' . $hash . ')');

	#todo queue all pages in item_page ;
	#todo item_page should have all the child items for replies

	#file_hash
	my @tables = qw(
		author_alias
		config
		item
		item_attribute
	);
	foreach (@tables) {
		my $query = "DELETE FROM $_ WHERE file_hash = '$hash'";
		SqliteQuery($query);
	}

	#item_hash
	my @tables2 = qw(event item_page item_parent location);
	foreach (@tables2) {
		my $query = "DELETE FROM $_ WHERE item_hash = '$hash'";
		SqliteQuery($query);
	}

	{
		my $query = "DELETE FROM vote WHERE source_hash = '$hash'";
		SqliteQuery($query);
	}

	{
		my $query = "DELETE FROM item_attribute WHERE source = '$hash'";
		SqliteQuery($query);
	}


	#source_hash
	my @tables3 = qw(vote);
	foreach (@tables3) {
		my $query = "DELETE FROM $_ WHERE source_hash = '$hash'";
		SqliteQuery($query);
	}

	#todo
	#item_attribute.source
	#item_parent (?)
	#item_page (and refresh)
	#
	#
	#

	#todo any successes deleting stuff should result in a refresh for the affected page
} # DBDeleteItemReferences()

sub DBAddPageTouch { # $pageName, $pageParam; Adds or upgrades in priority an entry to task table
# task table is used for determining which pages need to be refreshed
# is called from IndexTextFile() to schedule updates for pages affected by a newly indexed item
# if $pageName eq 'flush' then all the in-function stored queries are flushed to database.
	state $query;
	state @queryParams;

	my $pageName = shift;

	if ($pageName eq 'index') {
		#return;
		# this can be uncommented during testing to save time
		#todo optimize this so that all pages aren't rewritten at once
	}

	if ($pageName eq 'tag') {
		# if a tag page is being updated,
		# then the tags summary page must be updated also
		DBAddPageTouch('tags');
	}

	if ($pageName eq 'flush') {
		# flush to database queue stored in $query and @queryParams
		if ($query) {
			WriteLog("DBAddPageTouch(flush)");

			if (!$query) {
				WriteLog('Aborting DBAddPageTouch(flush), no query');
				return;
			}

			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = "";
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddPageTouch('flush');
		$query = '';
		@queryParams = ();
	}

	my $pageParam = shift;

	if (!$pageParam) {
		$pageParam = 0;
	}

	my $touchTime = GetTime();

	if ($pageName eq 'author') {
		# cascade refresh items which are by this author
		#todo probably put this in another function
		# could also be done as
		# foreach (author's items) { DBAddPageTouch('item', $item); }
		#todo this is kind of a hack, sould be refactored, probably

		# touch all of author's items too
		#todo fix awkward time() concat
		my $queryAuthorItems = "
			UPDATE task
			SET priority = (priority + 1), touch_time = " . time() . "
			WHERE
				task_type = 'page' AND
				task_name = 'item' AND
				task_param IN (
					SELECT file_hash FROM item_flat WHERE author_key = ?
				)
		";
		my @queryParamsAuthorItems;
		push @queryParamsAuthorItems, $pageParam;

		SqliteQuery($queryAuthorItems, @queryParamsAuthorItems);
	}
	#
	# if ($pageName eq 'item') {
	# 	# cascade refresh items which are by this author
	# 	#todo probably put this in another function
	# 	# could also be done as
	# 	# foreach (author's items) { DBAddPageTouch('item', $item); }
	#
	# 	# touch all of author's items too
	# 	my $queryAuthorItems = "
	# 		UPDATE task
	# 		SET priority = (priority + 1)
	# 		WHERE
	#			task_type = 'page' AND
	# 			task_name = 'item' AND
	# 			task_param IN (
	# 				SELECT file_hash FROM item WHERE author_key = ?
	# 			)
	# 	";
	# 	my @queryParamsAuthorItems;
	# 	push @queryParamsAuthorItems, $pageParam;
	#
	# 	SqliteQuery($queryAuthorItems, @queryParamsAuthorItems);
	# }

	#todo need to incremenet priority after doing this

	WriteLog("DBAddPageTouch($pageName, $pageParam)");

	if (!$query) {
		$query = "INSERT OR REPLACE INTO task(task_type, task_name, task_param, touch_time) VALUES ";
	} else {
		$query .= ',';
	}

	#todo
	# https://stackoverflow.com/a/34939386/128947
	# insert or replace into poet (_id,Name, count) values (
	# 	(select _id from poet where Name = "SearchName"),
	# 	"SearchName",
	# 	ifnull((select count from poet where Name = "SearchName"), 0) + 1)
	#
	# https://stackoverflow.com/a/3661644/128947
	# INSERT OR REPLACE INTO observations
	# VALUES (:src, :dest, :verb,
	#   COALESCE(
	#     (SELECT occurrences FROM observations
	#        WHERE src=:src AND dest=:dest AND verb=:verb),
	#     0) + 1);


	$query .= "('page', ?, ?, ?)";
	push @queryParams, $pageName, $pageParam, $touchTime;
} # DBAddPageTouch()

sub DBGetLabelCounts { # Get total vote counts by tag value
# Takes $orderBy as parameter, with vote_count being default;
#todo can probably be converted to parameterized query
	my $orderBy = shift;
	if ($orderBy) {
	} else {
		$orderBy = 'ORDER BY vote_count DESC';
	}

	my $query = "
		SELECT
			vote_value,
			vote_count
		FROM (
			SELECT
				vote_value,
				COUNT(vote_value) AS vote_count
			FROM
				vote
			WHERE
				file_hash IN (SELECT file_hash FROM item)
			GROUP BY
				vote_value
		)
		WHERE
			vote_count >= 1
		$orderBy;
	";

	my $sth = $dbh->prepare($query);
	$sth->execute();

	my $ref = $sth->fetchall_arrayref();

	$sth->finish();

	return $ref;
}

sub DBGetTagCount { # Gets number of distinct tag/vote values
	my $query = "
		SELECT
			COUNT(vote_value)
		FROM (
			SELECT
				DISTINCT vote_value
			FROM
				vote
			GROUP BY
				vote_value
		)
	";

	my $result = SqliteGetValue($query);

	if ($result) {
		WriteLog('DBGetTagCount: $result = ' . $result);
	} else {
		WriteLog('DBGetTagCount: warning: no $result, returning 0');
		$result = 0;
	}

	return $result;
} # DBGetTagCount()

sub DBGetItemLatestAction { # returns highest timestamp in all of item's children
# $itemHash is the item's identifier

	my $itemHash = shift;
	my @queryParams = ();

	# this is my first recursive sql query
	my $query = '
	SELECT MAX(add_timestamp) AS add_timestamp
	FROM item_flat
	WHERE file_hash IN (
		WITH RECURSIVE item_threads(x) AS (
			SELECT ?
			UNION ALL
			SELECT item_parent.item_hash
			FROM item_parent, item_threads
			WHERE item_parent.parent_hash = item_threads.x
		)
		SELECT * FROM item_threads
	)
	';

	push @queryParams, $itemHash;

	my $sth = $dbh->prepare($query);
	$sth->execute(@queryParams);

	my @aref = $sth->fetchrow_array();

	$sth->finish();

	return $aref[0];
}

#sub GetTopItemsForTag {
#	my $tag = shift;
#	chomp($tag);
#
#	my $query = "
#		SELECT * FROM item_flat WHERE file_hash IN (
#			SELECT file_hash FROM (
#				SELECT file_hash, COUNT(vote_value) AS vote_count
#				FROM vote WHERE vote_value = '" . SqliteEscape($tag) . "'
#				GROUP BY file_hash
#				ORDER BY vote_count DESC
#			)
#		);
#	";
#
#	return $query;
#}

sub DBAddKeyAlias { # adds new author-alias record $key, $alias, $pubkeyFileHash
	# $key = gpg fingerprint
	# $alias = author alias/name
	# $pubkeyFileHash = hash of file in which pubkey resides

	state $query;
	state @queryParams;

	my $key = shift;

	if ($key eq 'flush') {
		if ($query) {
			WriteLog("DBAddKeyAlias(flush)");

			if (!$query) {
				WriteLog('Aborting, no query');
				return;
			}

			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = "";
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddKeyAlias('flush');
		$query = '';
		@queryParams = ();
	}

	my $alias = shift;
	my $pubkeyFileHash = shift;

	if (!$query) {
		$query = "INSERT OR REPLACE INTO author_alias(key, alias, file_hash) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= "(?, ?, ?)";
	push @queryParams, $key, $alias, $pubkeyFileHash;

	ExpireAvatarCache($key); # does fresh lookup, no cache
	DBAddPageTouch('author', $key);
} # DBAddKeyAlias()

sub DBAddItemParent { # Add item parent record. $itemHash, $parentItemHash ;
# Usually this is when item references parent item, by being a reply or a vote, etc.
#todo replace with item_attribute
	state $query;
	state @queryParams;

	my $itemHash = shift;

	if ($itemHash eq 'flush') {
		if ($query) {
			WriteLog('DBAddItemParent(flush)');

			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddPageTouch('flush');
		DBAddItemParent('flush');
		$query = '';
		@queryParams = ();
	}

	my $parentHash = shift;

	if (!$parentHash) {
		WriteLog('DBAddItemParent: warning: $parentHash missing');
		return;
	}

	if ($itemHash eq $parentHash) {
		WriteLog('DBAddItemParent: warning: $itemHash eq $parentHash');
		return;
	}

	if (!$query) {
		$query = "INSERT OR REPLACE INTO item_parent(item_hash, parent_hash) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= '(?, ?)';
	push @queryParams, $itemHash, $parentHash;

	DBAddPageTouch('item', $itemHash);
	DBAddPageTouch('item', $parentHash);
}

sub DBAddItem2 {
	my $filePath = shift;
	my $fileHash = shift;
	my $itemType = shift;
	return DBAddItem($filePath, '', '', $fileHash, $itemType, 0);
}

sub DBAddItem { # $filePath, $itemName, $authorKey, $fileHash, $itemType, $verifyError ; Adds a new item to database
# $filePath = path to text file
# $itemName = item's 'name' (currently hash)
# $authorKey = author's gpg fingerprint
# $fileHash = hash of item
# $itemType = type of item (currently 'txt', 'image', 'url' supported)
# $verifyError = whether there was an error with gpg verification of item

	state $query;
	state @queryParams;

	my $filePath = shift;

	if ($filePath eq 'flush') {
		if ($query) {
			WriteLog("DBAddItem(flush)");

			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();

			DBAddItemAttribute('flush');
		}

		return '';
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddItem('flush');
		$query = '';
		@queryParams = ();
	}

	my $itemName = shift;
	my $authorKey = shift;
	my $fileHash = shift;
	my $itemType = shift;
	my $verifyError = shift;

	#DBAddItemAttribute($fileHash, 'attribute', 'value', 'epoch', 'source');

	if (!$authorKey) {
		$authorKey = '';
	}
#
#	if ($authorKey) {
#		DBAddItemParent($fileHash, DBGetAuthorPublicKeyHash($authorKey));
#	}

	WriteLog("DBAddItem($filePath, $itemName, $authorKey, $fileHash, $itemType, $verifyError);");

	if (!$query) {
		$query = "INSERT OR REPLACE INTO item(file_path, item_name, file_hash, item_type, verify_error) VALUES ";
	} else {
		$query .= ",";
	}
	push @queryParams, $filePath, $itemName, $fileHash, $itemType, $verifyError;

	$query .= "(?, ?, ?, ?, ?)";

	my $filePathRelative = $filePath;
	state $htmlDir = GetDir('html');
	$filePathRelative =~ s/$htmlDir\//\//;

	WriteLog('DBAddItem: $filePathRelative = ' . $filePathRelative . '; $htmlDir = ' . $htmlDir);

	DBAddItemAttribute($fileHash, 'sha1', $fileHash);
	#DBAddItemAttribute($fileHash, 'md5', md5_hex(GetFile($filePath)));
	DBAddItemAttribute($fileHash, 'item_type', $itemType);
	DBAddItemAttribute($fileHash, 'file_path', $filePathRelative);

	if ($verifyError) {
		DBAddItemAttribute($fileHash, 'verify_error', '1');
	}
}

sub DBAddEventRecord { # add event record to database; $itemHash, $eventTime, $eventDuration, $signedBy
	state $query;
	state @queryParams;

	WriteLog("DBAddEventRecord()");

	my $fileHash = shift;

	if ($fileHash eq 'flush') {
		WriteLog("DBAddEventRecord(flush)");

		if ($query) {
			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();
		}

		return;
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddEventRecord('flush');
		$query = '';
		@queryParams = ();
	}

	my $eventTime = shift;
	my $eventDuration = shift;
	my $signedBy = shift;

	if (!$eventTime || !$eventDuration) {
		WriteLog('DBAddEventRecord() sanity check failed! Missing $eventTime or $eventDuration');
		return;
	}

	chomp $eventTime;
	chomp $eventDuration;

	if ($signedBy) {
		chomp $signedBy;
	} else {
		$signedBy = '';
	}

	if (!$query) {
		$query = "INSERT OR REPLACE INTO event(item_hash, event_time, event_duration, author_key) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= '(?, ?, ?, ?)';
	push @queryParams, $fileHash, $eventTime, $eventDuration, $signedBy;
}


sub DBAddLocationRecord { # $itemHash, $latitude, $longitude, $signedBy ; Adds new location record from latlong token
	state $query;
	state @queryParams;

	WriteLog("DBAddLocationRecord()");

	my $fileHash = shift;

	if ($fileHash eq 'flush') {
		WriteLog("DBAddLocationRecord(flush)");

		if ($query) {
			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();
		}

		return;
	}

	if (
		$query
			&&
		(
			length($query) >= DBMaxQueryLength()
				||
			scalar(@queryParams) > DBMaxQueryParams()
		)
	) {
		DBAddLocationRecord('flush');
		$query = '';
		@queryParams = ();
	}

	my $latitude = shift;
	my $longitude = shift;
	my $signedBy = shift;

	if (!$latitude || !$longitude) {
		WriteLog('DBAddLocationRecord() sanity check failed! Missing $latitude or $longitude');
		return;
	}

	chomp $latitude;
	chomp $longitude;

	if ($signedBy) {
		chomp $signedBy;
	} else {
		$signedBy = '';
	}

	if (!$query) {
		$query = "INSERT OR REPLACE INTO location(item_hash, latitude, longitude, author_key) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= '(?, ?, ?, ?)';
	push @queryParams, $fileHash, $latitude, $longitude, $signedBy;
}

###

sub DBAddLabel { # $fileHash, $ballotTime, $voteValue, $signedBy, $sourceHash ; Adds a new label record to an item based on vote/ token
	state $query;
	state @queryParams;

	WriteLog("DBAddLabel()");

	my $fileHash = shift;

	if ($fileHash eq 'flush') {
		WriteLog("DBAddLabel(flush)");

		if ($query) {
			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();
		}

		return;
	}

	if (!$fileHash) {
		WriteLog('DBAddLabel: warning: called without $fileHash');
		return '';
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddLabel('flush');
		DBAddPageTouch('flush');
		$query = '';
	}

	my $labelTime = shift;
	my $voteValue = shift;
	my $signedBy = shift;
	my $sourceHash = shift;

	if (!$labelTime) {
		WriteLog('DBAddLabel: warning: missing $labelTime');
		return '';
	}

#	if (!$signedBy) {
#		WriteLog("DBAddLabel() called without \$signedBy! Returning.");
#	}

	chomp $fileHash;
	chomp $labelTime;
	chomp $voteValue;

	if ($signedBy) {
		chomp $signedBy;
	} else {
		$signedBy = '';
	}

	if ($sourceHash) {
		chomp $sourceHash;
	} else {
		$sourceHash = '';
	}

	if (!$query) {
		$query = "INSERT OR REPLACE INTO vote(file_hash, label_time, vote_value, author_key, source_hash) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= '(?, ?, ?, ?, ?)';
	push @queryParams, $fileHash, $labelTime, $voteValue, $signedBy, $sourceHash;

	DBAddPageTouch('tag', $voteValue);
	DBAddPageTouch('item', $fileHash);
}

sub DBGetItemAttribute { # $fileHash, [$attribute] ; returns all if attribute not specified
	my $fileHash = shift;
	my $attribute = shift;

	if ($fileHash) {
		if ($fileHash =~ m/[^a-f0-9]/) {
			WriteLog('DBGetItemAttribute: warning: sanity check failed on $fileHash');
			return '';
		} else {
			$fileHash =~ s/[^a-f0-9]//g;
		}
	} else {
		return '';
	}
	if (!$fileHash) {
		WriteLog('DBGetItemAttribute: warning: where is $fileHash?');
		return '';
	}

	if ($attribute) {
		$attribute =~ s/[^a-zA-Z0-9_]//g;
		#todo add sanity check
	} else {
		$attribute = '';
	}

	my $query = "SELECT attribute, value FROM item_attribute_latest WHERE file_hash = '$fileHash'";
	if ($attribute) {
		$query .= " AND attribute = '$attribute'";
	}

	my $results = SqliteQuery3($query);
	return $results;
} # DBGetItemAttribute()


sub DBGetItemAttributeValue { # $fileHash, [$attribute] ; returns one value
	my $fileHash = shift;
	my $attribute = shift;

	if ($fileHash) {
		if ($fileHash =~ m/[^a-f0-9]/) {
			WriteLog('DBGetItemAttributeValue: warning: sanity check failed on $fileHash');
			return '';
		} else {
			$fileHash =~ s/[^a-f0-9]//g;
		}
	} else {
		return '';
	}
	if (!$fileHash) {
		WriteLog('DBGetItemAttributeValue: warning: where is $fileHash?');
		return '';
	}

	if ($attribute) {
		$attribute =~ s/[^a-zA-Z0-9_]//g;
		#todo add sanity check
	} else {
		$attribute = '';
	}

	my $query = "SELECT value FROM item_attribute_latest WHERE file_hash = '$fileHash'";
	if ($attribute) {
		$query .= " AND attribute = '$attribute'";
	} else {
		WriteLog('DBGetItemAttributeValue: warning: called without $attribute');
		return '';
	}

	my $result = SqliteGetValue($query);
	return $result;
} # DBGetItemAttributeValue()

sub DBAddItemAttribute { # $fileHash, $attribute, $value, $epoch, $source # add attribute to item
# currently no constraints
	state $query;
	state @queryParams;

	WriteLog("DBAddItemAttribute()");

	my $fileHash = shift;

	if ($fileHash eq 'flush') {
		WriteLog("DBAddItemAttribute(flush)");

		if ($query) {
			$query .= ';';

			SqliteQuery($query, @queryParams);

			$query = '';
			@queryParams = ();
		}

		return;
	}

	if (!$fileHash) {
		WriteLog('DBAddItemAttribute() called without $fileHash! Returning.');
	}

	if ($query && (length($query) > DBMaxQueryLength() || scalar(@queryParams) > DBMaxQueryParams())) {
		DBAddItemAttribute('flush');
		$query = '';
	}

	my $attribute = shift;
	my $value = shift;
	my $epoch = shift;
	my $source = shift;

	if (!$attribute) {
		WriteLog('DBAddItemAttribute: warning: called without $attribute');
		return '';
	}
	if (!defined($value)) {
		WriteLog('DBAddItemAttribute: warning: called without $value, $attribute = ' . $attribute);
		return '';
	}

	chomp $fileHash;
	chomp $attribute;
	chomp $value;

	if (!$epoch) {
		$epoch = '';
	}
	if (!$source) {
		$source = '';
	}

	chomp $epoch;
	chomp $source;

	WriteLog("DBAddItemAttribute($fileHash, $attribute, $value, $epoch, $source)");

	if (!$query) {
		$query = "INSERT OR REPLACE INTO item_attribute(file_hash, attribute, value, epoch, source) VALUES ";
	} else {
		$query .= ",";
	}

	$query .= '(?, ?, ?, ?, ?)';
	push @queryParams, $fileHash, $attribute, $value, $epoch, $source;
}

sub DBGetAddedTime { # return added time for item specified
	my $fileHash = shift;
	if (!$fileHash) {
		WriteLog('DBGetAddedTime: warning: $fileHash missing');
		return;
	}
	chomp ($fileHash);

	if (!IsSha1($fileHash)) {
		WriteLog('DBGetAddedTime: warning: called with invalid parameter! returning');
		return;
	}

	if (!IsSha1($fileHash) || $fileHash ne SqliteEscape($fileHash)) {
		WriteLog('DBGetAddedTime: warning: important sanity check failed! this should never happen: !IsSha1($fileHash) || $fileHash ne SqliteEscape($fileHash)');
		return '';
	} #todo ideally this should verify it's a proper hash too

	my $query = "
		SELECT
			MIN(value) AS add_timestamp
		FROM item_attribute
		WHERE
			file_hash = '$fileHash' AND
			attribute IN ('chain_timestamp', 'gpg_timestamp', 'puzzle_timestamp', 'access_log_timestamp')
	";
	# my $query = "SELECT add_timestamp FROM added_time WHERE file_hash = '$fileHash'";

	WriteLog($query);

	if ($dbh) {
		my $sth = $dbh->prepare($query);
		$sth->execute();

		my @aref = $sth->fetchrow_array();

		$sth->finish();

		my $resultUnHacked = $aref[0];
		#todo do this properly

		return $resultUnHacked;
	} else {
		WriteLog('DBGetAddedTime: warning: $dbh was missing, returning empty-handed');
	}
} # DBGetAddedTime()

sub DBGetItemListByTagList { #get list of items by taglist (as array)
# uses DBGetItemList()
#	my @tagListArray = shift;

#	if (scalar(@tagListArray) < 1) {
#		return;
#	}

	#todo sanity checks

	my @tagListArray = @_;

	my $tagListCount = scalar(@tagListArray);

	my $tagListArrayText = "'" . join ("','", @tagListArray) . "'";

	my %queryParams;
	my $whereClause = "
		WHERE file_hash IN (
			SELECT file_hash FROM (
				SELECT
					COUNT(id) AS vote_count,
						file_hash
				FROM vote
				WHERE vote_value IN ($tagListArrayText)
				GROUP BY file_hash
			) WHERE vote_count >= $tagListCount
		)
	";
	WriteLog("DBGetItemListByTagList");
	WriteLog("$whereClause");

	$queryParams{'where_clause'} = $whereClause;

	#todo this is currently an "OR" select, but it should be an "AND" select.

	return DBGetItemList(\%queryParams);
}

sub DBGetItemList { # get list of items from database. takes reference to hash of parameters; returns array of hashrefs
	my $paramHashRef = shift;
	my %params = %$paramHashRef;

	#supported params:
	#where_clause = where clause for sql query
	#order_clause
	#limit_clause

	my $query;
	my $itemFields = DBGetItemFields();
	$query = "
		SELECT
			$itemFields
		FROM
			item_flat
	";

	#todo sanity check: typically, none of these should have a semicolon?
	if (defined ($params{'join_clause'})) {
		$query .= " " . $params{'join_clause'};
	}
	if (defined ($params{'where_clause'})) {
		$query .= " " . $params{'where_clause'};
	}
	if (defined ($params{'group_by_clause'})) {
		$query .= " " . $params{'group_by_clause'};
	}
	if (defined ($params{'order_clause'})) {
		$query .= " " . $params{'order_clause'};
	}
	if (defined ($params{'limit_clause'})) {
		$query .= " " . $params{'limit_clause'};
	}

	#todo bind params and use hash of parameters

	WriteLog('DBGetItemList: $query = ' . $query);

	my $sth = $dbh->prepare($query);
	$sth->execute();

	my @resultsArray = ();

	while (my $row = $sth->fetchrow_hashref()) {
		push @resultsArray, $row;
	}

	return @resultsArray;
} # DBGetItemList()

sub DBGetAllAppliedTags { # return all tags that have been used at least once
	my $query = "
		SELECT DISTINCT vote_value FROM vote
		JOIN item ON (vote.file_hash = item.file_hash)
	";

	my $sth = $dbh->prepare($query);

	my @ary;

	$sth->execute();

	$sth->bind_columns(\my $val1);

	while ($sth->fetch) {
		push @ary, $val1;
	}

	return @ary;
}

sub DBGetItemListForAuthor { # return all items attributed to author
	my $author = shift;
	chomp($author);

	if (!IsFingerprint($author)) {
		WriteLog('DBGetItemListForAuthor called with invalid parameter! returning');
		return;
	}
	$author = SqliteEscape($author);

	my %params = {};

	$params{'where_clause'} = "WHERE author_key = '$author'";

	return DBGetItemList(\%params);
}

sub DBGetAuthorList { # returns list of all authors' gpg keys as array
	my $query = "SELECT key FROM author";

	my $sth = $dbh->prepare($query);

	$sth->execute();

	my @resultsArray = ();

	while (my $row = $sth->fetchrow_hashref()) {
		push @resultsArray, $row;
	}

	return @resultsArray;
}

sub DBGetAuthorAlias { # returns author's alias by gpg key
	my $key = shift;
	chomp $key;

	if (!IsFingerprint($key)) {
		WriteLog('DBGetAuthorAlias: warning: called with invalid parameter! returning');
		return;
	}

	$key = SqliteEscape($key);

	if ($key) {
		my $query = "SELECT alias FROM author_alias WHERE key = '$key'";
		return SqliteGetValue($query);
	} else {
		return "";
	}
}

sub DBGetAuthorScore { # returns author's total score
# score is the sum of all the author's items' scores
# $key = author's gpg key
	my $key = shift;
	chomp ($key);

	if (!IsFingerprint($key)) {
		WriteLog('Problem! DBGetAuthorScore called with invalid parameter! returning');
		return;
	}

	state %scoreCache;
	if (exists($scoreCache{$key})) {
		return $scoreCache{$key};
	}

	$key = SqliteEscape($key);

	if ($key) { #todo fix non-param sql
		my $query = "SELECT author_score FROM author_score WHERE author_key = '$key'";
		$scoreCache{$key} = SqliteGetValue($query);
		return $scoreCache{$key};
	} else {
		return "";
	}
}

sub DBGetAuthorItemCount { # returns number of items attributed to author identified by $key
# $key = author's gpg key
	my $key = shift;
	chomp ($key);

	if (!IsFingerprint($key)) {
		WriteLog('DBGetAuthorItemCount: warning: called with non-fingerprint parameter, returning');
		return 0;
	}
	if ($key ne SqliteEscape($key)) {
		# should be redundant, but what the heck
		WriteLog('DBGetAuthorItemCount: warning: $key != SqliteEscape($key)');
		return 0;
	}

	state %scoreCache;
	if (exists($scoreCache{$key})) {
		return $scoreCache{$key};
	}

	if ($key) {
		my $query = "SELECT COUNT(file_hash) file_hash_count FROM (SELECT DISTINCT file_hash FROM item_flat WHERE author_key = ?)";
		$scoreCache{$key} = SqliteGetValue($query, $key);
		return $scoreCache{$key};
	} else {
		return 0;
	}

	WriteLog('DBGetAuthorItemCount: warning: unreachable reached');
	return 0;
} # DBGetAuthorItemCount()

sub DBGetAuthorSeen { # return timestamp of most recent item attributed to author
# $key = author's gpg key
	my $key = shift;
	chomp ($key);

	if (!IsFingerprint($key)) {
		WriteLog('Problem! DBGetAuthorLastSeen called with invalid parameter! returning');
		return;
	}

	state %lastSeenCache;
	if (exists($lastSeenCache{$key})) {
		return $lastSeenCache{$key};
	}

	$key = SqliteEscape($key);

	if ($key) { #todo fix non-param sql
		my $query = "SELECT MAX(item_flat.add_timestamp) AS author_seen FROM item_flat WHERE author_key = '$key'";
		$lastSeenCache{$key} = SqliteGetValue($query);
		return $lastSeenCache{$key};
	} else {
		return "";
	}
}


sub DBGetAuthorPublicKeyHash { # Returns the hash/identifier of the file containing the author's public key
# $key = author's gpg fingerprint
# cached in hash called %authorPubKeyCache

	my $key = shift;
	chomp ($key);

	if (!IsFingerprint($key)) {
		WriteLog('Problem! DBGetAuthorPublicKeyHash called with invalid parameter! returning');
		return;
	}

	state %authorPubKeyCache;
	if (exists($authorPubKeyCache{$key}) && $authorPubKeyCache{$key}) {
		WriteLog('DBGetAuthorPublicKeyHash: returning from memo: ' . $authorPubKeyCache{$key});
		return $authorPubKeyCache{$key};
	}

	$key = SqliteEscape($key);

	if ($key) { #todo fix non-param sql
		my $query = "SELECT MAX(author_alias.file_hash) AS file_hash FROM author_alias WHERE key = '$key'";
		my $fileHashReturned = SqliteGetValue($query);
		if ($fileHashReturned) {
			$authorPubKeyCache{$key} = SqliteGetValue($query);
			WriteLog('DBGetAuthorPublicKeyHash: returning ' . $authorPubKeyCache{$key});
			return $authorPubKeyCache{$key};
		} else {
			WriteLog('DBGetAuthorPublicKeyHash: database drew a blank, returning 0');
			return 0;
		}
	} else {
		return "";
	}
} # DBGetAuthorPublicKeyHash()

sub DBGetItemFields { # Returns fields we typically need to request from item_flat table
	my $itemFields =
		"item_flat.file_path file_path,
		item_flat.item_name item_name,
		item_flat.file_hash file_hash,
		item_flat.author_key author_key,
		item_flat.child_count child_count,
		item_flat.parent_count parent_count,
		item_flat.add_timestamp add_timestamp,
		item_flat.item_title item_title,
		item_flat.item_score item_score,
		item_flat.labels_list labels_list,
		item_flat.item_type item_type";

	return $itemFields;
}

sub DBGetTopAuthors { # Returns top-scoring authors from the database
	WriteLog('DBGetTopAuthors() begin');

	my $query = "
		SELECT
			author_key,
			author_alias,
			author_score,
			author_seen,
			item_count
		FROM author_flat
		ORDER BY author_score DESC
		LIMIT 1024;
	";

	my @queryParams = ();

	my $sth = $dbh->prepare($query);
	$sth->execute(@queryParams);

	my @resultsArray = ();

	while (my $row = $sth->fetchrow_hashref()) {
		push @resultsArray, $row;
	}

	return @resultsArray;
} # DBGetTopAuthors()

sub DBGetTopItems { # get top items minus flag (hard-coded for now)
	WriteLog('DBGetTopItems()');

	my %queryParams;
	$queryParams{'where_clause'} = "WHERE item_score > 0";
	$queryParams{'order_clause'} = "ORDER BY add_timestamp DESC";
	$queryParams{'limit_clause'} = "LIMIT 100";
	my @resultsArray = DBGetItemList(\%queryParams);

	return @resultsArray;
}

sub DBGetItemsByPrefix { # $prefix ; get items whose hash begins with $prefix
	my $prefix = shift;
	if (!IsItemPrefix($prefix)) {
		WriteLog('DBGetItemsByPrefix: warning: $prefix sanity check failed');
		return '';
	}

	my $itemFields = DBGetItemFields();
	my $whereClause;
	$whereClause = "
		WHERE
			(file_hash LIKE '%$prefix')

	"; #todo remove hardcoding here

	my $query = "
		SELECT
			$itemFields
		FROM
			item_flat
		$whereClause
		ORDER BY
			add_timestamp DESC
		LIMIT 50;
	";

	WriteLog('DBGetItemsByPrefix: $query = ' . $query);
	my @queryParams;

	my $sth = $dbh->prepare($query);
	$sth->execute(@queryParams);

	my @resultsArray = ();
	while (my $row = $sth->fetchrow_hashref()) {
		push @resultsArray, $row;
	}

	WriteLog('DBGetItemsByPrefix: scalar(@resultsArray) = ' . @resultsArray);

	return @resultsArray;
} # DBGetItemsByPrefix()

sub DBGetItemVoteTotals { # get tag counts for specified item, returned as hash of [tag] -> count
	my $fileHash = shift;
	if (!$fileHash) {
		WriteLog('DBGetItemVoteTotals: warning: $fileHash missing, returning');
		return 0;
	}

	chomp $fileHash;

	if (!IsItem($fileHash)) {
		WriteLog('DBGetItemVoteTotals: warning: sanity check failed, returned');
		return;
	}

	WriteLog("DBGetItemVoteTotals($fileHash)");

	my $query = "
		SELECT
			vote_value,
			COUNT(vote_value) AS vote_count
		FROM
			vote
		WHERE
			file_hash = ?
		GROUP BY
			vote_value
		ORDER BY
			vote_count DESC;
	";

	my @queryParams;
	push @queryParams, $fileHash;

	my $sth = $dbh->prepare($query);
	$sth->execute(@queryParams);

	my %voteTotals;

	my $tagTotal;
	while ($tagTotal = $sth->fetchrow_arrayref()) {
		$voteTotals{@$tagTotal[0]} = @$tagTotal[1];
	}

	$sth->finish();

	return %voteTotals;
} # DBGetItemVoteTotals()

1;








		if ($message) {
			# cache the processed message text
			my $messageCacheName = GetMessageCacheName($fileHash);
			if ($txt) {
				WriteLog("IndexTextFile: \n====\n" . $messageCacheName . "\n====\n" . $message . "\n====\n" . $txt . "\n====\n");
			} else {
				WriteLog('IndexTextFile: warning: $txt was false; $fileHash = ' . $fileHash . '; $messageCacheName = ' . $messageCacheName);
			}
			PutFile($messageCacheName, $message);
		} else {
			WriteLog('IndexTextFile: I was going to save $messageCacheName, but $message is blank!');
		}

		# below we call DBAddItem, which accepts an author key
		if ($isSigned) {
			# If message is signed, use the signer's key
			DBAddItem($file, $itemName, $gpgKey, $fileHash, 'txt', $verifyError);

			if ($gpgTimestamp) {
				my $gpgTimestampEpoch = `date -d "$gpgTimestamp" +%s`;
				DBAddItemAttribute($fileHash, 'gpg_timestamp', $gpgTimestampEpoch);
			}
		} else {
			if ($hasCookie) {
				# Otherwise, if there is a cookie, use the cookie
				DBAddItem($file, $itemName, $hasCookie, $fileHash, 'txt', $verifyError);
			} else {
				# Otherwise add with an empty author key
				DBAddItem($file, $itemName, '', $fileHash, 'txt', $verifyError);
			}
		}

		DBAddPageTouch('read');
		DBAddPageTouch('item', $fileHash);
		if ($isSigned && $gpgKey && IsAdmin($gpgKey)) {
			$isAdmin = 1;
			DBAddLabel($fileHash, 0, 'admin');
			DBAddPageTouch('tag', 'admin');
		}
		if ($isSigned) {
			DBAddPageTouch('author', $gpgKey);
			DBAddPageTouch('authors');
		} elsif ($hasCookie) {
			DBAddPageTouch('author', $hasCookie);
			DBAddPageTouch('authors');
		}
		DBAddPageTouch('stats');
		DBAddPageTouch('rss');
		DBAddPageTouch('index');
		DBAddPageTouch('compost');
		DBAddPageTouch('chain');
		DBAddPageTouch('flush'); #todo shouldn't be here
	}
	return $fileHash;
} # IndexTextFile()


















		if ($gpgKey) { #hack
			my $gpgWelcomeFilename = 'html/txt/welcome_' . $gpgKey . '.txt';
			my $gpgWelcomeCommand = 'echo "Welcome" | gpg --trust-model always --armor --encrypt -r ' . $gpgKey . ' > ' . $gpgWelcomeFilename;
			WriteLog('IndexTextFile: $gpgWelcomeCommand = ' . $gpgWelcomeCommand);
			$gpgWelcomeCommand = 'echo "Welcome" | gpg --trusted-key ' . $gpgKey . ' --armor --encrypt -r ' . $gpgKey . ' > ' . $gpgWelcomeFilename;
			WriteLog('IndexTextFile: $gpgWelcomeCommand = ' . $gpgWelcomeCommand);
		}



	while (@hashTags) {
		my $hashTagToken = shift @hashTags;
		$hashTagToken = trim($hashTagToken);
		my $hashTag = shift @hashTags;
		$hashTag = trim($hashTag);

		if ($hashTag && (IsAdmin($gpgKey) || $authorHasLabel{'admin'} || $authorHasLabel{$hashTag})) {
			#if ($hashTag) {
			WriteLog('IndexTextFile: $hashTag = ' . $hashTag);

			$hasToken{$hashTag} = 1;

			if ($hasParent) {
				WriteLog('$hasParent');

			} # if ($hasParent)
			else { # no parent, !($hasParent)
				WriteLog('$hasParent is FALSE');

				if ($isSigned) {
					# include author's key if message is signed
					DBAddLabel($fileHash, $addedTime, $hashTag, $gpgKey, $fileHash);
				}
				else {
					if ($hasCookie) {
						DBAddLabel($fileHash, $addedTime, $hashTag, $hasCookie, $fileHash);
					} else {
						DBAddLabel($fileHash, $addedTime, $hashTag, '', $fileHash);
					}
				}
			}

			DBAddPageTouch('tag', $hashTag);

			$detokenedMessage =~ s/#$hashTag//g;
		} # if ($hashTag)
	} # while (@hashTags)
} # if (GetConfig('admin/token/hashtag') && $message)









{
	# look up author's tags

	my @tagsAppliedToAuthor = DBGetAllAppliedTags(DBGetAuthorPublicKeyHash($gpgKey));
	foreach my $tagAppliedToAuthor (@tagsAppliedToAuthor) {
		$authorHasLabel{$tagAppliedToAuthor} = 1;
		my $tagsInTagSet = GetTemplate('tagset/' . $tagAppliedToAuthor);
		# if ($tagsInTagSet) {
		# 	foreach my $tagInTagSet (split("\n", $tagsInTagSet)) {
		# 		if ($tagInTagSet) {
		# 			$authorHasLabel{$tagInTagSet} = 1;
		# 		}
		# 	}
		# }
	}
}
#DBAddItemAttribute($fileHash, 'x_author_tags', join(',', keys %authorHasLabel));





















		#my $lineCount = @setTitleToLines / 3;
		while (@lines) {
			# loop through all found title: token lines
			my $token = shift @lines;
			my $space = shift @lines;
			my $value = shift @lines;

			chomp $token;
			chomp $space;
			chomp $value;
			$value = trim($value);

			my $reconLine; # reconciliation
			$reconLine = $token . $space . $value;

			WriteLog('IndexTextFile: #verify $reconLine = ' . $reconLine);
			WriteLog('IndexTextFile: #verify $value = ' . $value);

			if ($value =~ m|https://www.reddit.com/user/([0-9a-zA-Z\-_]+)/?|) {
				# reddit verify
				$hasToken{'verify'} = 1;
				my $redditUsername = $1;
				my $valueHash = sha1_hex($value);
				my $profileHtml = '';

				if (-e "once/$valueHash") {
					WriteLog('IndexTextFile: once exists');
					$profileHtml = GetFile("once/$valueHash");
				} else {
					my $curlCommand = 'curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36" "' . EscapeShellChars($value) .'.json"';
					WriteLog('IndexTextFile: #verify once needed, doing curl');
					WriteLog('IndexTextFile: #verify "' . $curlCommand . '"');

					my $curlResult = `$curlCommand`; #note the backticks
					# this could be dangerous, but the url is sanitized above

					PutFile("once/$valueHash", $curlResult);
					$profileHtml = GetFile("once/$valueHash");
				}

				WriteLog('IndexTextFile: #verify $value = ' . $value);

				if ($hasParent) {
					# has parent(s), so add title to each parent
					foreach my $itemParent (@itemParents) {
						if (index($profileHtml, $itemParent) != -1) {
							DBAddItemAttribute($itemParent, 'reddit_url', $value, $addedTime, $fileHash);
							DBAddItemAttribute($itemParent, 'reddit_username', $redditUsername, $addedTime, $fileHash);
							DBAddPageTouch('item', $itemParent);
						}
					} # @itemParents
				} else {
					# no parents, ignore
					WriteLog('IndexTextFile: AccessLogHash: Item has no parent, ignoring');

					# DBAddLabel($fileHash, $addedTime, 'hasAccessLogHash');
					# DBAddItemAttribute($fileHash, 'AccessLogHash', $titleGiven, $addedTime);
				}
			} #reddit


			if ($value =~ m|https://www.twitter.com/([0-9a-zA-Z_]+)/?|) { # supposed to be 15 chars or less
				# twitter verify
				$hasToken{'verify'} = 1;
				my $twitterUsername = $1;
				my $valueHash = sha1_hex($value);
				my $profileHtml = '';

				if (-e "once/$valueHash") {
					WriteLog('IndexTextFile: once exists');
					$profileHtml = GetFile("once/$valueHash");
				} else {
					my $curlCommand = 'curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36" "' . EscapeShellChars($value);

					WriteLog('IndexTextFile: #verify once needed, doing curl');
					WriteLog('IndexTextFile: #verify "' . $curlCommand . '"');

					my $curlResult = `$curlCommand`; #note the backticks
					# should be safe because url is sanitized above

					PutFile("once/$valueHash", $curlResult);
					$profileHtml = GetFile("once/$valueHash");
				}

				WriteLog('IndexTextFile: #verify $value = ' . $value);

				if ($hasParent) {
					# has parent(s), so add title to each parent
					foreach my $itemParent (@itemParents) {
						if (index($profileHtml, $itemParent) != -1) {
							DBAddItemAttribute($itemParent, 'twitter_url', $value, $addedTime, $fileHash);
							DBAddItemAttribute($itemParent, 'twitter_username', $twitterUsername, $addedTime, $fileHash);
							DBAddPageTouch('item', $itemParent);
						}
					} # @itemParents
				} else {
					# no parents, ignore
					WriteLog('IndexTextFile: AccessLogHash: Item has no parent, ignoring');

					# DBAddLabel($fileHash, $addedTime, 'hasAccessLogHash');
					# DBAddItemAttribute($fileHash, 'AccessLogHash', $titleGiven, $addedTime);
				}
			} # twitter

			if ($value =~ m|https://www.instagram.com/([0-9a-zA-Z._]+)/?|) {
				# instagram verification (not working yet)
				$hasToken{'verify'} = 1;
				my $instaUsername = $1;
				my $valueHash = sha1_hex($value);
				my $profileHtml = '';

				if (-e "once/$valueHash") {
					WriteLog('IndexTextFile: once exists');
					$profileHtml = GetFile("once/$valueHash");
				} else {
					my $curlCommand = 'curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36" "' . EscapeShellChars($value) . '"';

					WriteLog('IndexTextFile: #verify once needed, doing curl');
					WriteLog('IndexTextFile: #verify "'.$curlCommand.'"');

					my $curlResult = `$curlCommand`; #note backticks
					# should be safe because url is sanitized above

					PutFile("once/$valueHash", $curlResult); # runs the curl command, note the backticks
					$profileHtml = GetFile("once/$valueHash");
				}

				WriteLog('IndexTextFile: #verify $value = ' . $value);

				if ($hasParent) {
					# has parent(s), so add title to each parent
					foreach my $itemParent (@itemParents) {
						if (index($profileHtml, $itemParent) != -1) {
							DBAddItemAttribute($itemParent, 'insta_url', $value, $addedTime, $fileHash);
							DBAddItemAttribute($itemParent, 'insta_username', $instaUsername, $addedTime, $fileHash);
							DBAddPageTouch('item', $itemParent);
						}
					} # @itemParents
				} else {
					# no parents, ignore
					WriteLog('IndexTextFile: AccessLogHash: Item has no parent, ignoring');

					# DBAddLabel($fileHash, $addedTime, 'hasAccessLogHash');
					# DBAddItemAttribute($fileHash, 'AccessLogHash', $titleGiven, $addedTime);
				}
			} #instagram

			$message = str_replace($reconLine, '[Verified]', $message);
			$detokenedMessage = str_replace($reconLine, '[Verified]', $detokenedMessage);
			# $message = str_replace($reconLine, '[AccessLogHash: ' . $value . ']', $message);
		} # @lines
	}







		#look for #config and #resetconfig #setconfig
		if (GetConfig('admin/token/config') && $message) {
			if (
				IsAdmin($gpgKey) # admin can always config
					||
				GetConfig('admin/anyone_can_config') # anyone can config
					||
				(
					# signed can config
					GetConfig('admin/signed_can_config')
						&&
					$isSigned
				)
					||
				(
					# cookied can config
					GetConfig('admin/cookied_can_config')
						&&
					$hasCookie
				)
			) {
				# preliminary conditions met
				my @configLines = ($message =~ m/(config)(\W)([a-z0-9\/_]+)(\W+?[=]?\W+?)(.+?)$/mg);
				#                                 1       2   3             4             5
				WriteLog('@configLines = ' . scalar(@configLines));

				if (@configLines) {
					#my $lineCount = @configLines / 5;

					while (@configLines) {
						my $configAction = shift @configLines; # 1
						my $space1 = shift @configLines; # 2
						my $configKey = shift @configLines; # 3
						my $space2 = ''; # 4
						my $configValue; # 5

						# allow theme aliasing, currently only one alias: theme to setting/theme
						my $configKeyActual = $configKey;

						$space2 = shift @configLines;
						$configValue = shift @configLines;
						$configValue = trim($configValue);

						if ($configAction && $configKey && $configKeyActual) {
							my $reconLine;
							$reconLine = $configAction . $space1 . $configKey . $space2 . $configValue;
							WriteLog('IndexTextFile: #config: $reconLine = ' . $reconLine);

							if (ConfigKeyValid($configKey) && $reconLine) {
								WriteLog('IndexTextFile: ConfigKeyValid() passed!');
								WriteLog('$reconLine = ' . $reconLine);
								WriteLog('$gpgKey = ' . ($gpgKey ? $gpgKey : '(no)'));
								WriteLog('$isSigned = ' . ($isSigned ? $isSigned : '(no)'));
								WriteLog('$configKey = ' . $configKey);
								WriteLog('signed_can_config = ' . GetConfig('admin/signed_can_config'));
								WriteLog('anyone_can_config = ' . GetConfig('admin/anyone_can_config'));

								my $canConfig = 0;
								if (IsAdmin($gpgKey)) {
									$canConfig = 1;
								}

								if (!$canConfig && substr(lc($configKeyActual), 0, 5) ne 'admin') {
									if (GetConfig('admin/signed_can_config')) {
										if ($isSigned) {
											$canConfig = 1;
										}
									}
									if (GetConfig('admin/cookied_can_config')) {
										if ($hasCookie) {
											$canConfig = 1;
										}
									}
									if (GetConfig('admin/anyone_can_config')) {
										$canConfig = 1;
									}
								}

								if ($canConfig)	{
									# checks passed, we're going to update/reset a config entry
									DBAddLabel($fileHash, $addedTime, 'config');

									$reconLine = quotemeta($reconLine);

									if ($configValue eq 'default') {
										DBAddConfigValue($configKeyActual, $configValue, $addedTime, 1, $fileHash);
										$message =~ s/$reconLine/[Successful config reset: $configKeyActual will be reset to default.]/g;
									}
									else {
										DBAddConfigValue($configKeyActual, $configValue, $addedTime, 0, $fileHash);
										$message =~ s/$reconLine/[Successful config change: $configKeyActual = $configValue]/g;
									}

									$detokenedMessage =~ s/$reconLine//g;

								} # if ($canConfig)
								else {
									$message =~ s/$reconLine/[Attempted change to $configKeyActual ignored. Reason: Not operator.]/g;
									$detokenedMessage =~ s/$reconLine//g;
								}
							} # if (ConfigKeyValid($configKey))
							else {
								#$message =~ s/$reconLine/[Attempted change to $configKey ignored. Reason: Config key has no default.]/g;
								#$detokenedMessage =~ s/$reconLine//g;
							}
						}
					} # while
				}
	}
	} # if (GetConfig('admin/token/config') && $message)







		if (0) {
			my %authorHasLabel;
			{
				# look up author's tags

				my @tagsAppliedToAuthor = DBGetAllAppliedTags(DBGetAuthorPublicKeyHash($gpgKey));
				foreach my $tagAppliedToAuthor (@tagsAppliedToAuthor) {
					$authorHasLabel{$tagAppliedToAuthor} = 1;
					my $tagsInTagSet = GetTemplate('tagset/' . $tagAppliedToAuthor);
					# if ($tagsInTagSet) {
					# 	foreach my $tagInTagSet (split("\n", $tagsInTagSet)) {
					# 		if ($tagInTagSet) {
					# 			$authorHasLabel{$tagInTagSet} = 1;
					# 		}
					# 	}
					# }
				}
			}
			#DBAddItemAttribute($fileHash, 'x_author_tags', join(',', keys %authorHasLabel));
		}



sub RemoveOldItems {
	my $query = "
		SELECT * FROM item_flat WHERE file_hash NOT IN (
			SELECT file_hash FROM item_flat
			WHERE
				',' || labels_list || ',' like '%approve%'
					OR
				file_hash IN (
					SELECT item_hash
					FROM item_parent
					WHERE parent_hash IN (
						SELECT file_hash FROM item_flat WHERE ',' || labels_list || ',' LIKE '%approve%'
					)
				)
		)
		ORDER BY add_timestamp
	";
}




===


#sub GetItemTemplate-1 {
#	my %file = %{shift @_}; #todo should be better formatted
#
#	if (
#		defined($file{'file_hash'}) &&
#		defined($file{'item_type'})
#	) {
#		WriteLog('GetItemTemplate: sanity check passed, defined($file{file_path}');
#
#		if ($file{'item_type'} eq 'txt') {
#			my $message = GetItemDetokenedMessage($file{'file_hash'});
#			$message = FormatMessage($message, \%file);
#		}
#
#		my $itemTemplate = '';
#		{
#			my %windowParams;
#			$windowParams{'body'} = GetTemplate('html/item/item.template'); # GetItemTemplate()
#			$windowParams{'title'} = HtmlEscape($file{'item_title'});
#			$windowParams{'guid'} = substr(sha1_hex($file{'file_hash'}), 0, 8);
#
#			$windowParams{'body'} =~ s/\$itemText/$message/;
#
#			{
#				my $statusBar = '';
#
#				$statusBar .= GetItemHtmlLink($file{'file_hash'}, GetTimestampWidget($file{'add_timestamp'}));
#				$statusBar .= '; ';
#
#				$statusBar .= '<span class=advanced>';
#				$statusBar .= substr($file{'file_hash'}, 0, 8);
#				$statusBar .= '; ';
#				$statusBar .= '</span>';
#
#				if ($file{'author_key'}) {
#					$statusBar .= trim(GetAuthorLink($file{'author_key'}));
#					$statusBar .= '; ';
#				}
#
#				WriteLog('GetItemTemplate: ' . $file{'file_hash'} . ': $file{child_count} = ' . $file{'child_count'});
#
#				if ($file{'child_count'}) {
#					$statusBar .= '<a href="' . GetHtmlFilename($file{'file_hash'}) . '#reply">';
#					if ($file{'child_count'}) {
#						$statusBar .= 'reply(' . $file{'child_count'} . ')';
#					} else {
#						$statusBar .= 'reply';
#					}
#					$statusBar .= '</a>; ';
#				}
#
#				$statusBar .= GetItemLabelButtons($file{'file_hash'}, 'all');
#				$windowParams{'status'} = $statusBar;
#			}
#
#			$windowParams{'content'} = $message;
#
#			$itemTemplate = GetDialogX2(\%windowParams);
#		}
#		return $itemTemplate;
#
#	} else {
#		WriteLog('GetItemTemplate: sanity check FAILED, defined($file{file_path}');
#		return '';
#	}
#} # GetItemTemplate()
