#!/usr/bin/perl

use warnings;
use strict;

use lib '../..';
use PortageXS;

my $pxs=PortageXS->new();
print "CFLAGS are set to: ";
print join(' ',$pxs->getParamFromFile($pxs->getFileContents('@GENTOO_PORTAGE_EPREFIX@/etc/make.globals').$pxs->getFileContents('@GENTOO_PORTAGE_EPREFIX@/etc/make.conf'),'CFLAGS','lastseen'))."\n";
