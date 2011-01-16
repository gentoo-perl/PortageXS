package PortageXS;

# -----------------------------------------------------------------------------
#
# PortageXS
#
# author      : Christian Hartmann <ian@gentoo.org>
# license     : GPL-2
# header      : $Header: /srv/cvsroot/portagexs/trunk/lib/PortageXS.pm,v 1.13 2007/05/20 14:17:40 ian Exp $
#
# -----------------------------------------------------------------------------
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# -----------------------------------------------------------------------------

$VERSION='0.02.07';

use PortageXS::Core;
use PortageXS::System;
use PortageXS::UI::Console;
use PortageXS::Useflags;
use Term::ANSIColor;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(
			getArch
			getPortdir
			getPortdirOverlay
			getFileContents
			searchInstalledPackage
			getParamFromFile
			getUseSettingsOfInstalledPackage
			printColored
			print_ok
			print_err
			print_info
			getPortageXScategorylist
			getAvailableEbuilds
			cmdExecute
			getAvailableArches
			getPackagesFromCategory
			fileBelongsToPackage
			getFilesOfInstalledPackage
			cmdAskUser
			getHomedir
			getEbuildVersion
			getEbuildName
		);

sub new {
	my $self	= {};

	bless($self);

	$self->{'VERSION'}			= $VERSION;
	
	$self->{'PORTDIR'}			= $self->getPortdir();
	$self->{'PKG_DB_DIR'}			= '/var/db/pkg/';
	$self->{'PATH_TO_WORLDFILE'}		= '/var/lib/portage/world';
	$self->{'IS_INITIALIZED'}		= 1;
	
	$self->{'EXCLUDE_DIRS'}{'.'}		= 1;
	$self->{'EXCLUDE_DIRS'}{'..'}		= 1;
	$self->{'EXCLUDE_DIRS'}{'metadata'}	= 1;
	$self->{'EXCLUDE_DIRS'}{'licenses'}	= 1;
	$self->{'EXCLUDE_DIRS'}{'eclass'}	= 1;
	$self->{'EXCLUDE_DIRS'}{'distfiles'}	= 1;
	$self->{'EXCLUDE_DIRS'}{'profiles'}	= 1;
	$self->{'EXCLUDE_DIRS'}{'CVS'}		= 1;
	$self->{'EXCLUDE_DIRS'}{'.cache'}	= 1;
	
	$self->{'PORTAGEXS_ETC_DIR'}		= '/etc/pxs/';
	$self->{'ETC_DIR'}			= '/etc/';
	$self->{'MAKE_PROFILE_PATH'}		= '/etc/make.profile';
	
	# - init colors >
	$self->{'COLORS'}{'YELLOW'}		= color('bold yellow');
	$self->{'COLORS'}{'GREEN'}		= color('green');
	$self->{'COLORS'}{'LIGHTGREEN'}		= color('bold green');
	$self->{'COLORS'}{'WHITE'}		= color('bold white');
	$self->{'COLORS'}{'CYAN'}		= color('bold cyan');
	$self->{'COLORS'}{'RED'}		= color('bold red');
	$self->{'COLORS'}{'BLUE'}		= color('bold blue');
	$self->{'COLORS'}{'RESET'}		= color('reset');
	
	if (lc($self->getParamFromFile($self->getFileContents('/etc/make.conf'),'NOCOLOR','lastseen')) eq 'true') {
		$self->{'COLORS'}{'YELLOW'}		= '';
		$self->{'COLORS'}{'GREEN'}		= '';
		$self->{'COLORS'}{'LIGHTGREEN'}		= '';
		$self->{'COLORS'}{'WHITE'}		= '';
		$self->{'COLORS'}{'CYAN'}		= '';
		$self->{'COLORS'}{'RED'}		= '';
		$self->{'COLORS'}{'BLUE'}		= '';
		$self->{'COLORS'}{'RESET'}		= '';
	}

	return $self;
}


1;
