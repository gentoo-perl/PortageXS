use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	ABSTRACT     => 'Portage abstraction layer for perl',
	NAME         => q[PortageXS],
	VERSION_FROM => 'lib/PortageXS.pm', # finds $VERSION
	PREREQ_PM   => {
		'Term::ANSIColor'	=> 0,
		'Test::Simple'		=> 0,
		'IO::Socket::SSL'	=> 0.97,
		'Sys::Syslog'		=> 0.18,
		'Scalar::Util'		=> 0,
	},
);
