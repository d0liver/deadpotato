struct Gam {
	/* For now this should be 1. If the file format changes in a future version of
	Realpolitik, this will be used to distinguish between the old and new formats. */
	int version;

	/* What you type here is what will appear in the title bar for the map
	window. This will also be the default name for any saved game file of the
	variant. However, you can override the default by naming the game file
	something else in the "save dialog". Whenever the game is opened after that
	point, the new file name will appear in the title bar for the map window. Note
	that renaming the file on your computer's desktop will not affect the name in
	the title bar. */
	char *game_name;

	/* This is the variant's name. This must match exactly the name of the variant
	 * as listed in the .var file. */
	char *variant;

	/* Season and year of the game's first turn */
	char *season;

	int year;

	/* The number of adjustments expected. In general this should only be 0 except in
	a Winter phase. It equals the total number of builds and removals expected for
	all countries. This can be used in variants where the first action of the game
	is to build units. */
	int number_adjust;

	int num_country_infos;

	/* There should be one group of these per country. The groups need to be listed
	 * in the same order as the countries in the Variant.cnt file. */
	struct CountryInfo **country_infos;

	/* The total number of dislodged units. For a new variant, this should be
	 * 0, unless you want to handle dislodges as the first move of the game. */
	int num_dislodges;

	/* See Dislogde */
	struct Dislodge **dislodges;

	/* History is omitted here */
};

struct Dislodge {
	/*
	 * In a new variant, there are generally no dislodges. However, if there
	 * are dislodges, there should be a string of the following format per
	 * dislodge.
	 * <country name> <unitID> <spaceID> [<coast>] <retreatspaces>
	 */
	int coast;
	char *country_name;
	/* UnitID is 'A' or 'F' (for Army or Fleet) */
	char unit_id;
	char *space_id;
	/* 3 character space ids for spaces the unit can retreat to */
	char **retreatspaces;
};

struct CountryInfo {
	/* This gives the number of builds/removals. It should be positive for
	 * builds and negative for removals. This is used in saved games and in
	 * variants where the first action of the game is to build or remove units
	 * (see Chaos for an example of the latter). */
	int adjustment;

	/* This is a series of 3-character space abbreviations, separated by spaces
	 * and representing the supply centers owned by this country at the
	 * beginning of the game. */
	int num_supply_centers;
	char **supply_centers;

	/* This is a series of unit types and space abbreviations, separated by
	 * spaces. It represents the units owned by this country and the provinces
	 * they start in at the beginning of the game. */
	int num_units;
	struct Unit **units;
};

struct Unit {
	char *supply_center;
	char type;
};

void show_gam_info();
void destroy_gam(struct Gam *gam);
struct Gam *init_gam(const char *fpath, struct ParseError **err);
