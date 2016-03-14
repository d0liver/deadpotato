#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "var-parser.h"

static char *next_prop(FILE *file) {
	char line[256], *res, *tmp;

	tmp = fgets(line, 256, file);
	if (tmp) {
		/* Advance tmp to after the property name (They go in order so we
		 * already know what they will be). */
		for (;*tmp != ':' && *tmp != '\0' && *tmp != '\n'; ++tmp);
		++tmp;
		/* Eat any whitespace in front of the property name also */
		for (;*tmp == ' ' || *tmp == '\t'; ++tmp);
		/* Go ahead and strip the newline character off. */
		tmp[strlen(tmp)-2] = '\0';
		res = malloc(strlen(tmp));
		strcpy(res, tmp);
		return res;
	}

	return NULL;
}

void destroy_variant (struct Variant *variant) {
	free(variant->name);
	free(variant->map_file);
	free(variant->countries);
	free(variant->game);
	free(variant->bWMap);
	free(variant->colorMap);
	free(variant->regions);
	free(variant->info);
	free(variant->build);
	free(variant->centers);
	free(variant->flags);
	free(variant);
}

struct Variant *init_variant (const char *fpath, struct ParseError **err) {
	FILE *file;
	struct Variant *variant = malloc(sizeof(struct Variant));
	char *err_msg = NULL;

	memset(variant, 0, sizeof(struct Variant));
	if (err)
		*err = NULL;
	file = fopen(fpath, "rb");
	if (!file) {
		err_msg = "Could not open variant file (.var).";
		goto cleanup;
	}
	if (
		!(variant->version = atoi(next_prop(file))) ||
		!(variant->name = next_prop(file)) ||
		!(variant->map_file = next_prop(file)) ||
		!(variant->countries = next_prop(file)) ||
		!(variant->game = next_prop(file)) ||
		!(variant->bWMap = next_prop(file)) ||
		!(variant->colorMap = next_prop(file)) ||
		!(variant->regions = next_prop(file)) ||
		!(variant->info = next_prop(file)) ||
		!(variant->build = next_prop(file)) ||
		!(variant->centers = next_prop(file)) ||
		!(variant->flags = next_prop(file))
	) {
		err_msg = "There was an error within the .var file.";
		goto cleanup;
	}

cleanup:
	if (file)
		fclose(file);
	if (err_msg) {
		destroy_variant(variant);
		if (err)
			*err = init_parse_error(err_msg);
		return NULL;
	}
	return variant;
}

void show_variant_info (struct Variant *variant) {
	printf(
		".var file info\n"
		"==============\n"
		"Version: %d\n"
		"Name: %s\n"
		"Map_file: %s\n"
		"Countries: %s\n"
		"Game: %s\n"
		"BWMap: %s\n"
		"ColorMap: %s\n"
		"Regions: %s\n"
		"Info: %s\n"
		"Build: %s\n"
		"Centers: %s\n"
		"Flags: %s\n",
		variant->version,
		variant->name,
		variant->map_file,
		variant->countries,
		variant->game,
		variant->bWMap,
		variant->colorMap,
		variant->regions,
		variant->info,
		variant->build,
		variant->centers,
		variant->flags
	);
}
