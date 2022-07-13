#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetAuthorFriendsList { # $authorKey ; returns friends list as html with avatars and links
	my $authorKey = shift;

	# get list of friends from db
	my @authorFriendsArray = DBGetAuthorFriends($authorKey);

	# generated html will reside here
	my $authorFriends = '';

	while (@authorFriendsArray) {
		# get the friend's key
		my $authorFriend = shift @authorFriendsArray;
		my $authorFriendKey = $authorFriend->{'author_key'};

		# get avatar (with link) for key
		my $authorFriendAvatar .= GetAuthorLink($authorFriendKey);

		# get friend list item template and insert linked avatar to it
		my $authorFriendTemplate = GetTemplate('author/author_friends_item.template');
		$authorFriendTemplate =~ s/\$authorFriendAvatar/$authorFriendAvatar/g;

		# append it to list of friends html
		$authorFriends .= $authorFriendTemplate;
	}

	if (!$authorFriends) {
		$authorFriends = '*';
	}

	# wrap list of friends in wrapper
	my $authorFriendsWrapper = GetTemplate('author/author_friends.template');
	$authorFriendsWrapper =~ s/\$authorFriendsList/$authorFriends/;

} # GetAuthorFriendsList()

1;