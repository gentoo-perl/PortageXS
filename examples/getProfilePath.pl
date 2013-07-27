#!/usr/bin/perl

use warnings;
use strict;

use lib '../..';
use PortageXS;

my $pxs=PortageXS->new();
print "Profile: ".$pxs->getProfilePath()."\n";
