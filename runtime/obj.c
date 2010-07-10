/* This file originates from http://piumarta.com/software/id-objmodel/ .
 *  It was initially developed by Ian Piumarta.
 */

#include "obj.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct closure;
struct symbol;

typedef bennu_object *(*imp_t)(struct closure *closure, bennu_object *receiver, ...);

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

struct closure
{
  bennu_vtable *_vt[0];
  imp_t		 method;
  bennu_object *data;
};

struct symbol
{
  bennu_vtable *_vt[0];
  char          *string;
};

bennu_vtable *SymbolList= 0;

bennu_vtable *vtable_vt;
bennu_vtable *object_vt;
bennu_vtable *symbol_vt;
bennu_vtable *closure_vt;

bennu_object *s_addMethod = 0;
bennu_object *s_allocate  = 0;
bennu_object *s_delegated = 0;
bennu_object *s_lookup    = 0;

extern inline void *alloc(size_t size)
{
  bennu_vtable **ppvt= (bennu_vtable **)calloc(1, sizeof(bennu_vtable *) + size);
  return (void *)(ppvt + 1);
}

bennu_object *symbol_new(char *string)
{
  struct symbol *symbol = (struct symbol *)alloc(sizeof(struct symbol));
  symbol->_vt[-1] = symbol_vt;
  symbol->string = strdup(string);
  return (bennu_object *)symbol;
}

bennu_object *closure_new(imp_t method, bennu_object *data)
{
  struct closure *closure = (struct closure *)alloc(sizeof(struct closure));
  closure->_vt[-1] = closure_vt;
  closure->method  = method;
  closure->data    = data;
  return (bennu_object *)closure;
}

bennu_object *vtable_lookup(struct closure *closure, bennu_vtable *self, bennu_object *key);

#if BENNU_OBJ_ICACHE
# define send(RCV, MSG, ARGS...) ({				\
      struct        object   *r = (bennu_object *)(RCV);	\
      static bennu_vtable   *prevVT  = 0;			\
      static struct closure  *closure = 0;			\
      register bennu_vtable *thisVT  = r->_vt[-1];		\
      thisVT == prevVT						\
	?  closure						\
	: (prevVT  = thisVT,					\
	   closure = bind(r, (MSG)));				\
      closure->method(closure, r, ##ARGS);			\
    })
#else
# define send(RCV, MSG, ARGS...) ({				\
      bennu_object  *r = (bennu_object *)(RCV);		\
      struct closure *c = bind(r, (MSG));			\
      c->method(c, r, ##ARGS);					\
    })
#endif

#if BENNU_OBJ_MCACHE
struct entry {
  bennu_vtable  *vtable;
  bennu_object  *selector;
  struct closure *closure;
} MethodCache[8192];
#endif

struct closure *bind(bennu_object *rcv, bennu_object *msg)
{
  struct closure *c;
  bennu_vtable  *vt = rcv->_vt[-1];
#if BENNU_OBJ_MCACHE
  struct entry   *cl = MethodCache + ((((unsigned)vt << 2) ^ ((unsigned)msg >> 3)) & ((sizeof(MethodCache) / sizeof(struct entry)) - 1));
  if (cl->vtable == vt && cl->selector == msg)
    return cl->closure;
#endif
  c = ((msg == s_lookup) && (rcv == (bennu_object *)vtable_vt))
    ? (struct closure *)vtable_lookup(0, vt, msg)
    : (struct closure *)send(vt, s_lookup, msg);
#if BENNU_OBJ_MCACHE
  cl->vtable   = vt;
  cl->selector = msg;
  cl->closure  = c;
#endif
  return c;
}

bennu_vtable *vtable_delegated(struct closure *closure, bennu_vtable *self)
{
  bennu_vtable *child= (bennu_vtable *)alloc(sizeof(bennu_vtable));
  child->_vt[-1] = self ? self->_vt[-1] : 0;
  child->size    = 2;
  child->tally   = 0;
  child->keys    = (bennu_object **)calloc(child->size, sizeof(bennu_object *));
  child->values  = (bennu_object **)calloc(child->size, sizeof(bennu_object *));
  child->parent  = self;
  return child;
}

bennu_object *vtable_allocate(struct closure *closure, bennu_vtable *self, int payloadSize)
{
  bennu_object *object = (bennu_object *)alloc(payloadSize);
  object->_vt[-1] = self;
  return object;
}

imp_t vtable_addMethod(struct closure *closure, bennu_vtable *self, bennu_object *key, imp_t method)
{
  int i;
  for (i = 0;  i < self->tally;  ++i)
    if (key == self->keys[i])
      return ((struct closure *)self->values[i])->method = method;
  if (self->tally == self->size)
    {
      self->size  *= 2;
      self->keys   = (bennu_object **)realloc(self->keys,   sizeof(bennu_object *) * self->size);
      self->values = (bennu_object **)realloc(self->values, sizeof(bennu_object *) * self->size);
    }
  self->keys  [self->tally  ] = key;
  self->values[self->tally++] = closure_new(method, 0);
  return method;
}

bennu_object *vtable_lookup(struct closure *closure, bennu_vtable *self, bennu_object *key)
{
  int i;
  for (i = 0;  i < self->tally;  ++i)
    if (key == self->keys[i])
      return self->values[i];
  if (self->parent)
    return send(self->parent, s_lookup, key);
  fprintf(stderr, "lookup failed %p %s\n", self, ((struct symbol *)key)->string);
  return 0;
}

bennu_object *symbol_intern(struct closure *closure, bennu_object *self, char *string)
{
  bennu_object *symbol;
  int i;
  for (i = 0;  i < SymbolList->tally;  ++i)
    {
      symbol = SymbolList->keys[i];
      if (!strcmp(string, ((struct symbol *)symbol)->string))
	return symbol;
    }
  symbol = symbol_new(string);
  vtable_addMethod(0, SymbolList, symbol, 0);
  return symbol;
}

void init(void)
{
  vtable_vt = vtable_delegated(0, 0);
  vtable_vt->_vt[-1] = vtable_vt;

  object_vt = vtable_delegated(0, 0);
  object_vt->_vt[-1] = vtable_vt;
  vtable_vt->parent = object_vt;

  symbol_vt  = vtable_delegated(0, object_vt);
  closure_vt = vtable_delegated(0, object_vt);

  SymbolList = vtable_delegated(0, 0);

  s_lookup    = symbol_intern(0, 0, "lookup");
  s_addMethod = symbol_intern(0, 0, "addMethod");
  s_allocate  = symbol_intern(0, 0, "allocate");
  s_delegated = symbol_intern(0, 0, "delegated");

  vtable_addMethod(0, vtable_vt, s_lookup,    (imp_t)vtable_lookup);
  vtable_addMethod(0, vtable_vt, s_addMethod, (imp_t)vtable_addMethod);

  send(vtable_vt, s_addMethod, s_allocate,    vtable_allocate);
  send(vtable_vt, s_addMethod, s_delegated,   vtable_delegated);
}
