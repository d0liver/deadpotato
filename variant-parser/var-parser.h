#ifndef DEADPOTATO_VARIANT_FILE_PARSER_H
#include "err.h"

struct Variant {
	/* This should be 0. It will be used for future variant extensions. */
	short version;

	/* The name of the variant. This is used by Realpolitik as the name displayed
	 * for the variant in the "Variants" menu.*/
	char *name;

	/* This tells Realpolitik which Variant.map file is the one to use for this
	 * variant. */
	char *map_file;

	/* This tells Realpolitik which Variant.cnt file is the one to use for this
	 * variant. */
	char *countries;

	/*  This tells Realpolitik which Variant.gam file is the one to use for this
	 *  variant. */
	char *game;

	/*  This tells Realpolitik which VariantBW.{pct,bmp} file is the one to use
	 *  for this variant. Do not include the file extension (.pct, .pic, or
	 *  .bmp) in this file name. Realpolitik will append the appropriate one
	 *  for the operating system. */
	char *bWMap;

	/*  This tells Realpolitik which Variant.{pct,bmp} file is the one to use
	 *  for this variant. Do not include the file extension (.pct, .pic, or
	 *  .bmp) in this file name. Realpolitik will append the appropriate one
	 *  for the operating system. */
	char *colorMap;

	/*  This tells Realpolitik which Variant.rgn file is the one to use for this
	 *  variant. */
	char *regions;

	/*  This tells Realpolitik which Variant.txt file is the one to use for this
	 *  variant. */
	char *info;

	/*
	 * This tells Realpolitik which build rule to use for this variant. It can
	 * be one of three options:

	 * Standard - a player may only build on her vacant home centers

	 * Aberration - a player may build on any supply center he owns which is
	 * vacant as long as he still owns at least one of his original home centers

	 * Chaos - a player may build on any supply center that she owns that is
	 * vacant
	 */
	char *build;

	/*  This is an integer that tells Realpolitik how many supply centers are
	 *  needed to win the game for the variant. If this is 0, then the number of
	 *  supply centers needed to win is assumed to be a simple majority. This is
	 *  calculated by taking the total number of supply centers, divided by two,
	 *  rounded down, plus one. So for a variant with 35 supply centers: 35 divided
	 *  by 2 is 17.5, rounded down is 17, plus one is 18. */
	char *centers;

	/*  This should be 0. It will be used for future variant extensions. */
	char *flags;
};

void destroy_variant (struct Variant *variant);
void show_variant_info (struct Variant *variant);
struct Variant *init_variant (const char *fpath, struct ParseError **err);
#define DEADPOTATO_VARIANT_FILE_PARSER_H
#endif
