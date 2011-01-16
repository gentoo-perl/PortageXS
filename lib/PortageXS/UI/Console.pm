package PortageXS::UI::Console;

# -----------------------------------------------------------------------------
#
# PortageXS::UI::Console
#
# author      : Christian Hartmann <ian@gentoo.org>
# license     : GPL-2
# header      : $Header: /srv/cvsroot/portagexs/trunk/lib/PortageXS/UI/Console.pm,v 1.6 2007/04/09 15:03:51 ian Exp $
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
			printColored
			print_ok
			print_err
			print_info
			setPrintColor
			cmdAskUser
			formatUseflags
		);

# Description:
# Prints gentoo-style items.
sub printColored {
	my $self	= shift;
	print ' ' . $self->{'COLORS'}{shift()} . '* ' . $self->{'COLORS'}{'RESET'} . shift() , @_;
}

# Description:
# Wrapper for printColored >
sub print_ok {
	my $self	= shift;
	$self->printColored('LIGHTGREEN',shift);
}

# Description:
# Wrapper for printColored >
sub print_err {
	my $self	= shift;
	$self->printColored('RED',shift);
}

# Description:
# Wrapper for printColored >
sub print_info {
	my $self	= shift;
	$self->printColored('YELLOW',shift);
}

# Description:
# Changes color to given param >
sub setPrintColor {
	my $self	= shift;
	print $self->{'COLORS'}{shift()};
}

# Description:
# Asks user to make a decision.
# $usersChoice=$pxs->cmdAskUser($question,$options);
# $question: Text
# $options: Comma separated values (y,n,a,...)
# $usersChoice: one of the values given in $options in lowercase
sub cmdAskUser {
	my $self	= shift;
	my $question	= shift;
	my $option	= shift;
	my @options	= ();
	my $userInput	= "";
	my $this_option	= "";
	my $valid	= 0;
	
	# - split comma seperated options >
	@options = split(/,/,$option);

	# - loop until user has entered a valid option >
	do {
		print " ".$question." (".join("/",@options)."): ";
		chomp($userInput = <STDIN>);
		foreach $this_option (@options) {
			if (lc($this_option) eq lc($userInput)) {
				$valid=1;
				last;
			}
		}
	}
	until($valid);

	return lc($userInput);
}

# Description:
# Formats useflags for output the way portages does.
# @formattedUseflags=$pxs->formatUseflags(@useflags);
sub formatUseflags {
	my $self	= shift;
	my @useflags	= @_;
	my @use1	= (); # +
	my @use2	= (); # -
	my %masked	= ();
	
	foreach ($self->getUsemasksFromProfile()) {
		$masked{$_}=1;
	}
	
	# - Sort - Needed for the right display order >
	for (my $x=0;$x<=$#useflags;$x++) {
		if (substr($useflags[$x],0,1) eq '-') {
			push(@use2,$useflags[$x]);
		}
		else {
			push(@use1,$useflags[$x]);
		}
	}
	@useflags=();
	push(@useflags,sort(@use1));
	push(@useflags,sort(@use2));
	@use1=();
	@use2=();
	
	# - Apply colors and use.mask >
	for (my $x=0;$x<=$#useflags;$x++) {
		if (substr($useflags[$x],0,1) eq '-') {
			if ($masked{substr($useflags[$x],1,length($useflags[$x])-1)}) {
				push(@use2,'('.$self->{'COLORS'}{'BLUE'}.$useflags[$x].$self->{'COLORS'}{'RESET'}.')');
			}
			else {
				push(@use2,$self->{'COLORS'}{'BLUE'}.$useflags[$x].$self->{'COLORS'}{'RESET'});
			}
		}
		else {
			if ($masked{$useflags[$x]}) {
				push(@use1,'('.$self->{'COLORS'}{'RED'}.$useflags[$x].$self->{'COLORS'}{'RESET'}.')');
			}
			else {
				push(@use1,$self->{'COLORS'}{'RED'}.$useflags[$x].$self->{'COLORS'}{'RESET'});
			}
		}
	}
	
	return @use1,@use2;
}

1;
