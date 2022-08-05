#!/usr/bin/perl -T

use strict;


sub GetTokenDefs {
	WriteLog('GetTokenDefs()');
#
#	state @tokenDefs;
#
#	if (@tokenDefs) {
#		return @tokenDefs;
#	}

	#todo memo
	my @tokenDefs = (
	    # ATTENTION #tokenSanityCheck
	    # Whenever adding a new definition here
	    # Also add it to the sanity check below
	    # Look for this tag: #tokenSanityCheck
	    # ATTENTION #tokenSanityCheck

		{ # cookie of user who posted the message
			'token'   => 'cookie',
			'mask'    => '^(cookie)(\W+)([0-9A-F]{16})',
			'mask_params'    => 'mgi',
			'message' => '[Cookie]'
		},
		{ # server receipt time of message
			'token'   => 'received',
			'mask'    => '^(received)(\W+)([0-9]{10})',
			'mask_params'    => 'mgi',
			'message' => '[Received]'
		},
		{ # date in yyyy-mm-dd format
			'token'   => 'date',
			'mask'    => '^(date)(\W+)([0-9]{4}\-[0-9]{2}\-[0-9]{2})',
			'mask_params'    => 'mgi',
			'message' => '[Date]'
		},
		{ # time in epoch
			'token'   => 'time',
			'mask'    => '^(time)(\W+)([0-9]+)',
			'mask_params'    => 'mgi',
			'message' => '[Time]',
			'target_attribute' => 'manual_timestamp'
		},
		{ # host user used to post message
			'token'   => 'host',
			'mask'    => '^(host)(\W+)([0-9a-z\.:]+)',
			'mask_params'    => 'mgi',
			'message' => '[Host]'
		},
		{ # surpass: this item is better than another item
			'token'   => 'surpass',
			'mask'    => '^(surpass)(\W+)([0-9a-f]{40})',
			'mask_params'    => 'mgi',
			'message' => '[Surpass]',
			'apply_to_parent' => 1
		},
		{ # allows cookied user to set own name
			'token'   => 'my_name_is',
			'mask'    => '^(my name is)(\W+)([A-Za-z0-9\'_\., ]+)\r?$',
			'mask_params'    => 'mgi',
			'message' => '[MyNameIs]'
		},
		{ # parent of item (to which item is replying)
			'token'   => 'parent',
			'mask'    => '^(\>\>)(\W?)([0-9a-f]{40})', # >>
			'mask_params' => 'mg',
			'message' => '[Parent]'
		},
		{ # parent of item (to which item is replying)
			'token'   => 'signature_divider',
			'mask'    => '^(-- )()()$', # -- \n
			'mask_params' => 'mg',
			'message' => '[Signature Divider]'
		},
	#				{ # reference to item
	#					'token'   => 'itemref',
	#					'mask'    => '(\W?)([0-9a-f]{8})(\W?)',
	#					'mask_params' => 'mg',
	#					'message' => '[Reference]'
	#				}, #todo make it ensure item exists before parsing
		{ # title of item, either self or parent. used for display when title is needed #title title:
			'token'   => 'title',
			'mask'    => '^(title)(\W)(.+)$',
			'mask_params'    => 'mg',
			'apply_to_parent' => 1,
			'message' => '[Title]'
		},
		{ # begin time, self only:
			'token'   => 'begin',
			'mask'    => '^(begin)(\W)(.+)$',
			'mask_params'    => 'mg',
			'message' => '[Begin]'
		},
		{ # duration, self only:
			'token'   => 'duration',
			'mask'    => '^(duration)(\W)(.+)$',
			'mask_params'    => 'mg',
			'message' => '[Duration]'
		},
		# { # track: self only:
		# 	'token'   => 'track',
		# 	'mask'    => '^(track)(\W)(.+)$',
		# 	'mask_params'    => 'mg',
		# 	'message' => '[Track]'
		# },
		{ # name of item, either self or parent. used for display when title is needed #title title:
			'token'   => 'name',
			'mask'    => '^(name)(\W)(.+)$',
			'mask_params'    => 'mg',
			'apply_to_parent' => 1,
			'message' => '[Name]'
		},
		{ # order of item, either self or parent. used for ordering things
			'token'   => 'order',
			'mask'    => '^(order)(\W)(.+)$',
			'mask_params'    => 'mg',
			'apply_to_parent' => 1,
			'message' => '[Order]'
		},
		{ # used for image alt tags #todo
			'token'   => 'alt',
			'mask'    => '^(alt)(\W+)(.+)$',
			'mask_params'    => 'mg',
			'apply_to_parent' => 1,
			'message' => '[Alt]'
		},
		{ # hash of line from access.log where item came from (for parent item)
			'token'   => 'access_log_hash',
			'mask'    => '^(AccessLogHash)(\W+)(.+)$',
			'mask_params'    => 'mgi',
			'apply_to_parent' => 1,
			'message' => '[AccessLogHash]'
		},
		{ # hash of line from access.log where item came from (for parent item)
			'token'   => 'self_timestamp',
			'mask'    => '^(timestamp)(\W+)([0-9]+)$',
			'mask_params'    => 'mgi',
			'apply_to_parent' => 0,
			'message' => '[Timestamp]'
		},
		{
			'token' => 'footer_separator',
			'mask' => '^-- $',
			'mask_params' => 'mgi',
			'message' => ''
		},
		{ # anything beginning with http and up to next space character (or eof)
			'token' => 'http',
			'mask' => '()()(http:[\S]+)',
			'mask_params' => 'mg',
			'message' => '[http]',
			'apply_to_parent' => 1
		},
		{
			# s/// regex basic
			'token'       => 's_replace',
			'mask'        => 's\/([^\/]+)\/([^\/]+)\/?',
			'mask_params' => 'ig',
			'message'    => '[$1]',
			'apply_to_parent' => 1
		},
		{ # anything beginning with https and up to next space character (or eof)
			'token' => 'https',
			'mask' => '()()(https:[\S]+)',
			'mask_params' => 'mg',
			'message' => '[https]',
			'apply_to_parent' => 1
		},
#todo
#		{ # for things quoted from hackernews
#			'token' => 'hn_user',
#			'mask' => '^(.+)(.+\W)([–])$',
#			'mask_params' => 'mg',
#			'message' => '[hn_user]',
#			'apply_to_parent' => 0
#		},
		{ # plustags, currently restricted to latin alphanumeric and underscore
			'token' => 'plustag',
			'mask'  => '(\+)()([a-zA-Z0-9_]{1,32})',
			'mask_params' => 'mgi',
			'message' => '[Plustag]',
			'apply_to_parent' => 1
		},
		{ # hashtags, currently restricted to latin alphanumeric and underscore
			'token' => 'hashtag',
			'mask'  => '(\#)()([a-zA-Z0-9_]{1,32})',
			'mask_params' => 'mgi',
			'message' => '',
			#'message' => '[HashTag]',
			'apply_to_parent' => 0,
			#'require_spacer' => 0
		},
		{ # verify token, for third-party identification
			# example: verify http://www.example.com/user/JohnSmith/
			# must be child of pubkey item
			'token' => 'verify',
			'mask'  => '^(verify)(\W)(.+)$',
			'mask_params' => 'mgi',
			'message' => '[Verify]',
			'apply_to_parent' => 1
		},
		{ # #sql token, returns sql results (for privileged users)
			# example: #sql select author_key, alias from author_alias
			# must be a select statement, no update etc
			# to begin with, limited to 1 line; #todo
			'token' => 'sql',
			'mask' => '^(sql)(\W).+$',
			'mask_params' => 'mgi',
			'message' => '[SQL]',
			'apply_to_parent' => 0
		},
		{ # config token for setting configuration
			# config/admin/anyone_can_config = allow anyone to config (for open-access boards)
			# config/admin/signed_can_config = allow only signed users to config
			# config/admin/cookied_can_config = allow any user (including cookies) to config
			# otherwise, only admin user can config
			# also, anything under config/admin/ is still restricted to admin user only
			# admin user must have a pubkey
			'token' => 'config',
			'mask'  => '^(config)(\W)(.+)$', #bughere #todo
			'mask_params' => 'mgi',
			'message' => '[Config]',
			'apply_to_parent' => 1
		}
	);

		# REGEX cheatsheet
		# ================
		#
		# \w word
		# \W NOT word
		# \s whitespace
		# \S NOT whitespace
		#
		# /s = single-line (changes behavior of . metacharacter to match newlines)
		# /m = multi-line (changes behavior of ^ and $ to work on lines instead of entire file)
		# /g = global (all instances)
		# /i = case-insensitive
		# /e = eval
		#
		# allowed flag combinations:
		# mg (??)
		# mgi ??
		# gi    ??
		# g       ??
		#

	return @tokenDefs;
} # GetTokenDefs()

1;
