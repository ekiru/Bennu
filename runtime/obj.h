#ifndef BENNU_OBJ_H
#define BENNU_OBJ_H

#define BENNU_OBJ_ICACHE 1	/* nonzero to enable point-of-send inline cache */
#define BENNU_OBJ_MCACHE 1	/* nonzero to enable global method cache        */

typedef struct bennu_vtable bennu_vtable;
typedef struct bennu_object bennu_object;
typedef struct bennu_closure bennu_closure;
typedef struct bennu_symbol bennu_symbol;

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

#endif /* BENNU_OBJ_H */
