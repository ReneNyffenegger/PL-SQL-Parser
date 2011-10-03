create or replace type number_stack as object (
-- This type is needed for the token_getter_into_table type.

  numbers_ numbers_t,

  constructor function number_stack return self as result,

  final instantiable member procedure push     (i in number),
  final instantiable member function  pop(self in out number_stack) return number
);
/
