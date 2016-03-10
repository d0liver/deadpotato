#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "file-parser.h"
#include "err.h"

int main (int argc, char **argv) {
	struct Variant *variant;
	struct ParseError *err;

	if(variant = init_variant ("Standard/Standard.var", &err))
		show_variant_info(variant);
	else {
		printf("Failed to initialize the variant. Reason: %s\n", err->message);
		destroy_parse_error(err);
	}
}
