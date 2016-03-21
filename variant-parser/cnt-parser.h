#ifndef DEADPOTATO_CNT_FILE_PARSER_H
/* This struct represents the contents of the .cnt variant file which contains
 * information about the countries in the game. */
struct Cnt {
	/* For now, this should be 1. If the file format changes in a future version of
	Realpolitik, this will be used to distinguish between the old and new formats. */
	short version;

	/* Number of Countries: This is the number of countries in the variant. */
	int num_countries;

	struct Country **countries;

	/* Note that the initial is used to pick the appropriate icon so if an icon
	 * with that initial does not exist, you'll have to create one in either
	 * the Icons file (MacOS) or the Icons folder (Win32).*/
};

/* Info about a specific country */
struct Country {

	/* The name of the country (e.g. France) */
	char *name;

	/* The country adjective (e.g. French) */
	char *adjective;

	/* The single capital initial character for that country (e.g. F) */
	char *capital_initial;

	/* The name of the pattern to be used for filling supply center regions.
	 * Available patterns are: Random, ThinDiag, Hash, Gray, Quilt, Sparse,
	 * Diag, ThinHoriz, Horiz, Vert, Stripe and Flood */
	char *pattern;

	/* The color to be used for units, orders and supply centers. Available
	 * colors are: Black, Blue, Brown, Charcoal, Crimson, Cyan, Forest, Green,
	 * Magenta, Navy, Olive, Orange, Purple, Red, Tan, Teal, White and Yellow
	 * */
	char *color;
};

void show_cnt_info (struct Cnt *cnt);
void destroy_cnt(struct Cnt *cnt);
struct Cnt *init_cnt(const char *fpath, struct ParseError **err);
json_t *cnt_json (struct Cnt *cnt);
#define DEADPOTATO_CNT_FILE_PARSER_H
#endif
