#!/usr/bin/perl

use warnings;
use strict;

use lib '../..';
use PortageXS;

my $pxs=PortageXS->new();
print "List of available packages in category $ARGV[0]:\n";
print join("\n",$pxs->getPackagesFromCategory($ARGV[0]))."\n";
