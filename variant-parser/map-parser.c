#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "map-parser.h"
#include "parser-utils.h"

/* Resource management stuff */

static void destroy_space(struct Space *space) {
	int i;

	free(space->name);
	for (i = 0; i < space->num_abbreviations; ++i)
		free(space->abbreviations[i]);
	free(space->abbreviations);

	free(space->letters);

	free(space);
}

static void destroy_adjacency(struct Adjacency *adj) {
	int i;

	free(adj->region);

	for (i = 0; i < adj->num_adjacent_regions; ++i)
		free(adj->adjacent_regions[i]);
	free(adj->adjacent_regions);

	free(adj);
}

void destroy_map(struct Map *map) {
	int i;

	for (i = 0; i < map->num_spaces; ++i)
		destroy_space(map->spaces[i]);
	free(map->spaces);

	for (i = 0; i < map->num_adjacencies; ++i)
		destroy_adjacency(map->adjacencies[i]);
	free(map->adjacencies);

	free(map);
}

/* Show info stuff */

static char *space_type(struct Space *space, char letter) {
	switch(letter) {
		case 'l':
			return "land";
			break;
		case 'w':
			return "water";
			break;
		case 'x':
			return "neutral supply center";
			break;
		case 'v':
			return "ice";
			break;
		default:
			return "capital";
			break;
	}
}

void show_map_info(struct Map *map) {
	int i, j;

	printf(
		".map file info\n"
		"==============\n"
	);
	for (i = 0; i < map->num_spaces; ++i) {
		struct Space *space = map->spaces[i];
		printf("Space Name: %s\n", space->name);
		for (j = 0; j < space->num_letters; ++j)
			printf("Space Type: %s\n", space_type(space, space->letters[j]));
		for (j = 0; j < space->num_abbreviations; ++j)
			printf("\tAbbreviation: %s\n", space->abbreviations[j]);
	}

	for (i = 0; i < map->num_adjacencies; ++i) {
		struct Adjacency *adjacency = map->adjacencies[i];
		printf("Adjacency region: %s\n", adjacency->region);
		printf("Adjacency type: %s\n", adjacency->type);
		for (j = 0; j < adjacency->num_adjacent_regions; ++j)
			printf("\tAdjacent to: %s\n", adjacency->adjacent_regions[j]);
	}
}

/* Parser stuff */
static struct Space *next_space(FILE *file, struct ParseError **cerr) {
	int i;
	struct ParseError *err = NULL;
	struct Space *space = malloc(sizeof(struct Space));
	char line[256], *line_ptr, *word;

	memset(space, 0, sizeof(*space));
	line_ptr = fgets(line, 256, file);
	/* This is the end of the spaces section */
	if (strstr(line_ptr, "-1") == line_ptr)
		return NULL;

	/* Get the <name> */
	eat_whitespace(&line_ptr);
	word = eat_until(&line_ptr, ',');
	if (!word) {
		err = init_parse_error("Error parsing space name in .map file.");
		goto cleanup;
	}
	space->name = malloc(strlen(word));
	strcpy(space->name, word);

	/* Get the <letter(s)> */
	/* Eat the comma */
	++line_ptr;
	eat_whitespace(&line_ptr);
	word = eat_word(&line_ptr);
	if (!word) {
		err = init_parse_error("Error parsing space type in .map file.");
		goto cleanup;
	}
	space->letters = malloc(strlen(word));
	space->num_letters = strlen(word);
	strcpy(space->letters, word);

	/* Get the abbreviations */
	eat_whitespace(&line_ptr);
	/* Shrink this after we know how many abbreviations there are */
	space->abbreviations = malloc(sizeof(char *)*MAX_SUPPLY_CENTERS);
	for (i = 0; word = eat_word(&line_ptr); ++i) {
		space->abbreviations[i] = word;
		eat_whitespace(&line_ptr);
	}
	space->abbreviations = realloc(space->abbreviations, sizeof(char *)*i);
	space->num_abbreviations = i;

cleanup:
	if (err && cerr)
		*cerr = err;
	if (err) {
		destroy_space(space);
		return NULL;
	}
	return space;
}

static struct Adjacency *next_adjacency(FILE *file, struct ParseError **cerr) {
	int i;
	struct ParseError *err = NULL;
	struct Adjacency *adjacency = malloc(sizeof(struct Adjacency));
	char line[256], *line_ptr, *word;

	memset(adjacency, 0, sizeof(*adjacency));
	line_ptr = fgets(line, 256, file);
	/* This is the end of the adjacencies section */
	if (strstr(line_ptr, "-1") == line_ptr)
		return NULL;

	/* Get the <abbreviation> */
	eat_whitespace(&line_ptr);
	word = eat_until(&line_ptr, '-');
	if (!word) {
		err = init_parse_error("Error parsing adjacency region in .map file.");
		goto cleanup;
	}
	adjacency->region = malloc(strlen(word));
	strcpy(adjacency->region, word);

	/* Get the <type of adjacency> */
	/* Advance past the hyphen */
	++line_ptr;
	word = eat_word(&line_ptr);
	if (!word) {
		err = init_parse_error("Error parsing adjacency type in .map file.");
		goto cleanup;
	}
	strncpy(adjacency->type, word, sizeof(adjacency->type));

	/* Get the <adjacencies> */
	/* Eat the ':' */
	++line_ptr;
	eat_whitespace(&line_ptr);
	/* Shrink this after we know how many adjacent regions there are */
	adjacency->adjacent_regions = malloc(sizeof(char *)*MAX_SUPPLY_CENTERS);
	for (i = 0; word = eat_word(&line_ptr); ++i) {
		adjacency->adjacent_regions[i] = word;
		eat_whitespace(&line_ptr);
	}
	adjacency->adjacent_regions =
		realloc(adjacency->adjacent_regions, sizeof(char *)*i);
	adjacency->num_adjacent_regions = i;

cleanup:
	if (err && cerr)
		*cerr = err;
	if (err) {
		destroy_adjacency(adjacency);
		return NULL;
	}
	return adjacency;
}

struct Map *init_map(const char *fpath, struct ParseError **cerr) {
	int i;
	char line[256];
	FILE *file;
	struct Map *map = malloc(sizeof(struct Map));
	struct ParseError *err = NULL;

	memset(map, 0, sizeof(struct Map));
	file = fopen(fpath, "rb");
	if (!file) {
		err = init_parse_error("Could not open variant file (.map).");
		goto cleanup;
	}

	/* We will shrink this down after */
	map->spaces = malloc(sizeof(struct Space)*MAX_SUPPLY_CENTERS);
	for (i = 0; i < MAX_SUPPLY_CENTERS; ++i) {
		map->spaces[i] = next_space(file, &err);
		if (!map->spaces[i] && !err)
			break;
		else if (err)
			goto cleanup;
	}
	map->spaces = realloc(map->spaces, sizeof(struct Space)*i);
	map->num_spaces = i;

	/* We will shrink this down after */
	map->adjacencies = malloc(sizeof(struct Adjacency)*MAX_SUPPLY_CENTERS);
	for (i = 0; i < MAX_SUPPLY_CENTERS; ++i) {
		map->adjacencies[i] = next_adjacency(file, &err);
		if (!map->adjacencies[i] && !err)
			break;
		else if (err)
			goto cleanup;
	}
	map->adjacencies = realloc(map->adjacencies, sizeof(struct Space)*i);
	map->num_adjacencies = i;

cleanup:
	if (file)
		fclose(file);
	if (err && cerr)
		*cerr = err;
	if (err) {
		destroy_map(map);
		return NULL;
	}

	return map;

}
