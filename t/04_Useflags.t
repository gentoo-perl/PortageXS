#!/usr/bin/perl -w

use Test::Simple tests => 4;

use lib '../lib/';
use lib 'lib/';
use PortageXS;

my $pxs = PortageXS->new();

# - getUsedesc >
{
	my $usedesc = $pxs->getUsedesc('perl',$pxs->getPortdir());
	ok($usedesc,"getUsedesc('perl','".$pxs->getPortdir()."'): ".$usedesc);
}

# - getUsedescs >
{
	my @usedescs = $pxs->getUsedescs('perl',$pxs->getPortdir());
	ok(($#usedescs+1),"getUsedescs('perl','".$pxs->getPortdir()."'): ".join(" ",@usedescs));
}

# - sortUseflags >
{
	my @in=qw(foo -bam bar baz);
	my @out=$pxs->sortUseflags(@in);
	ok(join(' ',@out) eq 'bar baz foo -bam','sortUseflags returned expected order: '.join(' ',@out));
}

# - getUsemasksFromProfile >
{
	my @usemasks=$pxs->getUsemasksFromProfile();
	ok(($#usemasks+1),'getUsemasksFromProfile() returned '.($#usemasks+1).' masked useflags');
}

