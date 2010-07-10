#include "bennu.h"

#include "int.h"
#include "obj.h"

void bennu_init(void) {
	bennu_obj_init();
	bennu_int_init();
}
