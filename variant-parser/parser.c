#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "var-parser.h"
#include "cnt-parser.h"
#include "gam-parser.h"
#include "err.h"

int main (int argc, char **argv) {
	struct Variant *variant;
	struct Cnt *cnt;
	struct Gam *gam;
	struct ParseError *err = NULL;

	if(variant = init_variant ("../variants/Middle Earth/midearth.var", &err))
		show_variant_info(variant);
	else
		goto variant_fail;

	if (cnt = init_cnt("../variants/Middle Earth/midearth.cnt", &err)) {
		printf("\n");
		show_cnt_info(cnt);
	}
	else
		goto cnt_fail;

	if (gam = init_gam("../variants/Middle Earth/midearth.gam", &err)) {
		printf("\n");
		show_gam_info(gam);
	}
	else
		goto gam_fail;

	destroy_gam(gam);
gam_fail:
	destroy_cnt(cnt);
cnt_fail:
	destroy_variant(variant);
variant_fail:
	if (err) {
		printf("\n");
		printf("Failed to initialize the variant. Reason: %s\n", err->message);
		destroy_parse_error(err);
	}
}
