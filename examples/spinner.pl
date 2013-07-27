#!/usr/bin/perl

use warnings;
use strict;

use PortageXS::UI::Spinner;

print "Spinner demonstration..  ";
my $spinner=PortageXS::UI::Spinner->new();
for (my $i=0;$i<5;$i++) {
	$spinner->spin();
	sleep(1);
}
$spinner->reset();
print "done! :)\n";
