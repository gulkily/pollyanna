#!/bin/sh

# build.sh builds local environment including symlinks to perl scripts and sets +x

mkdir -p config/template/perl

#todo these copy procedures below should only happen if the files don't already exist

cp default/template/perl/build.pl config/template/perl/build.pl
cp default/template/perl/utils.pl config/template/perl/utils.pl
cp default/template/perl/config.pl config/template/perl/config.pl
#cp default/template/perl/install.pl config/template/perl/install.pl
#cp default/template/perl/setup.pl config/template/perl/setup.pl
cp default/template/perl/server_local_lighttpd.pl config/template/perl/server_local_lighttpd.pl 

# this should not be necessary anymore #todo
# ln -sf config/template/perl/build.pl build.pl
ln -sf config/template/perl/utils.pl utils.pl
ln -sf config/template/perl/config.pl config.pl
ln -sf config/template/perl/index.pl index.pl
ln -sf config/template/perl/pages.pl pages.pl
ln -sf config/template/perl/sqlite.pl sqlite.pl
#ln -sf config/template/perl/install.pl install.pl
#ln -sf config/template/perl/setup.pl setup.pl
ln -sf config/template/perl/server_local_lighttpd.pl server_local_lighttpd.pl

perl -T config/template/perl/build.pl

perl -T ./config/template/perl/pages.pl --system

chmod -v -w *.pl
chmod -v +x *.pl
