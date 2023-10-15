#!/usr/bin/perl -T

# gpgpg.pl (gnu pretty good privacy guard)

# INPUT:
# path(s) to one or more text file(s)
#
# PROCESS:
# look for gpg-looking strings #gpg_strings
# prepare arguments for calling gpg: #gpg_prepare
#   if signed message: perform signature verification #gpg_signed
#   if public key: adds to keychain #gpg_pubkey
#   if encrypted message: displays message #gpg_encrypted
# call gpg #gpg_call
#   STDOUT and STDERR is piped to cache #gpg_command_pipe
# naive regex string-matching is used to pull out values #gpg_naive_regex
#   anything good is written to database
#   #gpg_naive_regex_pubkey #gpg_naive_regex_signed #gpg_naive_regex_encrypted

use strict;
use warnings;
use 5.010;
use utf8;

my @argsFound;
while (my $argFound = shift) {
	push @argsFound, $argFound;
}

sub GpgParse { # $filePath ; parses file and stores gpg response in cache
	# PgpParse {
	# $filePath = path to file containing the text
	#

	my $filePath = shift;
	if (!$filePath || !-e $filePath || -d $filePath) {
		WriteLog('GpgParse: warning: $filePath missing, non-existent, or a directory');
		return '';
	}
	if ($filePath =~ m/^([0-9a-zA-Z\/\._\-]+)$/) {
		$filePath = $1;
	} else {
		WriteLog('GpgParse: warning: sanity check failed on $filePath, returning');
		return '';
	}

	WriteLog("GpgParse($filePath)");
	my $fileHash = GetFileHash($filePath);

	if (!$fileHash || !IsItem($fileHash)) {
		WriteLog('GpgParse: warning: sanity check failed on $fileHash returned by GetFileHash($filePath), returning');
		return '';
	}

	state $CACHEPATH = GetDir('cache');
	state $cacheVersion = GetMyCacheVersion();

	my $cachePathStderr = "$CACHEPATH/$cacheVersion/gpg_stderr";
	if ($cachePathStderr =~ m/^([a-zA-Z0-9_\/.]+)$/) {
		$cachePathStderr = $1;
		WriteLog('GpgParse: $cachePathStderr sanity check passed: ' . $cachePathStderr);
	} else {
		WriteLog('GpgParse: warning: sanity check failed, $cachePathStderr = ' . $cachePathStderr);
		return '';
	}

	my $pubKeyFlag = 0;
	my $encryptedFlag = 0;
	my $signedFlag = 0;

	if (!-e "$cachePathStderr/$fileHash.txt") { # no gpg stderr output saved
		# we've not yet run gpg on this file
		WriteLog('GpgParse: found stderr output: ' . "$cachePathStderr/$fileHash.txt");
		my $fileContents = GetFile($filePath);

		#gpg_strings
		my $gpgPubkey = '-----BEGIN PGP PUBLIC KEY BLOCK-----';
		my $gpgSigned = '-----BEGIN PGP SIGNED MESSAGE-----';
		my $gpgEncrypted = '-----BEGIN PGP MESSAGE-----';

		# gpg_prepare
		# this is the base gpg command
		# these flags help prevent stalling due to password prompts
		my $gpgCommand = '';
		my $gpg2 = 0;
		if (GetConfig('admin/gpg/use_gpg2')) {
			$gpgCommand = 'gpg --no-default-keyring --keyring rs.gpg --pinentry-mode=loopback --batch ';
			$gpg2 = 1;
		} else {
			$gpgCommand = 'gpg --no-default-keyring --keyring rs.gpg --keyid-format long --batch ';
			$gpg2 = 0;
		}

		# basic message classification covering only three cases, exclusively
		if (index($fileContents, $gpgPubkey) > -1) {
			#gpg_pubkey # public key
			#gpg_pubkey # public key
			#gpg_pubkey # public key
			WriteLog('GpgParse: found $gpgPubkey');
			$gpgCommand .= '--import --ignore-time-conflict --ignore-valid-from ';
			$pubKeyFlag = 1;
		}
		elsif (index($fileContents, $gpgSigned) > -1) {
			#gpg_signed
			#gpg_signed
			#gpg_signed
			WriteLog('GpgParse: found $gpgSigned');
			if ($gpg2) {
				$gpgCommand .= '--verify -o - ';
			} else {
				$gpgCommand .= '--decrypt -o - ';
			}
			$signedFlag = 1;
		}
		elsif (index($fileContents, $gpgEncrypted) > -1) {
			#gpg_encrypted
			#gpg_encrypted
			#gpg_encrypted
			WriteLog('GpgParse: found $gpgEncrypted');
			$gpgCommand .= '-o - --decrypt ';
			$encryptedFlag = 1;
		} else {
			WriteLog('GpgParse: did not find any relevant strings, returning');
			return '';
		}

		if ($fileHash =~ m/^([0-9a-f]+)$/) {
			# $fileHash is also checked above, this is just an extra
			# sanity check because we're about to use it in a shell command
			$fileHash = $1;
		} else {
			WriteLog('GpgParse: sanity check failed, $fileHash = ' . $fileHash);
			return '';
		}

		#gpg_command_pipe
		my $messageCachePath = GetFileMessageCachePath($filePath) . '_gpg';
		$gpgCommand .= "$filePath "; # file we're parsing
		$gpgCommand .= ">$messageCachePath "; # capture stdout
		$gpgCommand .= "2>$cachePathStderr/$fileHash.txt "; # capture stdeerr
		WriteLog('GpgParse: ' . $fileHash . '; $gpgCommand = ' . $gpgCommand);
		system($gpgCommand);
	}

	my $gpgStderrOutput = GetCache("gpg_stderr/$fileHash.txt");
	if (!defined($gpgStderrOutput)) {
		WriteLog('GpgParse: warning: GetCache(gpg_stderr/$fileHash.txt) returned undefined!');
		$gpgStderrOutput = '';
	}

	if ($gpgStderrOutput) {
		#WriteLog('GpgParse: ' . $fileHash . '; $gpgStderrOutput = ' . $gpgStderrOutput);
		WriteLog('GpgParse: ' . $fileHash . '; $pubKeyFlag = ' . $pubKeyFlag);

		if ($pubKeyFlag) {
			### PUBKEY
			#pubkey
			##########
			my $gpgKeyPub = '';

			if ($gpgStderrOutput =~ /([0-9A-F]{16})/) { # username allowed characters chars filter is here
				$gpgKeyPub = $1;
				DBAddItemAttribute($fileHash, 'gpg_id', $gpgKeyPub);

				if ($gpgStderrOutput =~ m/"([ a-zA-Z0-9<>&\@.()_'"\\]+)"/) {
					# we found something which looks like a name
					my $aliasReturned = $1;
					$aliasReturned =~ s/\<(.+\@.+?)\>//g; # if has something which looks like an email, remove it

					if ($gpgKeyPub && $aliasReturned) {
						#gpg_naive_regex_pubkey
						my $message;
						$message = GetTemplate('message/user_reg.template');

						$message =~ s/\$name/$aliasReturned/g;
						$message =~ s/\$fingerprint/$gpgKeyPub/g;

						DBAddLabel($fileHash, GetTime(), 'pubkey', $gpgKeyPub, $fileHash);

						# sub DBAddLabel() { # $fileHash, $ballotTime, $voteValue, $signedBy, $sourceHash ; Adds a new vote (tag) record to an item based on vote/ token

						DBAddItemAttribute($fileHash, 'gpg_alias', $aliasReturned);
						#DBAddItemAttribute($fileHash, 'title', "$aliasReturned has registered (public key)"); #todo templatize
						DBAddItemAttribute($fileHash, 'title', "Public Key for $aliasReturned"); #todo templatize
						# this is changed because anyone can publish a public key, and this does not necessarily map to "has registered"

						if (GetConfig('admin/index/create_system_tags')) {
							DBAddLabel($fileHash, 0, 'pubkey');
						}

						#todo add message to index_log
						if (GetConfig('setting/admin/auto_approve_first_user')) {
							#todo optimize below
							my $existingAuthors = SqliteGetValue("SELECT COUNT(key) AS author_count FROM author_alias WHERE alias = '$aliasReturned'"); #todo parameterize
							WriteLog('GpgParse: auto_approve_first_user: $existingAuthors = ' . $existingAuthors);
							if ($existingAuthors) {
								# do not auto-approve
								RemoveHtmlFile('people.html'); #todo this should only happen if dynamic mode is on
							}
							else {
								#todo should apply to fingerprint?
								DBAddLabel($fileHash, GetTime(), 'approve', $gpgKeyPub, $fileHash);
								RemoveHtmlFile('people.html'); #todo this should only happen if dynamic mode is on
							}
						}

						#todo gpg --list-packets --keyid-format=long <public_key.txt>
						# this will give us the keygen time

						# DBAddKeyAlias($authorKey, $tokenFound{'param'}, $fileHash);
						# DBAddKeyAlias('flush');

						# gpg author alias shim
						DBAddKeyAlias($gpgKeyPub, $aliasReturned, $fileHash);
						DBAddKeyAlias('flush');

						ExpireAvatarCache($gpgKeyPub); # does fresh lookup, no cache

						PutFileMessage($fileHash, $message);
					} else {

					}
				} else {
					WriteLog('GpgParse: warning: alias not found in pubkey mode');
					#DBAddItemAttribute($fileHash, 'gpg_alias', '???');
					#$message =~ s/\$name/???/g;
				}

				return $gpgKeyPub;
			}


		} # $pubKeyFlag
		elsif ($signedFlag) {
			### SIGNED
			##########
			my $gpgKeySigned = '';
			#gpg_naive_regex_signed
			if ($gpgStderrOutput =~ /([0-9A-F]{16})/) {
				$gpgKeySigned = $1;
				DBAddItemAttribute($fileHash, 'gpg_id', $gpgKeySigned);
			}

			if ($gpgStderrOutput =~ /Signature made (.+)/) {
				# my $gpgDateEpoch = #todo convert to epoch time
				WriteLog('GpgParse: ' . $fileHash . '; found signature made token from gpg');
				my $signTimestamp = $1;
				chomp $signTimestamp;
				my $signTimestampEpoch = `date --date='$signTimestamp' +%s`;
				chomp $signTimestampEpoch;

				WriteLog('GpgParse: $signTimestamp = ' . $signTimestamp . '; $signTimestampEpoch = ' . $signTimestampEpoch);

				if ($gpgStderrOutput =~ /BAD signature from/) {
					## BAD SIGNATURE
					DBAddItemAttribute($fileHash, 'gpg_bad_signature', $signTimestampEpoch);
				} else {
					## GOOD SIGNATURE
					DBAddItemAttribute($fileHash, 'gpg_timestamp', $signTimestampEpoch);
					if (GetConfig('admin/index/create_system_tags')) {
						DBAddLabel($fileHash, 0, 'signed');
					}
				}
			}
			return $gpgKeySigned;
		}
		elsif ($encryptedFlag) {
			#gpg_naive_regex_encrypted
			DBAddItemAttribute($fileHash, 'gpg_encrypted', 1);
			PutFileMessage($fileHash, '(Encrypted message)');
			WriteLog('GpgParse: $encryptedFlag was true, setting message accordingly');
			return 1;
		} else {
			# not a pubkey, just take whatever pgp output for us
			WriteLog('GpgParse: fallthrough, nothing gpg-worthy found...');
			return '';
		}
	} # $gpgStderrOutput
	else {
		# for some reason gpg didn't output anything, so just put the original message
		# $returnValues{'message'} = GetFile("$cachePathMessage/$fileHash.txt");
		#WriteLog('GpgParse: warning: ' . $fileHash . '; $gpgStderrOutput was false!');
		return '';
	}

	return '';
} # GpgParse()
#
#while (my $arg1 = shift @argsFound) {
#	WriteLog('index.pl: $arg1 = ' . $arg1);
#	if ($arg1) {
#		if (-e $arg1) {
#			print GpgParse($arg1);
#			print "\n";
#		}
#	}
#}

1;
