/* This file originates from http://piumarta.com/software/id-objmodel/ .
 *  It was initially developed by Ian Piumarta.
 */

#include "obj.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

bennu_object *bennu_s_addMethod = 0;
bennu_object *bennu_s_allocate = 0;
bennu_object *bennu_s_delegated = 0;
bennu_object *bennu_s_lookup = 0;

struct bennu_symbol
{
  bennu_vtable *_vt[0];
  char          *string;
};

bennu_vtable *SymbolList= 0;

bennu_vtable *bennu_object_vtable;
bennu_vtable *vtable_vt;
bennu_vtable *symbol_vt;
bennu_vtable *closure_vt;

void *bennu_obj_alloc(size_t size)
{
  bennu_vtable **ppvt= (bennu_vtable **)calloc(1, sizeof(bennu_vtable *) + size);
  return (void *)(ppvt + 1);
}

bennu_object *symbol_new(char *string)
{
  bennu_symbol *symbol = (bennu_symbol *)bennu_obj_alloc(sizeof(bennu_symbol));
  symbol->_vt[-1] = symbol_vt;
  symbol->string = strdup(string);
  return (bennu_object *)symbol;
}

bennu_object *closure_new(bennu_meth_t method, bennu_object *data)
{
  bennu_closure *closure = (bennu_closure *)bennu_obj_alloc(sizeof(bennu_closure));
  closure->_vt[-1] = closure_vt;
  closure->method  = method;
  closure->data    = data;
  return (bennu_object *)closure;
}

bennu_object *vtable_lookup(bennu_closure *closure, bennu_vtable *self, bennu_object *key);

#if BENNU_OBJ_MCACHE
struct entry {
  bennu_vtable  *vtable;
  bennu_object  *selector;
  bennu_closure *closure;
} MethodCache[8192];
#endif

bennu_closure *bennu_obj_bind(bennu_object *rcv, bennu_object *msg)
{
  bennu_closure *c;
  bennu_vtable  *vt = rcv->_vt[-1];
#if BENNU_OBJ_MCACHE
  struct entry   *cl = MethodCache + ((((unsigned)vt << 2) ^ ((unsigned)msg >> 3)) & ((sizeof(MethodCache) / sizeof(struct entry)) - 1));
  if (cl->vtable == vt && cl->selector == msg)
    return cl->closure;
#endif
  c = ((msg == bennu_s_lookup) && (rcv == (bennu_object *)vtable_vt))
    ? (bennu_closure *)vtable_lookup(0, vt, msg)
    : (bennu_closure *)BENNU_OBJ_SEND(vt, bennu_s_lookup, msg);
#if BENNU_OBJ_MCACHE
  cl->vtable   = vt;
  cl->selector = msg;
  cl->closure  = c;
#endif
  return c;
}

bennu_vtable *vtable_delegated(bennu_closure *closure, bennu_vtable *self)
{
  bennu_vtable *child= (bennu_vtable *)bennu_obj_alloc(sizeof(bennu_vtable));
  child->_vt[-1] = self ? self->_vt[-1] : 0;
  child->size    = 2;
  child->tally   = 0;
  child->keys    = (bennu_object **)calloc(child->size, sizeof(bennu_object *));
  child->values  = (bennu_object **)calloc(child->size, sizeof(bennu_object *));
  child->parent  = self;
  return child;
}

bennu_object *vtable_allocate(bennu_closure *closure, bennu_vtable *self, int payloadSize)
{
  bennu_object *object = (bennu_object *)bennu_obj_alloc(payloadSize);
  object->_vt[-1] = self;
  return object;
}

bennu_meth_t vtable_addMethod(bennu_closure *closure, bennu_vtable *self, bennu_object *key, bennu_meth_t method)
{
  int i;
  for (i = 0;  i < self->tally;  ++i)
    if (key == self->keys[i])
      return ((bennu_closure *)self->values[i])->method = method;
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

bennu_object *vtable_lookup(bennu_closure *closure, bennu_vtable *self, bennu_object *key)
{
  int i;
  for (i = 0;  i < self->tally;  ++i)
    if (key == self->keys[i])
      return self->values[i];
  if (self->parent)
    return BENNU_OBJ_SEND(self->parent, bennu_s_lookup, key);
  fprintf(stderr, "lookup failed %p %s\n", self, ((bennu_symbol *)key)->string);
  return 0;
}

bennu_object *bennu_symbol_intern(bennu_closure *closure, bennu_object *self, char *string)
{
  bennu_object *symbol;
  int i;
  for (i = 0;  i < SymbolList->tally;  ++i)
    {
      symbol = SymbolList->keys[i];
      if (!strcmp(string, ((bennu_symbol *)symbol)->string))
	return symbol;
    }
  symbol = symbol_new(string);
  vtable_addMethod(0, SymbolList, symbol, 0);
  return symbol;
}

void bennu_obj_init(void)
{
  vtable_vt = vtable_delegated(0, 0);
  vtable_vt->_vt[-1] = vtable_vt;

  bennu_object_vtable = vtable_delegated(0, 0);
  bennu_object_vtable->_vt[-1] = vtable_vt;
  vtable_vt->parent = bennu_object_vtable;

  symbol_vt  = vtable_delegated(0, bennu_object_vtable);
  closure_vt = vtable_delegated(0, bennu_object_vtable);

  SymbolList = vtable_delegated(0, 0);

  bennu_s_lookup    = bennu_symbol_intern(0, 0, "lookup");
  bennu_s_addMethod = bennu_symbol_intern(0, 0, "addMethod");
  bennu_s_allocate  = bennu_symbol_intern(0, 0, "allocate");
  bennu_s_delegated = bennu_symbol_intern(0, 0, "delegated");

  vtable_addMethod(0, vtable_vt, bennu_s_lookup,    (bennu_meth_t)vtable_lookup);
  vtable_addMethod(0, vtable_vt, bennu_s_addMethod, (bennu_meth_t)vtable_addMethod);

  BENNU_OBJ_SEND(vtable_vt, bennu_s_addMethod, bennu_s_allocate,    vtable_allocate);
  BENNU_OBJ_SEND(vtable_vt, bennu_s_addMethod, bennu_s_delegated,   vtable_delegated);
}
