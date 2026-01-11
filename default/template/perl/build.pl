#!/usr/bin/perl -T
#freebsd: #!/usr/local/bin/perl -T

#gitbash: $ENV{PATH}="/bin:/usr/bin:/mingw64/bin"; #this is needed for -T to work
$ENV{PATH} = "/bin:/usr/bin"; # this is needed for -T to work

use strict;
use warnings;
use 5.010;
use utf8;

use Cwd qw(cwd);

sub BuildMessage { # prints timestamped message to output
	print ' ';
	print "\n";
	print time();
	print ': ';
	print shift;
	print "\n";
} # BuildMessage()

# sanity check for utils.pl, copy from default if missing, warn user
if (!-e './config/template/perl/utils.pl') {
	BuildMessage "utils.pl missing, copying from default...";
	system('cp default/template/perl/utils.pl ./config/template/perl/utils.pl');
}

if (!-e './config/template/perl/config.pl') {
	BuildMessage "config.pl missing, copying from default...";
	system('cp default/template/perl/config.pl ./config/template/perl/config.pl');
}

BuildMessage "Require ./utils.pl...";
require('./config/template/perl/utils.pl');

require_once('database.pl');
# depending on the setting/admin/database_type, use ...MakeTables()
if (GetConfig('setting/admin/database_type') eq 'sqlite') {
	BuildMessage "SqliteMakeTables()...";
	SqliteMakeTables();
} elsif (GetConfig('setting/admin/database_type') eq 'mysql') {
	BuildMessage "MysqlConnect()...";
	MysqlConnect();

	BuildMessage "MysqlMakeTables()...";
	MysqlMakeTables();
}

my $SCRIPTDIR = cwd();
WriteLog("build.pl: cwd() = $SCRIPTDIR");

# sanity check $SCRIPTDIR for bad characters, then set $SCRIPTDIR to a safe value
if ($SCRIPTDIR =~ m/^([a-zA-Z0-9\/\.\-_]+)$/) {
	$SCRIPTDIR = $1;
	# sanity check passed
} else {
	die "Error: $SCRIPTDIR failed sanity check";
}
WriteLog("build.pl: SCRIPTDIR = $SCRIPTDIR");

my $HTMLDIR = $SCRIPTDIR . '/html';
WriteLog("build.pl: HTMLDIR = $HTMLDIR");

# sanity check $HTMLDIR for bad characters, then set $HTMLDIR to a safe value
if ($HTMLDIR =~ m/^([a-zA-Z0-9\/\.\-_]+)$/) {
	$HTMLDIR = $1;
	# sanity check passed
} else {
	die "Error: $HTMLDIR failed sanity check";
}

my $TXTDIR = $HTMLDIR . '/txt';
# sanity check $TXTDIR for bad characters, then set $TXTDIR to a safe value
if ($TXTDIR =~ m/^([a-zA-Z0-9\/\.\-_])+$/) {
	$TXTDIR = $1;
	# sanity check passed
} else {
	die "Error: $TXTDIR failed sanity check";
}

my $IMAGEDIR = $HTMLDIR . '/image';
# sanity check $IMAGEDIR for bad characters, then set $IMAGEDIR to a safe value
if ($IMAGEDIR =~ m/^([a-zA-Z0-9\/\.\-_])+$/) {
	$IMAGEDIR = $1;
	# sanity check passed
} else {
	die "Error: $IMAGEDIR failed sanity check";
}

BuildMessage "Ensure there's $HTMLDIR and something inside...";
if (!-e $HTMLDIR) {
	# create $HTMLDIR directory if it doesn't exist
	mkdir($HTMLDIR);
}

BuildMessage "Ensure there's $TXTDIR and something inside...";
if (!-e $TXTDIR) {
	# create $TXTDIR directory if it doesn't exist
	mkdir($TXTDIR);
}

if (!-e $HTMLDIR . '/chain.log') {
	WriteLog('build.pl: creating ' . $HTMLDIR . '/chain.log');
	PutFile($HTMLDIR . '/chain.log', '');
}

if (!-e $IMAGEDIR) {
	# create $IMAGEDIR directory if it doesn't exist
	mkdir($IMAGEDIR);
}

BuildMessage "Looking for files...";

BuildMessage "DBAddPageTouch('summary')...";
DBAddPageTouch('system');
#`./pages.pl --system`;

BuildMessage("UpdateUpdateTime()...");
UpdateUpdateTime();

PutFile('config/setting/admin/build_end', GetTime());

if (!GetConfig('setting/admin/secret')) {
	PutConfig('admin/secret', md5_hex(time()));
	#todo improve security
}

if (GetConfig('setting/admin/dev/launch_browser_after_build')) {
	WriteLog('build.pl: xdg-open http://localhost:2784/ &');
	WriteLog(`xdg-open http://localhost:2784/ &`);
}

if (GetConfig('setting/admin/ssi/enable') && GetConfig('setting/admin/php/enable')) {
	BuildMessage('build.pl: warning: ssi/enable and php/enable are both true');
}

# these will be pre-written to config/
my @modules = qw(
	string.pl
	cache.pl
	html.pl
	file.pl
	database.pl
	mysql.pl
	sqlite.pl
	gpgpg.pl
	makepage.pl
	token_defs.pl
	render_field.pl
	resultset_as_dialog.pl
	item_page.pl
	format_message.pl
	item_template.pl
	widget.pl
	index_text_file.pl
	index.pl
	pages.pl
	item_listing_page.pl
);
# compare_page.pl

for my $module (@modules) {
	ensure_module("$module");
}

BuildMessage("===============");
BuildMessage("Build finished!");
BuildMessage("===============");
WriteLog("Finished!");

1;
