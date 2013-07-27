use strict;
use warnings;

package PortageXS::UI::Spinner::Rainbow;

# ABSTRACT: Console progress spinner bling.
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
extends 'PortageXS::UI::Spinner';

use IO::Handle;

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"PortageXS::UI::Spinner::Rainbow",
    "inherits":["PortageXS::UI::Spinner"],
    "interface":"class"
}

=end MetaPOD::JSON

=cut

=head1 SYNOPSIS

    use PortageXS::UI::Spinner::Rainbow;

    my $spinner = PortageXS::UI::Spinner->new(%attributes);

    for ( 0..1000 ){
        sleep 0.1;
        $spinner->spin;
    }
    $spinner->reset;

=cut

=attr C<colorstate>

The index of the I<next> color state to dispatch.

=cut

has colorstate => ( is => rwp =>, default => sub { 0 } );

=attr C<colorstates>

A list of colors to dispatch.

=cut

has colorstates => (
    is      => ro =>,
    default => sub {
        require Term::ANSIColor;
        my @c;
        push @c, map { Term::ANSIColor::color( 'bold ansi' . $_ ) } 1 .. 15;
        push @c, map { Term::ANSIColor::color( 'ansi' . $_ ) } 1 .. 15;
        \@c;
    }
);

=p_method C<_last_colorstate>

The number of L<< C<colorstates>|/colorstates >> this C<::Spinner::Rainbow> object has.

=cut

sub _last_colorstate { return $#{ $_[0]->colorstates } }

=p_method C<_increment_colorstate>

Increment the position within the L<< C<colorstates>|/colorstates >> array by one, updating L<< C<colorstate>|/colorstate >>

=cut

sub _increment_colorstate {
    my $self      = shift;
    my $rval      = $self->colorstate;
    my $nextstate = $rval + 0.3;
    if ( $nextstate > $self->_last_colorstate ) {
        $nextstate = 0;
    }
    $self->_set_colorstate($nextstate);
    return $rval;
}

=p_method C<_get_next_colorstate>

Returns the next character from the L<< C<colorstates>|/colorstates >> array

=cut

sub _get_next_colorstate {
    my (@states) = @{ $_[0]->colorstates };
    return $states[ $_[0]->_increment_colorstate ];
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
    require Term::ANSIColor;
    $self->_print_to_output( "\b"
          . $self->_get_next_colorstate
          . $self->_get_next_spinstate
          . Term::ANSIColor::color('reset') );
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
