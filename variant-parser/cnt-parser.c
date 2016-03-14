#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "err.h"
#include "cnt-parser.h"
#include "parser-utils.h"

void show_cnt_info (struct Cnt *cnt) {
	int i;

	printf(
		".cnt File Info\n"
		"==============\n"
		"Version: %d\n"
		"Num Countries: %d\n",
		cnt->version,
		cnt->num_countries
	);

	for (i = 0; i < cnt->num_countries; ++i)
		printf(
			"-------------\n"
			"Name: %s\n"
			"Adjective: %s\n"
			"Capital Initial: %s\n"
			"Pattern: %s\n"
			"Color: %s\n",
			cnt->countries[i]->name,
			cnt->countries[i]->adjective,
			cnt->countries[i]->capital_initial,
			cnt->countries[i]->pattern,
			cnt->countries[i]->color
		);
}

static void destroy_country(struct Country *country) {
	free(country->name);
	free(country->adjective);
	free(country->capital_initial);
	free(country->pattern);
	free(country->color);
}

void destroy_cnt(struct Cnt *cnt) {
	int i;

	for (i = 0; i < cnt->num_countries; ++i)
		destroy_country(cnt->countries[i]);

	free(cnt->countries);
}

static struct Country *next_country(FILE *file, struct ParseError **err) {
	struct Country *country = malloc(sizeof(struct Country));
	char line[256], *line_ptr;
	line_ptr = fgets(line, 256, file);

	/* We allow the caller to use us to determine when there are no more
	 * countries to parse so we don't throw an error in this case. */
	if (!line_ptr)
		return NULL;

	eat_whitespace(&line_ptr);
	country->name = eat_word(&line_ptr);

	eat_whitespace(&line_ptr);
	country->adjective = eat_word(&line_ptr);

	eat_whitespace(&line_ptr);
	country->capital_initial = eat_word(&line_ptr);

	eat_whitespace(&line_ptr);
	country->pattern = eat_word(&line_ptr);

	eat_whitespace(&line_ptr);
	country->color = eat_word(&line_ptr);

	return country;
}

struct Cnt *init_cnt(const char *fpath, struct ParseError **cerr) {
	char line[256];
	int i;
	unsigned int alloced = 4;
	FILE *file;
	struct Cnt *cnt = malloc(sizeof(struct Cnt));
	struct ParseError *err = NULL;
	struct Country *countries = malloc(sizeof(struct Country)*MAX_COUNTRIES);

	memset(cnt, 0, sizeof(struct Cnt));
	file = fopen(fpath, "rb");
	if (!file) {
		err = init_parse_error("Could not open variant file (.cnt).");
		goto cleanup;
	}
	if(!(cnt->version = atoi(fgets(line, 256, file))))
	{
		err = init_parse_error("Failed to get .cnt version.");
		goto cleanup;
	}
	/* The next line is the "number of countries" line. We can't trust it so
	 * we'll throw it away */
	fgets(line, 256, file);

	cnt->countries = malloc(sizeof(struct Country *)*alloced);
	/* Load in all of the countries */
	for(i = 0; i < MAX_COUNTRIES; ++i) {
		if (alloced < i) {
			alloced = (i + 3) & ~3;
			cnt->countries =
				realloc(cnt->countries, sizeof(struct Country *)*alloced);
		}
		cnt->countries[i] = next_country(file, &err);
		if (!cnt->countries[i] && !err)
			break;
		else if (err)
			goto cleanup;
	}
	cnt->num_countries = i;

cleanup:
	if (file)
		fclose(file);
	if (err && cerr)
		*cerr = err;
	if (err) {
		destroy_cnt(cnt);
		return NULL;
	}

	return cnt;
}
