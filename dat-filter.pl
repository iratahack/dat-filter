#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use XML::LibXML;

my $handle;
my $filename = 'FinalBurn Neo (ClrMame Pro XML, Arcade only).dat';

open $handle, '<', "exclude.txt";
chomp( my @exclude = <$handle> );
close $handle;
open $handle, '<', "include.txt";
chomp( my @include = <$handle> );
close $handle;

my $xml         = 0;
my $nc          = 0;
my $nb          = 0;
my $orientation = "";
while (my $param = shift @ARGV) {
    if ( $param eq "-x" ) {
        $xml = 1;
    }
    elsif ( $param eq "-nc" ) {
        $nc = 1;
    }
    elsif ( $param eq "-nb" ) {
        $nb = 1;
    }
    elsif ( $param eq "-dat" ) {
        $filename = shift @ARGV;
    }
    elsif ( $param eq "-v" ) {
        $orientation = "vertical";
    }
    elsif ( $param eq "-h" ) {
        $orientation = "horizontal";
    }
    elsif ( $param eq "-help" ) {
        say "Usage: $0 [options]\n";
        say "Options:";
        say "\t-help\tDisplay this help.";
        say "\t-dat <filename>";
        say "\t\tName of dat-file to process.";
        say "\t-x\tOutput in XML dat-file format.";
        say "\t-nc\tNo Clones, remove all clones from output.";
        say "\t-v\tVertical games only.";
        say "\t-h\tHorizontal games only.";

        say "";
        exit;
    }
}

my $dom = XML::LibXML->load_xml( location => $filename );

if ($xml) {
    say '<?xml version="1.0"?>';
    say '<datafile>';
    say $dom->findnodes('/datafile/header');
}

# lr-fbneo
scanDatFile("/datafile/game");

# lr-mame2003
scanDatFile("/mame/game");

exit(0);

sub scanDatFile {

    my $nodeName = $_[0];

    foreach my $game ( $dom->findnodes("$nodeName") ) {

        my $name = $game->getAttribute('name');
        my $desc = $game->findvalue("description");

        my ($video)  = $game->getChildrenByTagName("video");
        my ($driver) = $game->getChildrenByTagName("driver");

        # Always for BIOS
        if (
            ( defined $game->getAttribute('isbios')
                && $game->getAttribute('isbios') eq "yes" )
            || ( defined $game->getAttribute('runnable')
                && $game->getAttribute('runnable') eq "no" )
          )
        {
	    # Ignore BIOS
	    if ( $nb ) {
	        next;
	    }

            if ($xml) {
                say $game;
            }
            else {
                say $game->getAttribute("name");
            }
            next;
        }

        # Always include
        if ( grep( /^$name$/, @include ) ) {
            if ($xml) {
                say $game;
            }
            else {
                say $name;
            }
            next;
        }

        # No adult, etc. games
        if ( grep( /^$name$/, @exclude ) ) {
            next;
        }

        # Ignore gambling, mahjong, quiz, trivia, etc.
        if (   $desc =~ /prototype/i
            || $desc =~ /hack/i
            || $desc =~ /homebrew/i
            || $desc =~ /casino/i
            || $desc =~ /trivia/i
            || $desc =~ /quiz/i
            || $desc =~ /poker/i
            || $desc =~ /bubble system/i
            || $desc =~ /demo/i
            || $desc =~ /gambling/i
            || $desc =~ /puzzle/i
            || $desc =~ /beta/i
            || $desc =~ /mahjong/i )
        {
            next;
        }

        # Ignore clones
        if ( $nc && $game->getAttribute('cloneof') ) {
            next;
        }

        if (   $orientation
            && defined $video
            && $video->{orientation} ne $orientation )
        {
            next;
        }

        if ( defined $driver && $driver->getAttribute("status") eq "good" ) {
            if ($xml) {
                say $game;
            }
            else {
                say $game->getAttribute("name");
            }
        }
    }

    if ($xml) {
        say '</datafile>';
    }

}
