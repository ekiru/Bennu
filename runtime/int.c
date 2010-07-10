#include "int.h"

bennu_vtable *int_vtable;

struct bennu_int {
	bennu_vtable *_vt[0];
	int value;
};

void bennu_int_init(void) {

}
