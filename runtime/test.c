#include "bennu.h"
#include "int.h"
#include "setting.h"

#include <stdio.h>

int main () {
	bennu_init();
	printf("Init succeeded.\n");

	bennu_int *i = bennu_int_new(42);
	BENNU_OBJ_SEND(i, bennu_s_say);
	return 0;
}
