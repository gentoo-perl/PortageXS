package PortageXS::Core;

# -----------------------------------------------------------------------------
#
# PortageXS::Core
#
# author      : Christian Hartmann <ian@gentoo.org>
# license     : GPL-2
# header      : $Header: /srv/cvsroot/portagexs/trunk/lib/PortageXS/Core.pm,v 1.12 2007/04/09 15:03:51 ian Exp $
#
# -----------------------------------------------------------------------------
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# -----------------------------------------------------------------------------

use DirHandle;
require Exporter;
our @ISA = qw(Exporter PortageXS);
our @EXPORT = qw(
			getArch
			getPortdir
			getPortdirOverlay
			getFileContents
			searchInstalledPackage
			searchPackage
			getParamFromFile
			getUseSettingsOfInstalledPackage
			getAvailableEbuilds
			getPortageXScategorylist
			getAvailableArches
			getPackagesFromCategory
			fileBelongsToPackage
			getFilesOfInstalledPackage
			getEbuildVersion
			getEbuildName
			getReponame
			resolveMirror
			getCategories
			getProfilePath
			resetCaches
		);

# Description:
# Returnvalue is ARCH set in the system-profile.
#
# Example:
# $arch=$pxs->getArch();
sub getArch {
	my $self	= shift;
	my $curPath	= "";
	my @files	= ();
	my $parent	= "";
	my $buffer	= "";
	
	if(!-e $self->{'MAKE_PROFILE_PATH'}) {
		$self->print_err('Profile not set!');
		exit(0);
	}
	else {
		$curPath=$self->{'ETC_DIR'}.readlink($self->{'MAKE_PROFILE_PATH'});
	}
	
	while(1) {
		if (-e $curPath.'/make.defaults') {
			push(@files,$curPath.'/make.defaults');
		}
		if (! -e $curPath.'/parent') { last; }
		$parent=$self->getFileContents($curPath.'/parent');
		chomp($parent);
		$curPath.='/'.$parent;
	}
	
	$buffer.=$self->getFileContents("/etc/make.conf").$self->getFileContents("/etc/make.globals");
	foreach(@files) {
		$buffer.=$self->getFileContents($_);
	}
	
	return $self->getParamFromFile($buffer,'ARCH','firstseen');
}

# Description:
# Returnvalue is PORTDIR from make.conf or make.globals (make.conf overrules make.globals).
# This function initializes itself at the first time it is called and reuses $self->{'PORTDIR'}
# as a return value from then on.
#
# Provides:
# $self->{'PORTDIR'}
#
# Parameters:
# $forcereload is optional and forces a reload of the make.conf and make.globals files.
#
# Example:
# $portdir=$pxs->getPortdir([$forcereload]);
sub getPortdir {
	my $self	= shift;
	my $forcereload	= shift;
	
	if ($self->{'PORTDIR'} && !$forcereload) {
		return $self->{'PORTDIR'};
	}
	else {
		$self->{'PORTDIR'}=$self->getParamFromFile($self->getFileContents("/etc/make.globals").$self->getFileContents("/etc/make.conf"),"PORTDIR","lastseen");
		return $self->{'PORTDIR'};
	}
}

# Description:
# Returnvalue is PORTDIR_OVERLAY from make.conf or make.globals (make.conf overrules make.globals).
#
# Parameters:
# $forcereload is optional and forces a reload of the make.conf and make.globals files.
#
# Example:
# @portdir_overlay=$pxs->getPortdirOverlay();
sub getPortdirOverlay {
	my $self	= shift;
	my $forcereload	= shift;
	
	return split(/ /,$self->getParamFromFile($self->getFileContents('/etc/make.globals').$self->getFileContents('/etc/make.conf'),'PORTDIR_OVERLAY','lastseen'));
}

# Description:
# Returnvalue is the content of the given file.
# $filecontent=$pxs->getFileContents($file);
sub getFileContents {
	open(FH,"<".$_[1]) or die('Cannot open file '.$_[1]);
	my $content = do{local $/; <FH>};
	close(FH);
	return $content;
}

