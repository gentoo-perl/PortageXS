use strict;
use warnings;

package PortageXS::UI::Spinner;

# -----------------------------------------------------------------------------
#
# PortageXS::UI::Spinner
#
# author      : Christian Hartmann <ian@gentoo.org>
# license     : GPL-2
# header      : $Header: /srv/cvsroot/portagexs/trunk/lib/PortageXS/UI/Spinner.pm,v 1.1.1.1 2006/11/13 00:28:34 ian Exp $
#
# -----------------------------------------------------------------------------
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# -----------------------------------------------------------------------------

require Exporter;
our @ISA = qw(Exporter PortageXS);
our @EXPORT = qw(
			spin
			reset
		);

sub new {
	my $self	= shift;
	my $spin = bless {}, $self;
	$spin->{'spinstate'}=0;
	$|=1;
	return $spin;
}

sub spin {
	my $self	= shift;
	print "\b".('/', '-', '\\', '|')[$self->{'spinstate'}++];
	if ($self->{'spinstate'}>3) {
		$self->{'spinstate'}=0;
	}
}

sub reset {
	print "\b \b";
}

1;
