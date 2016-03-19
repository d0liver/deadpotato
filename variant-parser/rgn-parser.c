#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <jansson.h>

#include "parser-utils.h"
#include "err.h"
#include "rgn-parser.h"

void show_rgn_info (struct Rgn *rgn) {
	int i, j;

	printf(
		".rgn file info\n"
		"==============\n"
	);
	for (i = 0; i < rgn->num_regions; ++i)
		for (j = 0; j < rgn->regions[i]->num_scanlines; ++j)
			printf(
				"Scanline x, y, len: %d, %d, %d\n",
				rgn->regions[i]->scanlines[j].x,
				rgn->regions[i]->scanlines[j].y,
				rgn->regions[i]->scanlines[j].len
			);
}

json_t *rgn_json(struct Rgn *rgn, struct Map *map) {
	int i, j;
	json_t *res = json_object();

	for (i = 0; i < rgn->num_regions; ++i) {
		json_t *region_scanlines = json_array();
		/* Each regions scanlines will be stored under the region's name */
		char *rgn_name = map->spaces[i]->name;
		for (j = 0; j < rgn->regions[i]->num_scanlines; ++j) {
			json_t *scanline;
			scanline = json_pack(
				"{s:i, s:i, s:i}",
				"x", rgn->regions[i]->scanlines[j].x,
				"y", rgn->regions[i]->scanlines[j].y,
				"len", rgn->regions[i]->scanlines[j].len
			);
			json_array_append_new(region_scanlines, scanline);
		}
		json_object_set_new(res, rgn_name, region_scanlines);
	}

	/* All of the references were stolen so there is nothing to cleanup here */
	return res;
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

struct Coords *next_position(char *line_ptr, struct ParseError **cerr) {
	char line[256], *word;
	struct Coords *coords = malloc(sizeof(struct Coords));
	struct ParseError *err = NULL;

	if (!line_ptr) {
		err = init_parse_error("Failed to parse position in .rgn file.");
		goto cleanup;
	}

	/* Grab the first coord */
	word = eat_until(&line_ptr, ',');
	if (!word) {
		err = init_parse_error("Failed to parse position in .rgn file.");
		goto cleanup;
	}
	coords->x = atoi(word);

	/* Grab the second coord */
	word = eat_word(&line_ptr);
	if (!word) {
		err = init_parse_error("Failed to parse position in .rgn file.");
		goto cleanup;
	}
	/* Move past the comma */
	++line_ptr;
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
	struct ParseError *err = NULL;
	struct Region *region = malloc(sizeof(struct Region));

	memset(region, 0, sizeof(*region));
	/* Get unit pos */
	line_ptr = eat_comments(file, line);
	if (!line_ptr)
		/* EOF, finished parsing */
		return NULL;
	if (!(region->unit_pos = next_position(line_ptr, &err)))
		goto cleanup;

	/* Get name pos */
	line_ptr = eat_comments(file, line);
	if (!(region->name_pos = next_position(line_ptr, &err)))
		goto cleanup;

	/* Get num scanlines */
	line_ptr = eat_comments(file, line);
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

		eat_whitespace(&line_ptr);
		word = eat_word(&line_ptr);
		if (!word) {
			err = init_parse_error("Improperly formatted scanline in .rgn.");
			goto cleanup;
		}
		region->scanlines[i].y = atoi(word);

		eat_whitespace(&line_ptr);
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
		err = init_parse_error("Could not open variant file (.rgn).");
		goto cleanup;
	}
	/* Trash the first line of the file. It's the file path */
	fgets(line, 256, file);
	/* We will shrink this once we're finished */
	rgn->regions = malloc(sizeof(struct Region *)*MAX_SUPPLY_CENTERS);
	for (i = 0; i < MAX_SUPPLY_CENTERS; ++i) {
		rgn->regions[i] = next_region(file, &err);
		if (!rgn->regions[i] && !err)
			break;
		else if (err)
			goto cleanup;
	}
	rgn->regions = realloc(rgn->regions, sizeof(struct Region *)*i);
	rgn->num_regions = i;
	printf("NUM REGIONS: %d\n", rgn->num_regions);

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
