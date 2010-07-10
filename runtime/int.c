#include "int.h"

bennu_vtable *bennu_int_vtable;

struct bennu_int {
	bennu_vtable *_vt[0];
	int value;
};

void bennu_int_init(void) {
	bennu_int_vtable = (bennu_vtable *)BENNU_OBJ_SEND(bennu_object_vtable,
	                                                  bennu_s_delegated);
}
