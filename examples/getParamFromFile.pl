#!/usr/bin/perl

use warnings;
use strict;

use PortageXS;
use Path::Tiny qw(path);

my $pxs=PortageXS->new();
print "CFLAGS are set to: ";
my $content = path('/etc/make.globals')->slurp;
   $content .= path('/etc/make.conf')->slurp;
print join(' ',$pxs->getParamFromFile($content,'CFLAGS','lastseen'))."\n";
