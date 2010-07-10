#ifndef BENNU_OBJ_H
#define BENNU_OBJ_H

#define BENNU_OBJ_ICACHE 1	/* nonzero to enable point-of-send inline cache */
#define BENNU_OBJ_MCACHE 1	/* nonzero to enable global method cache        */

typedef struct bennu_vtable bennu_vtable;
typedef struct bennu_object bennu_object;
typedef struct bennu_closure bennu_closure;
typedef struct bennu_symbol bennu_symbol;

typedef bennu_object *(*bennu_meth_t)(bennu_closure *closure, bennu_object *receiver, ...);

struct bennu_vtable
{
  bennu_vtable  *_vt[0];
  int             size;
  int             tally;
  bennu_object **keys;
  bennu_object **values;
  bennu_vtable  *parent;
};

struct bennu_object {
  bennu_vtable *_vt[0];
};

struct bennu_closure
{
  bennu_vtable *_vt[0];
  bennu_meth_t		 method;
  bennu_object *data;
};

#if BENNU_OBJ_ICACHE
# define BENNU_OBJ_SEND(RCV, MSG, ARGS...) ({				\
      bennu_object   *r = (bennu_object *)(RCV);	\
      static bennu_vtable   *prevVT  = 0;			\
      static bennu_closure  *closure = 0;			\
      register bennu_vtable *thisVT  = r->_vt[-1];		\
      thisVT == prevVT						\
	?  closure						\
	: (prevVT  = thisVT,					\
	   closure = bennu_obj_bind(r, (MSG)));				\
      closure->method(closure, r, ##ARGS);			\
    })
#else
# define BENNU_OBJ_SEND(RCV, MSG, ARGS...) ({				\
      bennu_object  *r = (bennu_object *)(RCV);		\
      bennu_closure *c = bennu_obj_bind(r, (MSG));			\
      c->method(c, r, ##ARGS);					\
    })
#endif

void bennu_obj_init(void); /* Used to initialize the object system. */
/* Used by BENNU_OBJ_SEND. */
bennu_closure *bennu_obj_bind(bennu_object *rcv, bennu_object *msg);

/* Basic message symbols. */
extern bennu_object *bennu_s_addMethod;
extern bennu_object *bennu_s_allocate;
extern bennu_object *bennu_s_delegated;
extern bennu_object *bennu_s_lookup;

/* Core vtables. */
extern bennu_vtable *bennu_object_vtable;

#endif /* BENNU_OBJ_H */
