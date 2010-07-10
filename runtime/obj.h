#ifndef BENNU_OBJ_H
#define BENNU_OBJ_H

#define BENNU_OBJ_ICACHE 1	/* nonzero to enable point-of-send inline cache */
#define BENNU_OBJ_MCACHE 1	/* nonzero to enable global method cache        */

typedef struct bennu_vtable bennu_vtable;
typedef struct bennu_object bennu_object;
typedef struct bennu_closure bennu_closure;
typedef struct bennu_symbol bennu_symbol;

typedef bennu_object *(*bennu_meth_t)(bennu_closure *closure, bennu_object *receiver, ...);

#if BENNU_OBJ_ICACHE
# define BENNU_OBJ_SEND(RCV, MSG, ARGS...) ({				\
      struct        object   *r = (bennu_object *)(RCV);	\
      static bennu_vtable   *prevVT  = 0;			\
      static bennu_closure  *closure = 0;			\
      register bennu_vtable *thisVT  = r->_vt[-1];		\
      thisVT == prevVT						\
	?  closure						\
	: (prevVT  = thisVT,					\
	   closure = bind(r, (MSG)));				\
      closure->method(closure, r, ##ARGS);			\
    })
#else
# define BENNU_OBJ_SEND(RCV, MSG, ARGS...) ({				\
      bennu_object  *r = (bennu_object *)(RCV);		\
      bennu_closure *c = bind(r, (MSG));			\
      c->method(c, r, ##ARGS);					\
    })
#endif

void bennu_obj_init(void); /* Used to initialize the object system. */

/* Basic message symbols. */
bennu_object *bennu_s_addMethod = 0;
bennu_object *bennu_s_allocate  = 0;
bennu_object *bennu_s_delegated = 0;
bennu_object *bennu_s_lookup    = 0;

#endif /* BENNU_OBJ_H */
