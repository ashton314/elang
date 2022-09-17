#include <stdio.h>
#include <stdlib.h>
#include "elang_core.h"

void* add_n(void** closed_args, void** args) {
  int* c1 = (int *)closed_args[0];
  int* a1p = (int *)args[0];
  int* result = malloc(sizeof(int));
  *result = (*c1) + (*a1p);
  printf("in func; c1: %d, a1p: %d\n", *c1, *a1p);
  return result;
}

struct closure* make_adder(int i) {
  struct closure* c1 = malloc(sizeof(struct closure));
  void** closed_args = malloc(sizeof(void*) * 1); // sizeof(void*) * #args
  int* a1 = malloc(sizeof(int)); // allocate space on heap for closed-over args
  *a1 = i;                       // move closed args onto heap
  closed_args[0] = a1;
  c1->closed_args = closed_args;
  c1->closed_args_c = 1;
  c1->code = &add_n;

  return c1;
}

int main() {
  struct closure* c1 = make_adder(1);
  // We'll have to remember to emit all the instructions to build up the arg list.
  int tt = 22;
  void** args = malloc(sizeof(void*) * 1);
  args[0] = &tt;
  void* result = c1->code(c1->closed_args, args);
  printf("result: %d\n", *(int*)result);
  return 0;
}

