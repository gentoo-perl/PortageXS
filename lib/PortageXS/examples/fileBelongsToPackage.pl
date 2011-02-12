#!/usr/bin/perl

use warnings;
use strict;

use lib '../..';
use PortageXS;

$|=1;

my $pxs=PortageXS->new();

if (!-f $ARGV[0]) {
	$pxs->printColored('RED',"Given file does not exist - Aborting!\n");
}
else {
	$pxs->printColored('LIGHTGREEN',"Searching for '".$ARGV[0]."'..");

	my @results = $pxs->fileBelongsToPackage($ARGV[0]);

	if ($#results>-1) {
		print " done!\n\n";
		$pxs->printColored('LIGHTGREEN',"The file '".$ARGV[0]."' was installed by these packages:\n");
		print "   ".join("\n   ",@results)."\n";
	}
	else {
		$pxs->printColored('RED',"This file has not been installed by portage.\n");
	}
}

exit(0);

