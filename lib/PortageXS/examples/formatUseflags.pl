#!/usr/bin/perl

use warnings;
use strict;

use lib '../..';
use PortageXS;


my $pxs=PortageXS->new();

my $package     = "perl";
$package = $ARGV[0] if $ARGV[0];
($package)=$pxs->searchPackage($package,'exact');
$package=(split(/:/,$package))[1];

print "Package ".$package." has been compiled with useflags set: ";
print join(" ",$pxs->formatUseflags($pxs->getUseSettingsOfInstalledPackage($pxs->searchInstalledPackage($package))))."\n";
