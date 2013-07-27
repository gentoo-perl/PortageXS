#!/usr/bin/perl

use warnings;
use strict;

use PortageXS;

my $pxs=PortageXS->new();
print $ARGV[0]." resolves to:\n".join("\n",$pxs->resolveMirror($ARGV[0]))."\n";
