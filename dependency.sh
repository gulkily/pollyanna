#!/bin/bash

# Define packages for each package manager
APT_PACKAGES="liburi-encode-perl libany-uri-escape-perl libhtml-parser-perl libdbd-sqlite3-perl libdigest-sha-perl sqlite3 gnupg gnupg2 imagemagick zip php-cgi libunicode-string-perl libdbi-perl php-sqlite3"
YUM_PACKAGES="perl-Digest-MD5 perl-Digest-SHA perl-HTML-Parser perl-DBD-SQLite perl-URI-Encode perl-Digest-SHA1 sqlite gnupg gnupg2 perl-Devel-StackTrace perl-Digest-SHA perl-HTML-Parser perl-DBD-SQLite lighttpd-fastcgi ImageMagick php-cgi zip perl-Unicode-String"
BREW_PACKAGES="lighttpd gpg"
PACMAN_PACKAGES="perl-digest-md5 perl-unicode-string perl-digest-sha imagemagick zip php lighttpd perl-html-parser gnupg"

# Check for package manager and install packages
if command -v apt >/dev/null 2>&1; then
    echo "Using apt..."
    sudo apt install $APT_PACKAGES
elif command -v yum >/dev/null 2>&1; then
    echo "Using yum..."
    sudo yum install $YUM_PACKAGES
elif command -v brew >/dev/null 2>&1; then
    echo "Using brew..."
    brew install $BREW_PACKAGES
elif command -v pacman >/dev/null 2>&1; then
    echo "Using pacman..."
    sudo pacman -S $PACMAN_PACKAGES
else
    echo "No supported package manager found!"
fi

