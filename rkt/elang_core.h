/* elang core header files */

/* This needs to be included in ALL elang files */

// struct closure0 {
//   void** closed_args;         // List of closed-over values
//   int    closed_args_c;       // Number of values closed-over
//   void*  (*code)();
// };

// struct closure1 {
//   void** closed_args;         // List of closed-over values
//   int    closed_args_c;       // Number of values closed-over
//   void*  (*code)(void*);
// };

// struct closure2 {
//   void** closed_args;         // List of closed-over values
//   int    closed_args_c;       // Number of values closed-over
//   void*  (*code)(void*, void*);
// };

struct closure {
  void** closed_args;         // List of closed-over values
  int    closed_args_c;       // Number of values closed-over
  int    args_c;              // Number of arguments to hand to code
  void*  (*code)(void**);
};
