#!/usr/bin/perl

use warnings;
use strict;

use lib '../..';
use PortageXS;

my $pxs=PortageXS->new();
print "Usedesc of '".$ARGV[0]."':\n".join("\n",$pxs->getUsedescs($ARGV[0],$pxs->getPortdir()))."\n";
