#!/usr/bin/perl

use warnings;
use strict;

use PortageXS;

my $pxs=PortageXS->new();
print "CFLAGS are set to: ";
print join(' ',$pxs->getParamFromFile($pxs->getFileContents('/etc/make.globals').$pxs->getFileContents('/etc/make.conf'),'CFLAGS','lastseen'))."\n";
