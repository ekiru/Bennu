#include "int.h"
#include "setting.h"

#include <stdio.h>
#include <stdlib.h>

bennu_vtable *bennu_int_vtable;

struct bennu_int {
	bennu_vtable *_vt[0];
	int value;
};

bennu_int *bennu_int_new(int value) {
	bennu_int *result = (bennu_int *)bennu_obj_alloc(sizeof (*result));
	if (result != NULL) {
		result->_vt[-1] = bennu_int_vtable;
		result->value = value;
	}
	return result;
}

bennu_object *bennu_int_say(bennu_closure *closure, bennu_object *self) {
	printf("%d\n", ((bennu_int *)self)->value);
	return self;
}

void bennu_int_init(void) {
	bennu_int_vtable = (bennu_vtable *)BENNU_OBJ_SEND(bennu_object_vtable,
	                                                  bennu_s_delegated);
	BENNU_OBJ_SEND(bennu_int_vtable, bennu_s_addMethod,
	               bennu_s_say, bennu_int_say);
}
