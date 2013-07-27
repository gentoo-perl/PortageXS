
use strict;
use warnings;

package PortageXS::Colors;

# ABSTRACT: Colour formatting / translation for Gentoo

use Path::Tiny;
use Moo;

my %colors;

sub _has_color {
    my ( $name, $colorname ) = @_;
    has(
        'color_' . $name,
        is      => rwp =>,
        lazy    => 1,
        builder => sub {
            require Term::ANSIColor;
            Term::ANSIColor::color($colorname);
        }
    );
    $colors{$name} = $colorname;
}
my %task_colors;

sub _has_task_color {
    my ( $name, $colorname ) = @_;
    has(
        'task_color_' . $name,
        is      => rwp =>,
        lazy    => 1,
        builder => sub { $colorname }
    );
    $task_colors{$name} = $colorname;
}

=attr C<color_YELLOW>

=attr C<color_GREEN>

=attr C<color_LIGHTGREEN>

=cut

_has_color YELLOW     => 'bold yellow';
_has_color GREEN      => 'green';
_has_color LIGHTGREEN => 'bold green';

=attr C<color_WHITE>

=attr C<color_CYAN>

=attr C<color_RED>

=cut

_has_color WHITE => 'bold white';
_has_color CYAN  => 'bold cyan';
_has_color RED   => 'bold red';

=attr C<color_BLUE>

=attr C<color_RESET>

=cut

_has_color BLUE  => 'bold blue';
_has_color RESET => 'reset';

=attr task_color_ok

=attr task_color_err

=attr task_color_info

=cut

_has_task_color ok   => LIGHTGREEN =>;
_has_task_color err  => RED        =>;
_has_task_color info => YELLOW     =>;

=method C<getColor>

    my $colorCode = $colors->getColor('YELLOW');

=cut

sub getColor {
    my ( $self, $color ) = @_;
    if ( not exists $colors{$color} ) {
        die "No such color $color";
    }
    my $method = "color_$color";
    return $self->$method();
}

=method C<getTaskColor>

    my $color = $colors->getTaskColor('ok');
    my $colorCode = $colors->getColor($color);

=cut

sub getTaskColor {
    my ( $self, $task ) = @_;
    if ( not exists $task_colors{$task} ) {
        die "No such task $task";
    }
    my $method = "task_color_$task";
    return $self->$method();
}

=method C<printColor>

Emit a color code, turning on that colour for all future printing

    $colors->printColor('RED');
    print "this is red"

=cut

sub printColor {
    my ( $self, $color ) = @_;
    return print $self->getColor($color);
}

=method C<setPrintColor>

Emit a color code, turning on that colour for all future printing

    $colors->setPrintColor('RED');
    print "this is red"

=cut

sub setPrintColor {
    my ( $self, $color ) = @_;
    return print $self->getColor($color);
}

=method C<printTaskColor>

Emit a color code for a given task type, turning on that colour for all future printing

    $colors->printTaskColor('ok');
    print "this is green"

=cut

sub printTaskColor {
    my ( $self, $task ) = @_;
    return $self->printColor( $self->getTaskColor($task) );
}

=method C<disableColors>

Replace all colours with empty strings.

    $colors->disableColors;

=cut

sub disableColors {
    my ($self) = @_;
    for my $color ( keys %colors ) {
        my $setter = "_set_color_$color";
        $self->$setter('');
    }
}

=method C<restoreColors>

Restores factory color settings

    $colors->restoreColors;

=cut

sub restoreColors {
    my ( $self, ) = @_;
    for my $color ( keys %colors ) {
        my $setter = "_set_color_$color";
        require Term::ANSIColor;
        $self->$setter( Term::ANSIColor::color( $colors{$color} ) );
    }

}

=method C<messageColored>

Formats a string to Gentoo message styling

    my $message = $color->messageColored( 'RED' , "Hello World" )

    $message eq " <RED ON>*<RESET> Hello World"

=cut

sub messageColored {
    my ( $self, $color, @message ) = @_;
    return sprintf ' %s* %s%s', $self->getColor($color), $self->color_RESET,
      join '', @message;
}

=method C<printColored>

Its C<messageColored>, but prints to STDOUT

    $color->printColored( 'RED' , "Hello World" )

=cut

sub printColored {
    my ( $self, $color, $message ) = @_;
    return print $self->messageColored( $color, $message );
}

=method C<messageTaskColored>

As with C<messageColored>, but takes a task name instead of a color

    my $message = $color->messageTaskColored( 'ok' , "Hello World" )

    $message eq " <GREEN ON>*<RESET> Hello World"

=cut

sub messageTaskColored {
    my ( $self, $task, $message ) = @_;
    return $self->messageColored( $self->getTaskColor($task), $message );
}

=method C<printTaskColored>

Its C<messageTaskColored>, but prints to STDOUT

    $colors->printTaskColored( 'ok' , "Hello World" )

=cut

sub printTaskColored {
    my ( $self, $task, $message ) = @_;
    return print $self->messageTaskColored( $task, $message );
}

=method C<print_ok>

Its C<printTaskColored>, but shorter and 'ok' is implied

    $colors->printTaskColored( 'ok', $message );
    $colors->print_ok( $message ); # Easy

=cut

sub print_ok {
    my ( $self, $message ) = @_;
    return $self->printTaskColored( 'ok', $message );
}

=method C<print_err>

Its C<printTaskColored>, but shorter and 'err' is implied

    $colors->printTaskColored( 'err', $message );
    $colors->print_err( $message ); # Easy

=cut

sub print_err {
    my ( $self, $message ) = @_;
    return $self->printTaskColored( 'err', $message );
}

=method C<print_info>

Its C<printTaskColored>, but shorter and 'info' is implied

    $colors->printTaskColored( 'info', $message );
    $colors->print_err( $message ); # Easy

=cut

sub print_info {
    my ( $self, $message ) = @_;
    return $self->printTaskColored( 'info', $message );
}

1;

