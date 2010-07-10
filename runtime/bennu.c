#include "bennu.h"

#include "int.h"
#include "obj.h"
#include "setting.h"

void bennu_init(void) {
	bennu_obj_init();
	bennu_setting_init();

	bennu_int_init();
}
