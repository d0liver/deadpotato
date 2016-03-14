#ifndef DEADPOTATO_MAP_FILE_PARSER_H
#include "err.h"
/* This should be a text file. This file defines the layout of the map. It
 * tells Realpolitik which spaces are adjacent to which and where armies and
 * fleets can move. This is the hardest file for the variant creator to make -
 * actually it's not hard - it's tedious. But if your variant is based on a map
 * that's already used by another variant, then you're home free. This file
 * follows a very structured syntax. It is the same format used by the
 * Diplomacy judges (servers used to run games over the internet
 * automatically). So if you download a judge .map file, you should be able to
 * plug it right into Realpolitik. Besides being used by Realpolitik, the
 * Region Tool uses this file to create the Variant.rgn file. */
/* This file consists of three sections separated by -1 on a line by itself. */
struct Map {
	/*
	 * The first section defines the spaces on the map. For each region there
	 * should be one line consisting of
	 *     <name>, <letter(s)> <abbreviations>
	 * where:
	 *     name = The full name of the region (e.g. Norway)
	 *     letter = The (generally) single letter that is used to define what
	 *     type of region it is - where:

	 *         l = land

	 *         w = water. This letter can also be appended to land provinces,
	 *         or home or neutral supply centers, to indicate a coastal space
	 *         that can be used by fleets to convoy (for example, Baleares in
	 *         Ancient Med), e.g. lw or Aw or xw

	 *         <capital initial> = home supply center (assumed to be land) for
	 *         a given power using the capital initial defined for that power
	 *         in the Variant.cnt file

	 *         x = supply center that starts the game neutral (assumed to be
	 *         land)

	 *         v = ice (used in some rule variants, for example Loeb9)
	 *
	 *     abbreviations = The accepted abbreviations for the region, separated
	 *     by single spaces if there is more than one (e.g. nwy nor norw)
	 *
	 * Note there can be any number of spaces between the comma and the
	 * initial, but only one space between the initial and the abbreviations.
	 * The second section defines space adjacencies. Each line consists of
	 * either a set of adjacencies for a fleet in a space or a set of
	 * adjacencies for an army in a space in the following format:
	 *     <abbreviation>-<type of adjacency>: <adjacencies>
	 * where:
	 *    abbreviation = The accepted abbreviation, as defined in the first
	 *    section of this file, for the region whose adjacencies are being
	 *    defined.
	 *
	 *    type of adjacency = determines which type of unit is involved in
	 *    defining the adjacency where:
	 *        mv = adjacencies only for armies in that space
	 *        xc = adjacencies only for fleets in that space
	 *        nc, sc, ec, wc = adjacencies for specific coasts in bi-coastal
	 *        spaces (it's assumed that the unit involved is a fleet)
	 *        mx = adjacencies for armies moving with one less support (used in
	 *        some rule variants, for example Loeb9)
	 *
	 *    adjacencies = The accepted abbreviations, as defined in the first
	 *    section of this file, separated by single spaces, for all the regions
	 *    adjacent to the region whose adjacencies are being defined (only
	 *    considering the type of unit involved). For bi-coastal spaces, /nc,
	 *    /sc, /ec, /wc is added to the abbreviation to define specifically
	 *    which coast a fleet can move to.
	 *
	 * Note that the "-" between the abbreviation and the type of adjacency
	 * must be there, and that there is a space between the colon and the first
	 * adjacency.
	 * The last section is the supply center order for summary report. This is
	 * not used by Realpolitik.
	*/
	
	struct Space **spaces;
	int num_spaces;
	struct Adjacency **adjacencies;
	int num_adjacencies;
};

struct Space {
	char *name;
	char **abbreviations;
	int num_abbreviations;
	/* There can be more than one space type for the space */
	char *letters;
	/* Blegh. Vomit. */
	int num_letters;
};

struct Adjacency {
	/* Remember that these are the abbreviations rather than the full names */
	/* Remember that these are the abbreviations rather than the full names */
	char *region;
	char **adjacent_regions;
	int num_adjacent_regions;
	char type[2];
};

void show_map_info (struct Map *map);
void destroy_map(struct Map *map);
struct Map *init_map(const char *fpath, struct ParseError **err);
#define DEADPOTATO_MAP_FILE_PARSER_H
#endif
