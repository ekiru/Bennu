#ifndef BENNU_INT_H
#define BENNU_INT_H

#include "obj.h"

typedef struct bennu_int bennu_int;

extern bennu_vtable *bennu_int_vtable;

void bennu_int_init(void);

bennu_int *bennu_int_new(int value);

#endif /* BENNU_INT_H */
