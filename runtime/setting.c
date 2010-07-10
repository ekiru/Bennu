#include "setting.h"

bennu_object *bennu_s_say;

void bennu_setting_init(void) {
	bennu_s_say = bennu_symbol_intern(0, 0, "say");
}

bennu_object *bennu_say(bennu_object *self) {
	BENNU_OBJ_SEND(self, bennu_s_say);
}
