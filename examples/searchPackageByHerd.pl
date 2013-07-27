#!/usr/bin/perl

use strict;
use warnings;

use lib '../..';
use PortageXS;

my $pxs=PortageXS->new();

my @repos=();

push(@repos,$pxs->getPortdir());
push(@repos,$pxs->getPortdirOverlay());

foreach (@repos) {
	print "Repo: ".$_.":\n";
	print join("\n",$pxs->searchPackageByMaintainer($ARGV[0],$_))."\n\n";
}