# Description:
# Returns an array containing all packages that match $searchString
# @packages=$pxs->searchInstalledPackage($searchString);
sub searchInstalledPackage {
	my $self		= shift;
	my $searchString	= shift; if (! $searchString) { $searchString=''; }
	my $int_c		= 0;
	my @matches		= ();
	my $s_cat		= '';
	my $s_pak		= '';
	my $m_cat		= 0;
	my $dhc;
	my $dhp;
	my $tc;
	my $tp;
	
	# - escape special chars >
	$searchString =~ s/\+/\\\+/g;

	# - split >
	if ($searchString=~m/\//) {
		($s_cat,$s_pak)=split(/\//,$searchString);
	}
	else {
		$s_pak=$searchString;
	}
	
	$s_cat=~s/\*//g;
	$s_pak=~s/\*//g;
	
	# - read categories >
	$dhc = new DirHandle($self->{'PKG_DB_DIR'});
	if (defined $dhc) {
		while (defined($tc = $dhc->read)) {
			$m_cat=0;
			if ($s_cat ne '') {
				if ($tc=~m/$s_cat/i) {
					$m_cat=1;
				}
				else {
					next;
				}
			}
			
			# - not excluded and $_ is a dir?
			if (! $self->{'EXCLUDE_DIRS'}{$tc} && -d $self->{'PKG_DB_DIR'}.'/'.$tc) {
				$dhp = new DirHandle($self->{'PKG_DB_DIR'}.'/'.$tc);
				while (defined($tp = $dhp->read)) {
					# - check if packagename matches
					#   (faster if we already check it now) >
					if ($tp =~m/$s_pak/i || $s_pak eq "") {
						# - not excluded and $_ is a dir?
						if (! $self->{'EXCLUDE_DIRS'}{$tp} && -d $self->{'PKG_DB_DIR'}.'/'.$tc.'/'.$tp) {
							if (($s_cat ne '') && ($m_cat)) {
								push(@matches,$tc.'/'.$tp);
							}
							elsif ($s_cat eq '') {
								push(@matches,$tc.'/'.$tp);
							}
						}
					}
				}
				undef $dhp;
			}
		}
	}
	undef $dhc;
	
	return (sort @matches);
}

# Description:
# DO NOT USE THIS FUNCTION AS IT WILL MOST PROBABLY CHANGE IN THE FUTURE!
# TODO
# mode: like || exact
sub searchPackage {
	my $self		= shift;
	my $searchString	= shift;
	my $mode		= shift;
	my $int_c		= 0;
	my $dhc;
	my $dhp;
	my $tc;
	my $tp;
	my @matches		= ();
	my @repos		= ();
	my $repo_name		= '';
	
	if (!$mode) { $mode='like'; }
	
	# - get all repos >
	push(@repos,$self->{'PORTDIR'});
	push(@repos,$self->getPortdirOverlay());
	
	# - escape special chars >
	if ($mode eq 'like') {
		$searchString =~ s/\+/\\\+/g;
		
		# - read categories >
		foreach $this_repodir (@repos) {
			$repo_name = $self->getReponame($this_repodir);
			$dhc = new DirHandle($this_repodir);
			if (defined $dhc) {
				while (defined($tc = $dhc->read)) {
					# - not excluded and $_ is a dir?
					if (! $self->{'EXCLUDE_DIRS'}{$tc} && -d $this_repodir.'/'.$tc) {
						$dhp = new DirHandle($this_repodir.'/'.$tc);
						while (defined($tp = $dhp->read)) {
							# - look up if entry matches the search
							#  (much faster if we already check now) >
							if ($tp =~m/$searchString/i) {
								# - not excluded and $_ is a dir?
								if (! $self->{'EXCLUDE_DIRS'}{$tp} && -d $this_repodir.'/'.$tc.'/'.$tp) {
									push(@matches,$repo_name.':'.$tc.'/'.$tp);
								}
							}
						}
						undef $dhp;
					}
				}
			}
			undef $dhc;
		}
	}
	elsif ($mode eq 'exact') {
		# - read categories >
		foreach $this_repodir (@repos) {
			$repo_name = $self->getReponame($this_repodir);
			$dhc = new DirHandle($this_repodir);
			if (defined $dhc) {
				while (defined($tc = $dhc->read)) {
					# - not excluded and $_ is a dir?
					if (! $self->{'EXCLUDE_DIRS'}{$tc} && -d $this_repodir.'/'.$tc) {
						$dhp = new DirHandle($this_repodir.'/'.$tc);
						while (defined($tp = $dhp->read)) {
							# - look up if entry matches the search
							#  (much faster if we already check now) >
							if ($tp eq $searchString) {
								# - not excluded and $_ is a dir?
								if (! $self->{'EXCLUDE_DIRS'}{$tp} && -d $this_repodir.'/'.$tc.'/'.$tp) {
									push(@matches,$repo_name.':'.$tc.'/'.$tp);
								}
							}
						}
						undef $dhp;
					}
				}
			}
			undef $dhc;
		}
	}
	
	return (sort @matches);
}

# Description:
# Returns the value of $param. Expects filecontents in $file.
# $valueOfKey=$pxs->getParamFromFile($filecontents,$key,{firstseen,lastseen});
# e.g.
# $valueOfKey=$pxs->getParamFromFile($pxs->getFileContents("/path/to.ebuild"),"IUSE","firstseen");
sub getParamFromFile {
	my $self	= shift;
	my $file	= shift;
	my $param	= shift;
	my $mode	= shift; # ("firstseen","lastseen") - default is "lastseen"
	my $c		= 0;
	my $d		= 0;
	my @lines	= ();
	my $value	= ""; # value of $param
	
	# - split file in lines >
	@lines = split(/\n/,$file);
	
	for($c=0;$c<=$#lines;$c++) {
		next if $lines[$c]=~m/^#/;
		
		# - remove comments >
		$lines[$c]=~s/#(.*)//g;
		
		if ($lines[$c]=~/$param="(.*)"/) {
			# single-line with quotationmarks >
			$value=$1;
		
			if ($mode eq "firstseen") {
				# - 6. clean up value >
				$value=~s/^[ |\t]+//; # remove leading whitespaces and tabs
				$value=~s/[ |\t]+$//; # remove trailing whitespaces and tabs
				$value=~s/\t/ /g;     # replace tabs with whitespaces
				$value=~s/ {2,}/ /g;  # replace 1+ whitespaces with 1 whitespace
				return $value;
			}
		}
		elsif ($lines[$c]=~/$param="(.*)/) {
			# multi-line with quotationmarks >
			$value=$1." ";
			for($d=$c+1;$d<=$#lines;$d++) {
				# - look for quotationmark >
				if ($lines[$d]=~/(.*)"?/) {
					# - found quotationmark; append contents and leave loop >
					$value.=$1;
					last;
				}
				else {
					# - no quotationmark found; append line contents to $value >
					$value.=$lines[$d]." ";
				}
			}
		
			if ($mode eq "firstseen") {
				# - clean up value >
				$value=~s/^[ |\t]+//; # remove leading whitespaces and tabs
				$value=~s/[ |\t]+$//; # remove trailing whitespaces and tabs
				$value=~s/\t/ /g;     # replace tabs with whitespaces
				$value=~s/ {2,}/ /g;  # replace 1+ whitespaces with 1 whitespace
				return $value;
			}
		}
		elsif ($lines[$c]=~/$param=(.*)/) {
			# - single-line without quotationmarks >
			$value=$1;
			
			if ($mode eq "firstseen") {
				# - 6. clean up value >
				$value=~s/^[ |\t]+//; # remove leading whitespaces and tabs
				$value=~s/[ |\t]+$//; # remove trailing whitespaces and tabs
				$value=~s/\t/ /g;     # replace tabs with whitespaces
				$value=~s/ {2,}/ /g;  # replace 1+ whitespaces with 1 whitespace
				return $value;
			}
		}
	}
	
	# - clean up value >
	$value=~s/^[ |\t]+//; # remove leading whitespaces and tabs
	$value=~s/[ |\t]+$//; # remove trailing whitespaces and tabs
	$value=~s/\t/ /g;     # replace tabs with whitespaces
	$value=~s/ {2,}/ /g;  # replace 1+ whitespaces with 1 whitespace
	
	return $value;
}

# Description:
# Returns useflag settings of the given (installed) package.
# @useflags=$pxs->getUseSettingsOfInstalledPackage("dev-perl/perl-5.8.8-r3");
sub getUseSettingsOfInstalledPackage {
	my $self		= shift;
	my $package		= shift;
	my $tmp_filecontents	= "";
	my @package_IUSE	= ();
	my @package_USE		= ();
	my @USEs		= ();
	my $hasuse		= '';
	my $thisUSE		= '';
	my $thisIUSE		= '';
	
	if (-e $self->{'PKG_DB_DIR'}.'/'.$package.'/IUSE') {
		$tmp_filecontents	= $self->getFileContents($self->{'PKG_DB_DIR'}.'/'.$package.'/IUSE');
	}
	$tmp_filecontents	=~s/\n//g;
	@package_IUSE		= split(/ /,$tmp_filecontents);
	if (-e $self->{'PKG_DB_DIR'}."/".$package."/USE") {
		$tmp_filecontents	= $self->getFileContents($self->{'PKG_DB_DIR'}.'/'.$package.'/USE');
	}
	$tmp_filecontents	=~s/\n//g;
	@package_USE		= split(/ /,$tmp_filecontents);
	
	foreach $thisIUSE (@package_IUSE) {
		next if ($thisIUSE eq '');
		$hasuse = '-';
		foreach $thisUSE (@package_USE) {
			if ($thisIUSE eq $thisUSE) {
				$hasuse='';
				last;
			}
		}
		push(@USEs,$hasuse.$thisIUSE);
	}
	
	return @USEs;
}

# Description:
# @listOfEbuilds=$pxs->getAvailableEbuilds(category/packagename);
sub getAvailableEbuilds {
	my $self	= shift;
	my $catPackage	= shift;
	my @packagelist	= ();
	
	if (-e $self->{PORTDIR}.'/'.$catPackage) {
		# - get list of ebuilds >
		my $dh = new DirHandle($self->{PORTDIR}.'/'.$catPackage);
		while (defined($_ = $dh->read)) {
			if ($_ =~ m/(.+)\.ebuild$/) {
				push(@packagelist,$_);
			}
		}
	}
	
	return @packagelist;
}

# Description:
# @listOfArches=$pxs->getAvailableArches();
sub getAvailableArches {
	my $self	= shift;
	return split(/\n/,$self->getFileContents($self->{'PORTDIR'}.'/profiles/arch.list'));
}

# Description:
# Reads from /etc/portagexs/categories/$listname.list and returns all entries as an array.
# @listOfCategories=$pxs->getPortageXScategorylist($listname);
sub getPortageXScategorylist {
	my $self	= shift;
	my $category	= shift;
	
	return split(/\n/,$self->getFileContents($self->{'PORTAGEXS_ETC_DIR'}.'/categories/'.$category.'.list'));
}

# Description:
# Returns all available packages from the given category.
# @listOfPackages=$pxs->getPackagesFromCategory($category);
# E.g.:
# @listOfPackages=$pxs->getPackagesFromCategory("dev-perl");
sub getPackagesFromCategory {
	my $self	= shift;
	my $category	= shift;
	my $dhp;
	my $tp;
	my @packages	= ();
	
	return () if !$category;
	
	$dhp = new DirHandle($self->{'PORTDIR'}.'/'.$category);
	while (defined($tp = $dhp->read)) {
		# - not excluded and $_ is a dir?
		if (! $self->{'EXCLUDE_DIRS'}{$tp} && -d $self->{'PORTDIR'}.'/'.$category.'/'.$tp) {
			push(@packages,$tp);
		}
	}
	undef $dhp;

	return @packages;
}

# Description:
# Returns package(s) where $file belongs to.
# (Actually this is an array and not a scalar due to a portage design bug.)
# @listOfPackages=$pxs->fileBelongsToPackage("/path/to/file");
sub fileBelongsToPackage {
	my $self	= shift;
	my $file	= shift;

	my $int_c	= 0;
	my @matches	= ();
	my $dhc;
	my $dhp;
	my $tc;
	my $tp;
	
	# - read categories >
	$dhc = new DirHandle($self->{'PKG_DB_DIR'});
	if (defined $dhc) {
		while (defined($tc = $dhc->read)) {
			# - not excluded and $_ is a dir?
			if (! $self->{EXCLUDE_DIRS}{$tc} && -d $self->{'PKG_DB_DIR'}.'/'.$tc) {
				$dhp = new DirHandle($self->{'PKG_DB_DIR'}.'/'.$tc);
				while (defined($tp = $dhp->read)) {
					# - not excluded and $_ is a dir?
					if (! $self->{EXCLUDE_DIRS}{$tp} && -d $self->{'PKG_DB_DIR'}.'/'.$tc.'/'.$tp) {
						my $data = $self->getFileContents($self->{'PKG_DB_DIR'}.'/'.$tc.'/'.$tp.'/CONTENTS');
						my @lines = split(/\n/,$data);
						foreach (@lines) {
							my $thisfile = (split(/ /,$_))[1];
							if ($thisfile eq $file) {
								push(@matches,$tc.'/'.$tp);
							}
						}
					}
				}
				undef $dhp;
			}
		}
	}
	undef $dhc;
	
	return @matches;
}

# Description:
# Returns all files provided by $category/$package.
# @listOfFiles=$pxs->getFilesOfInstalledPackage("$category/$package");
sub getFilesOfInstalledPackage {
	my $self	= shift;
	my $package	= shift;
	my @files	= ();
	
	# - find installed versions & loop >
	foreach ($self->searchInstalledPackage($package)) {
		my $data = $self->getFileContents($self->{PKG_DB_DIR}.'/'.$_.'/CONTENTS');
		my @lines = split(/\n/,$data);
		foreach (@lines) {
			push(@files,(split(/ /,$_))[1]);
		}
	}

	return @files;
}

# Description:
# Returns version of an ebuild.
# $version=$pxs->getEbuildVersion("foo-1.23-r1.ebuild");
sub getEbuildVersion {
	my $self	= shift;
	my $version	= shift;
	$version =~ s/\.ebuild$//;
	$version =~ s/^([a-zA-Z0-9\-_\/\+]*)-([0-9\.]+[a-zA-Z]?)/$2/;
	
	return $version;
}

# Description:
# Returns name of an ebuild (w/o version).
# $version=$pxs->getEbuildName("foo-1.23-r1.ebuild");
sub getEbuildName {
	my $self	= shift;
	my $version	= shift;
	my $name	= $version;
	
	$version =~ s/^([a-zA-Z0-9\-_\/\+]*)-([0-9\.]+[a-zA-Z]?)/$2/;
	
	return substr($name,0,length($name)-length($version)-1);
}

# Description:
# Returns the repo_name of the given repo.
# $repo_name=$pxs->getReponame($repo);
# Example:
# $repo_name=$pxs->getRepomane("/usr/portage");
sub getReponame {
	my $self	= shift;
	my $repo	= shift;
	my $repo_name	= '';
	
	if (-f $repo.'/profiles/repo_name') {
		$repo_name = $self->getFileContents($repo.'/profiles/repo_name');
		chomp($repo_name);
		return $repo_name;
	}
	
	return '';
}

# Description:
# Returns an array of URLs of the given mirror.
# @mirrorURLs=$pxs->resolveMirror($mirror);
# Example:
# @mirrorURLs=$pxs->resolveMirror('cpan');
sub resolveMirror {
	my $self	= shift;
	my $mirror	= shift;
	my $buffer	= $self->getFileContents($self->{PORTDIR}.'/profiles/thirdpartymirrors');
	
	foreach (split(/\n/,$buffer)) {
		my @p=split(/\t/,$_);
		if ($mirror eq $p[0]) {
			return split(/ /,$p[2]);
		}
	}
	
	return;
}

# Description:
# Returns list of valid categories (from $repo/profiles/categories)
# @categories=$pxs->getCategories($repo);
# Example:
# @categories=$pxs->getCategories('/usr/portage');
sub getCategories {
	my $self	= shift;
	my $repo	= shift;
	my @categories	= ();
	
	if (-e $repo.'/profiles/categories') {
		return split(/\n/,$self->getFileContents($repo.'/profiles/categories'));
	}
	
	return ();
}

# Description:
# Returns path to profile.
# $path=$pxs->getProfilePath();
sub getProfilePath {
	my $self	= shift;
	return $self->{'ETC_DIR'}.readlink($self->{'MAKE_PROFILE_PATH'});
}

# Description:
# Returns path to profile.
# $pxs->resetCaches();
sub resetCaches {
	my $self	= shift;
	
	# - Core >
	$self->{'PORTDIR'}=undef;
	$self->{'PORTDIR'}=$self->getPortdir();
	
	# - Console >
	
	# - System - getHomedir >
	$self->{'CACHE'}{'System'}{'getHomedir'}{'homedir'}=undef;
	
	# - Useflags - getUsedescs >
	foreach my $k1 (keys %{$self->{'CACHE'}{'Useflags'}{'getUsedescs'}}) {
		$self->{'CACHE'}{'Useflags'}{'getUsedescs'}{$k1}{'use.desc'}{'initialized'}=undef;
		foreach my $k2 (keys %{$self->{'CACHE'}{'Useflags'}{'getUsedescs'}{$k1}{'use.desc'}{'use'}}) {
			$self->{'CACHE'}{'Useflags'}{'getUsedescs'}{$k1}{'use.desc'}{'use'}{$k2}=undef;
		}
		$self->{'CACHE'}{'Useflags'}{'getUsedescs'}{$k1}{'use.desc'}{'use'}=undef;
		$self->{'CACHE'}{'Useflags'}{'getUsedescs'}{$k1}{'use.local.desc'}=undef;
	}
	
	# - Useflags - getUsemasksFromProfile >
	$self->{'CACHE'}{'Useflags'}{'getUsemasksFromProfile'}{'useflags'}=undef;
	
	return 1;
}

1;