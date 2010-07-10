#ifndef BENNU_SETTING_H
#define BENNU_SETTING_H

#include "obj.h"

extern bennu_object *bennu_s_say;

void bennu_setting_init(void);

bennu_object *bennu_say(bennu_object *self);

#endif /* BENNU_SETTING_H */
