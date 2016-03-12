#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "var-parser.h"
#include "cnt-parser.h"
#include "err.h"

int main (int argc, char **argv) {
	struct Variant *variant;
	struct Cnt *cnt;
	struct ParseError *err = NULL;

	if(variant = init_variant ("../variants/Colonial/Colonial.var", &err))
		show_variant_info(variant);
	else
		goto cleanup;

	if (cnt = init_cnt("../variants/Colonial/Colonial.cnt", &err)) {
		printf("\n");
		show_cnt_info(cnt);
	}
	else
		goto cleanup;

cleanup:
	if (err) {
		printf("\n");
		printf("Failed to initialize the variant. Reason: %s\n", err->message);
		printf("Code: %d\n", err->code);
		destroy_parse_error(err);
	}
}
