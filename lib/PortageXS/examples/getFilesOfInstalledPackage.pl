#!/usr/bin/perl

use warnings;
use strict;

use lib '../..';
use PortageXS;

my $pxs=PortageXS->new();

if ($ARGV[0]) {
	$pxs->printColored('bold green',"List all files belonging to package '".$ARGV[0]."':\n");
	print "   ".join("\n   ",$pxs->getFilesOfInstalledPackage($ARGV[0]))."\n";
}
else {
	$pxs->printColored('bold red',"Please provide a package. Usage: getFilesOfInstalledPackage.pl category/package\n");
}

exit(0);

