#!/usr/bin/perl

use warnings;
use strict;

use lib '../..';
use PortageXS;

my $pxs=PortageXS->new();
print "Search for installed packages named: $ARGV[0]\n\n";
print join("\n",$pxs->searchInstalledPackage($ARGV[0]))."\n";
