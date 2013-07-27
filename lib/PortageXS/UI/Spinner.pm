use strict;
use warnings;

package PortageXS::UI::Spinner;

# ABSTRACT: Dancing Console progress spinner bling.
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

use Moo;
use IO::Handle;

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"PortageXS::UI::Spinner",
    "inherits":"Moo::Object",
    "interface":"class"
}

=end MetaPOD::JSON

=cut

=head1 SYNOPSIS

    use PortageXS::UI::Spinner;

    my $spinner = PortageXS::UI::Spinner->new(%attributes);

    for ( 0..1000 ){
        sleep 0.1;
        $spinner->spin;
    }
    $spinner->reset;

=cut

=attr C<spinstate>

The index of the I<next> spin state to dispatch.

=cut

has spinstate => ( is => rwp =>, default => sub { 0 } );

=attr C<output_handle>

The C<filehandle> to write L<< C<spin>|/spin >> and L<< C<reset>|/reset >> output to.

Defaults to C<*STDOUT>.

B<Note:> Turns on C<autoflush> for C<*STDOUT> if no handle is passed explicitly.

=cut

has output_handle => (
    is      => ro =>,
    default => sub {
        my $handle = \*STDOUT;
        $handle->autoflush(1);
        return $handle;
    }
);

=attr C<spinstates>

The array of spinstates to dispatch

Defaults to:

    qw(
        /
        -
        \
        |
    )

=cut

has spinstates => (
    is      => ro =>,
    default => sub {
        [ '/', '-', '\\', '|' ];
    }
);

=p_method C<_last_spinstate>

The number of L<< C<spinstates>|/spinstates >> this C<::Spinner> object has.

=cut

sub _last_spinstate { return $#{ $_[0]->spinstates } }

=p_method C<_increment_spinstate>

Increment the position within the L<< C<spinstates>|/spinstates >> array by one, updating L<< C<spinstate>|/spinstate >>

=cut

sub _increment_spinstate {
    my $self      = shift;
    my $rval      = $self->spinstate;
    my $nextstate = $rval + 1;
    if ( $nextstate > $self->_last_spinstate ) {
        $nextstate = 0;
    }
    $self->_set_spinstate($nextstate);
    return $rval;
}

=p_method C<_get_next_spinstate>

Returns the next character from the L<< C<spinstates>|/spinstates >> array

=cut

sub _get_next_spinstate {
    my (@states) = @{ $_[0]->spinstates };
    return $states[ $_[0]->_increment_spinstate ];
}

=p_method C<_print_to_output>

Internal wrapper to proxy C<print> to L<< C<output_handle>|/output_handle >>

=cut

sub _print_to_output {
    my $self = shift;
    $self->output_handle->print(@_);
}

=method C<spin>

Emits a backspace and the next spin character to L<< C<output_handle>|/output_handle >>

=cut

sub spin {
    my $self = shift;
    $self->_print_to_output( "\b" . $self->_get_next_spinstate );
}

=method C<reset>

Emits a spin-character clearing sequence to L<< C<output_handle>|/output_handle >>

This is just

    \b : backspace over last character
    \s : print a space to erase past characters
    \b : backspace again to prepare for more output

=cut

sub reset {
    $_[0]->_print_to_output("\b \b");
}

1;
