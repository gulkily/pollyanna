#!/usr/bin/perl -T

# clean up things that tend to pile up
# removes things from here which are from more than 24 hours ago:
#	trim log file
#	cache/b/response/*
#	log/*.sqlerr

# trim log file if it's there
# 	raise warning if there is a log file being written,
#	debug mode should normally not be on
# remove old entries in cache/b/response
#
# remove old files in log/*.sqlerr
# 	raise warning if there are a lot of them