#include <stdlib.h>
#include <string.h>

#include "err.h"

struct ParseError *init_parse_error(char *err_msg) {
	struct ParseError *err = malloc(sizeof(struct ParseError));

	memset(err, 0, sizeof(*err));
	err->message = malloc(strlen(err_msg));
	strcpy(err->message, err_msg);
	/* This is the default. The caller can set a different code if they like. */
	err->code = UNCAUGHT;

	return err;
}

void destroy_parse_error(struct ParseError *err) {
	free(err->message);
	free(err);
}
