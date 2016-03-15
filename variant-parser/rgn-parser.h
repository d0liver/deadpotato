#ifndef DEADPOTATO_RGN_FILE_PARSER_H
#include "err.h"
#include "map-parser.h"

struct Rgn {
	int num_regions;
	/* We omit the number of regions and which scanlines belong to which
	 * regions because it is parallel to the information in the .map file. We
	 * will check to make sure that the number of regions is the same for our
	 * safety. */
	struct Region **regions;
};

struct Region {
	int num_scanlines;
	struct Coords *unit_pos, *name_pos;
	struct ScanLine *scanlines;
};

struct Coords {
	int x, y;
};

struct ScanLine {
	int x,y, len;
};

void show_rgn_info (struct Rgn *rgn);
void destroy_rgn(struct Rgn *rgn);
struct Rgn *init_rgn(const char *fpath, struct ParseError **err);
#define DEADPOTATO_RGN_FILE_PARSER_H
#endif
