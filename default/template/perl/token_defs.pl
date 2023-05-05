#!/usr/bin/perl -T

# token_defs.pl
# definitions for tokens which can be found in messages
# returned as 

use strict;
use warnings;
use 5.010;
use utf8;

sub GetTokenDefs {
	WriteLog('GetTokenDefs()');
#
#	state @tokenDefs;
#
#	if (@tokenDefs) {
#		return @tokenDefs;
#	}
	#todo memo (not sure why above is commented out)
	
	my @tokenDefs = (
		# ATTENTION #tokenSanityCheck
		# Whenever adding a new definition here
		# Also add it to the sanity check
		# Look for this tag: #tokenSanityCheck in index_text_file.pl
		# ATTENTION #tokenSanityCheck

		# values allowed for mask_params:
		# mg   = multi-line, global
		# mgi  = multi-line, global, case-insensitive
		# gi   = global, case-insensitive
		# g    = global

		# token             = name of token; also used for item_attribute unless otherwise specified
		# mask              = regex mask with three parentheses captures: name, spacer, and parameter/value
		#                     for tokens without a prefix, use ()() for name and spacer placeholders
		# mask_params       = what is used at the end of the regex call. see allowed values above
		# message           = what the token is replaced with in the message when displayed to user
		# target_attribute  = name of attribute when stored in item_attributes table (if not specified, token name is used)
		# apply_to_parent   = when this is true, the token is applied to the parent item instead of the containing item
		# eval_message      = USE WITH CARE!!! causes eval() to be called on message. USE WITH CARE!!!
		# hashtag           = apply this hashtag instead of value of 'token'

		# ATTENTION #tokenSanityCheck
		# Whenever adding a new definition here
		# Also add it to the sanity check
		# Look for this tag: #tokenSanityCheck in index_text_file.pl
		# ATTENTION #tokenSanityCheck

		# DRAFT
		# {
		# 	'token'       => 'author_mention',
		# 	'mask'        => '()()([0-9A-F]){16}',
		# 	'mask_params' => 'g',
		# 	'message'     => '[Author Mention]'
		# },
		# ATTENTION; remember to add this to #tokenSanityCheck when uncommenting
		# DRAFT
		{ # cookie of user who posted the message
			'token'   => 'cookie',
			'mask'    => '^(cookie)(\W+)([0-9A-F]{16})',
			'mask_params'    => 'mgi',
			'message' => '[Cookie]'
		},
		{ # client id of user who posted the message
			'token'   => 'client',
			'mask'    => '^(client)(\W+)([0-9A-F]{16})',
			'mask_params'    => 'mgi',
			'message' => '[Client]'
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
		{ # title of item, either self or parent. used for display when title is needed #title title:
			'token'   => 'boxes',
			'mask'    => '^(boxes)(\W)(.+)$',
			'mask_params'    => 'mg',
			'apply_to_parent' => 0,
			'message' => '[BoxCount]'
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
		{
			# s/// regex basic
			'token'       => 's_replace',
			'mask'        => 's\/([^\/]+)\/([^\/]+)\/?',
			'mask_params' => 'ig',
			'message'    => '[$1]',
			'apply_to_parent' => 1
		},
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
#		{ # config token for setting configuration
#			# config/admin/anyone_can_config = allow anyone to config (for open-access boards)
#			# config/admin/signed_can_config = allow only signed users to config
#			# config/admin/cookied_can_config = allow any user (including cookies) to config
#			# otherwise, only admin user can config
#			# also, anything under config/admin/ is still restricted to admin user only
#			# admin user must have a pubkey
#			'token' => 'config',
#			'mask'  => '^(config)(\W)(.+)$', #bughere #todo
#			'mask_params' => 'mgi',
#			'message' => '[Config]',
#			'apply_to_parent' => 1
#		},
		{
			'token' => 'operator_please',
			'hashtag' => 'operator',
			'mask' => '^(operator, please)(\W)(.+)$',
			'mask_params' => 'mgi',
			'message' => '[Operator]',
			'apply_to_parent' => 0
		},
		{
			'token' => 'hike_set',
			'mask' => '^(hike set)(\W)(.+)$',
			'mask_params' => 'mgi',
			'message' => '[hike set]',
			'apply_to_parent' => 0
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
