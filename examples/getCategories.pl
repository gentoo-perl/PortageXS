#!/usr/bin/perl

use warnings;
use strict;

use PortageXS;

my $pxs=PortageXS->new();
my @repos=();

push(@repos,$pxs->getPortdir());
push(@repos,$pxs->getPortdirOverlay());

foreach (@repos) {
	print "List of available categories in repo ".$_.":\n";
	my @categories=$pxs->getCategories($_);
	if (@categories) {
		print join("\n",@categories)."\n";
	}
	else {
		print "No categories defined for this repo.\n";
	}
}
