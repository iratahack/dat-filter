#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use XML::LibXML;
my $handle;
my $filename = 'FinalBurn Neo (ClrMame Pro XML, Arcade only).dat';

open $handle, '<', "exclude.txt";
chomp(my @exclude = <$handle>);
close $handle;
open $handle, '<', "include.txt";
chomp(my @include = <$handle>);
close $handle;

my $dom = XML::LibXML->load_xml(location => $filename);

my $xml=0;
if (defined $ARGV[0] && $ARGV[0] eq "-x")
{
	$xml = 1;
	say '<?xml version="1.0"?>';
	say '<datafile>';
	say $dom->findnodes('/datafile/header');
}

foreach my $game ($dom->findnodes('/datafile/game')) {

	my $name = $game->getAttribute('name');
	my $desc = $game->findvalue("description");

	my ($video) = $game->getChildrenByTagName("video");
	my ($driver) = $game->getChildrenByTagName("driver");

	# Always for BIOS
	if ( $game->getAttribute('isbios') )
	{
		if ( $xml )
		{
			say $game;
		}
		else
		{
			say $game->getAttribute("name");
		}
		next;
	}

	# Always include
	if (grep(/$name/, @include))
	{
		if ( $xml )
		{
			say $game;
		}
		else
		{
			say $game->getAttribute("name");
		}
		next;
	}

	# Ignore decocass games
	if (
		$game->getAttribute('romof') &&
		$game->getAttribute('romof') =~ /decocass/
	)
	{
		next;
	}

	# No adult, etc. games
	if (grep(/$name/, @exclude))
	{
		next;
	}

	# Ignore gambling, mahjong, quiz, trivia, etc.
	if ( 
		$desc =~ /prototype/i ||
		$desc =~ /hack/i ||
		$desc =~ /homebrew/i ||
		$desc =~ /casino/i ||
		$desc =~ /trivia/i ||
		$desc =~ /quiz/i ||
		$desc =~ /poker/i ||
		$desc =~ /bubble system/i ||
		$desc =~ /mahjong/i
	)
	{
		next;
	}

	# Ignore clones
	if ( $game->getAttribute('cloneof') )
	{
		next;
	}

	if ( $video->{orientation} &&
		"$video->{orientation}" eq "vertical" &&
		$driver->getAttribute("status") eq "good" )
	{
		if ( $xml )
		{
			say $game;
		}
		else
		{
			say $game->getAttribute("name");
		}
	}
}

if($xml)
{
	say '</datafile>';
}
