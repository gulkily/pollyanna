#!/usr/bin/perl -T

# converts absolute links to relative links

require './utils.pl';

my $rootPath = shift;

if (
	(-e $rootPath)
	&& 
	(-d $rootPath)
	&& 
	($rootPath =~ m/^([0-9a-zA-Z_\/.]+)$/)
) {
	$rootPath = $1;
} else {
	die;
}

my @files = `find "$rootPath" | grep \\\\.html\$`;

for my $file (@files) {
	print $file;
	
	my $filePath = str_replace($rootPath, '', $file);
	
	my $content = GetFile($file);

	my $count = ($filePath =~ s/\//\//g) + 1;

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
	$content =~ s/action="\//action="$subDir/ig;
	$content =~ s/src=\//src=$subDir/ig;
	$content =~ s/href=\//href=$subDir/ig;
	$content =~ s/action=\//action=$subDir/ig;

	# javascript
	$content =~ s/\.src = '\//.src = '$subDir/ig;
	$content =~ s/\.location = '\//.location = '$subDir/ig;

	# css
	$content =~ s/url\(\/\//url=$subDir/ig;

	if ($content ne GetFile($file)) {
		PutFile($file, $content);
	}
}
