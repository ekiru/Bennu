#ifndef BENNU_OBJ_H
#define BENNU_OBJ_H

#define BENNU_OBJ_ICACHE 1	/* nonzero to enable point-of-send inline cache */
#define BENNU_OBJ_MCACHE 1	/* nonzero to enable global method cache        */

typedef struct bennu_vtable bennu_vtable;
typedef struct bennu_object bennu_object;
typedef struct bennu_closure bennu_closure;

#endif /* BENNU_OBJ_H */
