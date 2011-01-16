use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'      => 'PortageXS',
    'VERSION_FROM' => 'lib/PortageXS.pm', # finds $VERSION
    'PREREQ_PM' => {	'Term::ANSIColor'	=> 0,
			'Test::Simple'		=> 0,
			'IO::Socket::SSL'	=> 0.97,
			'Sys::Syslog'		=> 0.18
		},
);
