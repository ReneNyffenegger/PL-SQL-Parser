create table nd_cursor_expression (
  -- A CURSOR expression returns a nested cursor. This form of expression is
  -- equivalent to the PL/SQL REF CURSOR and can be passed as a REF CURSOR
  -- argument to a function.
  id number(8) not null primary key
);
