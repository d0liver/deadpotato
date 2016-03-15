#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "parser-utils.h"
#include "err.h"
#include "rgn-parser.h"

void show_rgn_info (struct Rgn *rgn) {
	int i, j;

	for (i = 0; i < rgn->num_regions; ++i)
		for (j = 0; j < rgn->regions[i]->num_scanlines; ++j)
			printf(
				"Scanline x, y, len: %d, %d, %d",
				rgn->regions[i]->scanlines[j].x,
				rgn->regions[i]->scanlines[j].y,
				rgn->regions[i]->scanlines[j].len
			);
}

void destroy_region(struct Region *region) {
	int i;

	free(region->unit_pos);
	free(region->name_pos);
	free(region->scanlines);
	free(region);
}

void destroy_rgn(struct Rgn *rgn) {
	int i, j;

	for (i = 0; i < rgn->num_regions; ++i)
		destroy_region(rgn->regions[i]);
	free(rgn);
}

struct Coords *next_position(FILE *file, struct ParseError **cerr) {
	char line[256], *line_ptr, *word;
	struct Coords *coords = malloc(sizeof(struct Coords));
	struct ParseError *err;

	line_ptr = fgets(line, 256, file);
	if (!line_ptr) {
		err = init_parse_error("Failed to parse position in .gam file.");
		goto cleanup;
	}

	/* Grab the first coord */
	word = eat_until(&line_ptr, ',');
	if (!word) {
		err = init_parse_error("Failed to parse position in .gam file.");
		goto cleanup;
	}
	coords->x = atoi(word);

	/* Grab the second coord */
	word = eat_word(&line_ptr);
	if (!word) {
		err = init_parse_error("Failed to parse position in .gam file.");
		goto cleanup;
	}
	coords->y = atoi(word);

cleanup:
	if (err && cerr)
		*cerr = err;
	if (err) {
		free(coords);
		return NULL;
	}
	return coords;
}

struct Region *next_region(FILE *file, struct ParseError **cerr) {
	int i;
	char line[256], *line_ptr, *word;
	struct ParseError *err;
	struct Region *region = malloc(sizeof(struct Region));

	memset(region, 0, sizeof(*region));
	/* Get unit pos */
	eat_comments(file);
	if (!(region->unit_pos = next_position(file, &err)))
		goto cleanup;

	/* Get name pos */
	eat_comments(file);
	if (!(region->name_pos = next_position(file, &err)))
		goto cleanup;

	/* Get num scanlines */
	eat_comments(file);
	word = eat_word(&line_ptr);
	if (!word) {
		err = init_parse_error("Failed to parse # of scan lines in .rgn file.");
		goto cleanup;
	}
	region->num_scanlines = atoi(word);
	if (region->num_scanlines > MAX_SCANLINES) {
		err = init_parse_error("Too many scanlines in .rgn file.");
		goto cleanup;
	}

	/* Get the scanlines */
	region->scanlines = malloc(sizeof(struct ScanLine)*region->num_scanlines);
	for (i = 0; i < region->num_scanlines; ++i) {
		line_ptr = fgets(line, 256, file);
		if(!line_ptr) {
			err = init_parse_error(
				"Incorrect number of scan lines given in .rgn file."
			);
			goto cleanup;
		}

		word = eat_word(&line_ptr);
		if (!word) {
			err = init_parse_error("Improperly formatted scanline in .rgn.");
			goto cleanup;
		}
		region->scanlines[i].x = atoi(word);

		word = eat_word(&line_ptr);
		if (!word) {
			err = init_parse_error("Improperly formatted scanline in .rgn.");
			goto cleanup;
		}
		region->scanlines[i].y = atoi(word);

		word = eat_word(&line_ptr);
		if (!word) {
			err = init_parse_error("Improperly formatted scanline in .rgn.");
			goto cleanup;
		}
		region->scanlines[i].len = atoi(word);
	}

cleanup:
	if (err && cerr)
		*cerr = err;
	if (err) {
		destroy_region(region);
		return NULL;
	}
	return region;
}

struct Rgn *init_rgn(const char *fpath, struct ParseError **cerr) {
	int i;
	char line[256], *line_ptr;
	FILE *file;
	struct Rgn *rgn = malloc(sizeof(struct Rgn));
	struct ParseError *err = NULL;

	memset(rgn, 0, sizeof(struct Rgn));
	file = fopen(fpath, "rb");
	if (!file) {
		err = init_parse_error("Could not open variant file (.gam).");
		goto cleanup;
	}
	/* Trash the first line of the file. It's the file path */
	fgets(line, 256, file);
	/* We will shrink this once we're finished */
	rgn->regions = malloc(sizeof(struct Region *)*MAX_SUPPLY_CENTERS);
	for (i = 0; i < MAX_SUPPLY_CENTERS; ++i) {
		rgn->regions[i] = next_region(file, &err);
		if (!rgn->regions && !err)
			break;
		else if (err)
			goto cleanup;
	}
	rgn->regions = realloc(rgn->regions, sizeof(struct Region *)*i);
	rgn->num_regions = i;

cleanup:
	if (file)
		fclose(file);
	if (err && cerr)
		*cerr = err;
	if (err) {
		destroy_rgn(rgn);
		return NULL;
	}

	return rgn;

}
