#!/usr/bin/perl

use warnings;
use strict;

use PortageXS;

my $pxs=PortageXS->new();
print "Usedesc of '".$ARGV[0]."' is: ".$pxs->getUsedesc($ARGV[0],$pxs->getPortdir())."\n";
