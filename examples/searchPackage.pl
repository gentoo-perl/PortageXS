#!/usr/bin/perl

use warnings;
use strict;

use PortageXS;

my $pxs=PortageXS->new();

print "Search for packages where package name is like: $ARGV[0]\n";
print join("\n",$pxs->searchPackage($ARGV[0],'like'))."\n";

print "\nSearch for packages where package name is: $ARGV[0]\n";
print join("\n",$pxs->searchPackage($ARGV[0],'exact'))."\n";
