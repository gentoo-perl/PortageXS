use strict;
use warnings;

package PortageXS;
# ABSTRACT: Portage abstraction layer for perl

# -----------------------------------------------------------------------------
#
# PortageXS
#
# author      : Christian Hartmann <ian@gentoo.org>
# license     : GPL-2
# header      : $Header: /srv/cvsroot/portagexs/trunk/lib/PortageXS.pm,v 1.14 2008/12/01 19:53:27 ian Exp $
#
# -----------------------------------------------------------------------------
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# -----------------------------------------------------------------------------

use PortageXS::Core;
use PortageXS::System;
use PortageXS::Version;
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
			getBestEbuildVersion
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
	my $self	= shift ;

	my $pxs = bless {}, $self;

	$pxs->{'VERSION'}			= $VERSION;
	
	$pxs->{'PORTDIR'}			= $pxs->getPortdir();
	$pxs->{'PKG_DB_DIR'}			= '/var/db/pkg/';
	$pxs->{'PATH_TO_WORLDFILE'}		= '/var/lib/portage/world';
	$pxs->{'IS_INITIALIZED'}		= 1;
	
	$pxs->{'EXCLUDE_DIRS'}{'.'}		= 1;
	$pxs->{'EXCLUDE_DIRS'}{'..'}		= 1;
	$pxs->{'EXCLUDE_DIRS'}{'metadata'}	= 1;
	$pxs->{'EXCLUDE_DIRS'}{'licenses'}	= 1;
	$pxs->{'EXCLUDE_DIRS'}{'eclass'}	= 1;
	$pxs->{'EXCLUDE_DIRS'}{'distfiles'}	= 1;
	$pxs->{'EXCLUDE_DIRS'}{'profiles'}	= 1;
	$pxs->{'EXCLUDE_DIRS'}{'CVS'}		= 1;
	$pxs->{'EXCLUDE_DIRS'}{'.cache'}	= 1;
	
	$pxs->{'PORTAGEXS_ETC_DIR'}		= '/etc/pxs/';
	$pxs->{'ETC_DIR'}			= '/etc/';
	$pxs->{'MAKE_PROFILE_PATH'}		= '/etc/make.profile';
	
	# - init colors >
	$pxs->{'COLORS'}{'YELLOW'}		= color('bold yellow');
	$pxs->{'COLORS'}{'GREEN'}		= color('green');
	$pxs->{'COLORS'}{'LIGHTGREEN'}		= color('bold green');
	$pxs->{'COLORS'}{'WHITE'}		= color('bold white');
	$pxs->{'COLORS'}{'CYAN'}		= color('bold cyan');
	$pxs->{'COLORS'}{'RED'}			= color('bold red');
	$pxs->{'COLORS'}{'BLUE'}		= color('bold blue');
	$pxs->{'COLORS'}{'RESET'}		= color('reset');
	
	if (lc($pxs->getParamFromFile($pxs->getFileContents('/etc/make.conf'),'NOCOLOR','lastseen')) eq 'true') {
		$pxs->{'COLORS'}{'YELLOW'}		= '';
		$pxs->{'COLORS'}{'GREEN'}		= '';
		$pxs->{'COLORS'}{'LIGHTGREEN'}		= '';
		$pxs->{'COLORS'}{'WHITE'}		= '';
		$pxs->{'COLORS'}{'CYAN'}		= '';
		$pxs->{'COLORS'}{'RED'}			= '';
		$pxs->{'COLORS'}{'BLUE'}		= '';
		$pxs->{'COLORS'}{'RESET'}		= '';
	}

	return $pxs;
}


1;
