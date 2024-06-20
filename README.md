# Dat File Filter

Dat file filter for MAME or FBNeo. The main script, when executed without any parameters reads a dat file called *FinalBurn Neo (ClrMame Pro XML, Arcade only).dat* and lists all the ROM sets which do *NOT* contain the following in their description:

* prototype
* hack
* homebrew
* casino
* trivia
* quiz
* poker
* bubble system
* demo
* gambling
* puzzle
* beta
* mahjong

If the *exclude.txt* file exists, sets listed in this file will be filtered out. Conversely, sets listed in *include.txt* are forced to be included.

Command line options are available to remove clones and to output only horizontal or vertical ROM sets.

The provided *exclude.txt* file attempts to remove all mature games in addition to the *VS.* series of games and the *decocass* based games. Some non-clone duplicates are also listed for exclusion.

## Usage

```sh
Usage: ./dat-filter.pl [options]

Options:
    -help   Display this help.
    -dat <filename>
        Name of dat-file to process.
    -x  Output in XML dat-file format.
    -nc No Clones, remove all clones from output.
    -v  Vertical games only.
    -h  Horizontal games only.
```
