#include <stdlib.h>
#include <string.h>
#include <stdio.h>

void eat_whitespace(char **ptr) {
	for(;**ptr == ' ' || **ptr == '\t'; ++*ptr);
}

char *eat_word(char **ptr) {
	const char *orig = *ptr;
	char *word;
	int word_len;

	/* Advance to the next whitespace */
	for (;
			**ptr != '\r' &&
			**ptr != '\n' &&
			**ptr != '\0' &&
			**ptr != ' ' &&
			**ptr != '\t';
			++*ptr
	);

	word_len = *ptr - orig;
	if (!word_len)
		return NULL;
	word = malloc(word_len);
	memcpy(word, orig, word_len+1);
	word[word_len] = '\0';

	return word;
}

char *eat_until(char **ptr, char c) {
	const char *orig = *ptr;
	char *word;
	int word_len;

	/* Advance to the next comma */
	for (; **ptr != c && **ptr != '\0'; ++*ptr);

	word_len = *ptr - orig;
	if (!word_len)
		return NULL;
	word = malloc(word_len);
	memcpy(word, orig, word_len+1);
	word[word_len] = '\0';

	return word;
}

/* Returns a pointer to the next line after the comments */
char *eat_comments(FILE *file, char *line) {
	char *line_ptr, *res;

	while((line_ptr = fgets(line, 256, file)) && *line_ptr == '#');

	/* Could be NULL */
	return line_ptr;
}
