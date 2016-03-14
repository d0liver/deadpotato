#ifndef DEADPOTATO_PARSER_UTILS_H
char *eat_word(char **ptr);
char *eat_until(char **ptr, char c);
void eat_whitespace(char **ptr);
/* Note that MAX_COUNTRIES needs to be a reasonable size because that number of
 * elements will be allocated before being shrunk (once the actual needed # of
 * countries is found). */
#define MAX_COUNTRIES 20
#define MAX_SUPPLY_CENTERS 500
#define DEADPOTATO_PARSER_UTILS_H
#endif
