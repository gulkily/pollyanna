#!/bin/sh

rm -vrf config/template/perl

mkdir -p config/template/perl

cp default/template/perl/build.pl config/template/perl/build.pl
cp default/template/perl/utils.pl config/template/perl/utils.pl
cp default/template/perl/config.pl config/template/perl/config.pl
#cp default/template/perl/install.pl config/template/perl/install.pl
cp default/template/perl/setup.pl config/template/perl/setup.pl
cp default/template/perl/server_local_lighttpd.pl config/template/perl/server_local_lighttpd.pl 

ln -sf config/template/perl/build.pl build.pl
ln -sf config/template/perl/utils.pl utils.pl
ln -sf config/template/perl/config.pl config.pl
ln -sf config/template/perl/index.pl index.pl
ln -sf config/template/perl/pages.pl pages.pl
ln -sf config/template/perl/sqlite.pl sqlite.pl
#ln -sf config/template/perl/install.pl install.pl
ln -sf config/template/perl/setup.pl setup.pl
ln -sf config/template/perl/server_local_lighttpd.pl server_local_lighttpd.pl

perl -T ./build.pl

perl -T ./pages.pl --system

chmod -v -w *.pl
chmod -v +x *.pl