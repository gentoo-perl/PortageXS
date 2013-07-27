use strict;
use warnings;

package PortageXS::UI::Spinner;
BEGIN {
  $PortageXS::UI::Spinner::AUTHORITY = 'cpan:KENTNL';
}
{
  $PortageXS::UI::Spinner::VERSION = '0.3.0';
}
# ABSTRACT: Dancing \|/- progress bling for consoles.
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

__END__

=pod

=encoding utf-8

=head1 NAME

PortageXS::UI::Spinner - Dancing \|/- progress bling for consoles.

=head1 VERSION

version 0.3.0

=head1 AUTHORS

=over 4

=item *

Christian Hartmann <ian@gentoo.org>

=item *

Torsten Veller <tove@gentoo.org>

=item *

Kent Fredric <kentnl@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Christian Hartmann.

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut
