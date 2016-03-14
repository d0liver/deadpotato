#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "err.h"
#include "gam-parser.h"
#include "parser-utils.h"
#define MAX_DISLODGES 200

void show_gam_info (struct Gam *gam) {
	printf(
		".gam file info\n"
		"==============\n"
		"Version: %d\n"
		"Game Name: %s\n"
		"Variant: %s\n"
		"Season: %s\n"
		"Year: %d\n"
		"Number Adjust: %d\n"
		"Num Country Infos: %d\n",
		gam->version,
		gam->game_name,
		gam->variant,
		gam->season,
		gam->year,
		gam->number_adjust,
		gam->num_country_infos
	);
}

/* RESOURCE CLEANUP */
static void destroy_country_info(struct CountryInfo *cinf) {
	int i;

	for(i = 0; i < cinf->num_supply_centers; ++i) {
		free(cinf->supply_centers[i]);
	}
	free(cinf->supply_centers);

	for (i = 0; i < cinf->num_units; ++i) {
		free(cinf->units[i]->supply_center);
		free(cinf->units[i]);
	}
	free(cinf->units);

	free(cinf);
}

static void destroy_dislodge(struct Dislodge *dislodge) {
}

void destroy_gam(struct Gam *gam) {
	int i;

	free(gam->game_name);
	free(gam->variant);
	free(gam->season);

	for (i = 0; i < gam->num_country_infos; ++i) {
		destroy_country_info(gam->country_infos[i]);
	}
	free(gam->country_infos);

	/* for (i = 0; i < gam->num_dislodges; ++i) { */
	/* 	destroy_dislodge(gam->dislodges[i]); */
	/* } */
	/* free(gam->dislodges); */
	free(gam);
}

/* PARSE HELPERS */
static struct Dislodge *next_dislodge(FILE *file, struct ParseError **err) {
	struct Dislodge *dislodge = malloc(sizeof(struct Dislodge));
	/* TODO: Implement this later. How do we know where the history starts? */

	return dislodge;
}

static void dislodges (FILE *file, struct Gam *gam, struct ParseError **err) {
	int i;
	/* Finish this out later */
	/* Will shrink later */
	gam->dislodges = malloc(sizeof(struct Dislodge *)*MAX_DISLODGES);

	for (i = 0; i < MAX_DISLODGES; ++i) {
		(gam->dislodges)[i] = next_dislodge(file, err);
		if (!gam->dislodges[i] && !err)
			break;
		else if (err)
			return;
	}
	/* Shrink cnt->countries back down to the number of countries we actually
	 * used */
	gam->dislodges = realloc(gam->dislodges, i);
	gam->num_dislodges = i;
}

static char *next_prop(FILE *file) {
	char line[256], *tmp, *res;

	tmp = fgets(line, 256, file);
	if (tmp) {
		/* -1 because we will strip off the newline */
		res = malloc(strlen(tmp)-1);
		memcpy(res, tmp, strlen(tmp)-1);

		return res;
	}

	return NULL;
}

static int season_and_year(FILE *file, char **season, int *year) {
	char line[256], *line_ptr, *tmp;

	line_ptr = fgets(line, 256, file);
	if (!tmp)
		return 1;

	*season = eat_word(&line_ptr);
	eat_whitespace(&line_ptr);
	tmp = eat_word(&line_ptr);
	*year = atoi(tmp);
	free(tmp);

	return 0;
}

struct CountryInfo *next_country_info(FILE *file, struct ParseError **cerr) {
	int i;
	char line[256], *line_ptr, *word;
	struct CountryInfo *cinf = malloc(sizeof(struct CountryInfo));
	struct ParseError *err;

	memset(cinf, 0, sizeof(struct CountryInfo));
	/* The first line is the number of adjustments */
	line_ptr = fgets(line, 256, file);
	if(line_ptr)
		cinf->adjustment = atoi(line_ptr);
	else {
		err = init_parse_error("Error parsing number of adjustments in .gam.");
		goto cleanup;
	}

	/* The second line is the supply centers */
	line_ptr = fgets(line, 256, file);
	/* We take this to mean we are finished parsing */
	if (strstr(line_ptr, "-1"))
		return NULL;
	if (!line_ptr) {
		err = init_parse_error("Error parsing supply centers in .gam.");
		goto cleanup;
	}

	cinf->supply_centers = malloc(sizeof(char *)*MAX_SUPPLY_CENTERS);

	for(i = 0; (word = eat_word(&line_ptr)) && i < MAX_SUPPLY_CENTERS; ++i) {
		cinf->supply_centers[i] = word;
		eat_whitespace(&line_ptr);
	}
	/* Shrink num of pointers to num used */
	cinf->supply_centers = realloc(cinf->supply_centers, sizeof(char *)*i);
	cinf->num_supply_centers = i;

	/* The third line is the units */
	line_ptr = fgets(line, 256, file);
	if (!line_ptr) {
		err = init_parse_error("Error parsing units in .gam file.");
		goto cleanup;
	}

	cinf->units = malloc(sizeof(struct Unit)*MAX_SUPPLY_CENTERS);

	for(i = 0; i < MAX_SUPPLY_CENTERS; ++i) {
		char *word;

		cinf->units[i] = malloc(sizeof(struct Unit));
		word = eat_word(&line_ptr);
		if(word) {
			if (strcmp(word, "A") && strcmp(word, "F")) {
				err = init_parse_error("Parsing .gam file unit with invalid type.");
				goto cleanup;
			}
			cinf->units[i]->type = *word;
		}
		else
			/* We're finished parsing units */
			break;

		eat_whitespace(&line_ptr);
		if(!(cinf->units[i]->supply_center = eat_word(&line_ptr))) {
			err = init_parse_error("Parsing .gam file found type without supply center.");
			goto cleanup;
		}
		eat_whitespace(&line_ptr);
	}
	/* Shrink num of pointers to num used */
	cinf->units = realloc(cinf->units, sizeof(struct Unit)*i);
	cinf->num_units = i;

cleanup:
	if (err && cerr)
		*cerr = err;
	if (err) {
		destroy_country_info(cinf);
		return NULL;
	}
	return cinf;
}

struct Gam *init_gam(const char *fpath, struct ParseError **cerr) {
	char line[256], *line_ptr;
	int i;
	FILE *file;
	struct Gam *gam = malloc(sizeof(struct Gam));
	struct ParseError *err = NULL;

	memset(gam, 0, sizeof(struct Gam));
	file = fopen(fpath, "rb");
	if (!file) {
		err = init_parse_error("Could not open variant file (.cnt).");
		goto cleanup;
	}
	if(!(gam->version = atoi(fgets(line, 256, file))))
	{
		err = init_parse_error("Failed to get .gam version.");
		goto cleanup;
	}
	if (!(gam->game_name = next_prop(file))) {
		err = init_parse_error("Failed to get .gam game name.");
		goto cleanup;
	}
	if(!(gam->variant = next_prop(file)))
	{
		err = init_parse_error("Failed to get .gam variant.");
		goto cleanup;
	}
	if(season_and_year(file, &gam->season, &gam->year)) {
		err = init_parse_error("Failed to get .gam season and year.");
		goto cleanup;
	}
	line_ptr = fgets(line, 256, file);
	if(line_ptr)
		gam->number_adjust = atoi(line_ptr);
	else {
		goto cleanup;
		err = init_parse_error("Failed to get .gam number_adjust.");
	}

	/* Eat the next line, supposed number of countries */
	line_ptr = fgets(line, 256, file);

	/* We will shrink this later */
	gam->country_infos = malloc(sizeof(struct CountryInfo *)*MAX_COUNTRIES);
	for (i = 0; i < MAX_COUNTRIES; ++i) {
		gam->country_infos[i] = next_country_info(file, &err);
		if (!gam->country_infos[i] && !err)
			break;
		else if (err)
			goto cleanup;
	}
	/* Shrink cnt->countries back down to the number of countries we actually
	 * used */
	gam->country_infos = realloc(gam->country_infos, sizeof(struct CountryInfo)*i);
	gam->num_country_infos = i;

cleanup:
	if (file)
		fclose(file);
	if (err && cerr)
		*cerr = err;
	if (err) {
		destroy_gam(gam);
		return NULL;
	}

	return gam;
}
