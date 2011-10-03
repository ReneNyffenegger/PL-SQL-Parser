create table nd_simple_expression (
  --
  -- A simple expression specifies a 
  --   o  column, 
  --   o  pseudocolumn, 
  --   o  constant, 
  --   o  sequence number, or
  --   o  null.
  -- 
  -- What is the difference to a 'column expression'?
  --
  -- Within *this* framework, a 'simple expression 'can
  -- also be a 'function call' without ().
  -- As soon as a function call has parenthesis, it
  -- is a 'function expression'.
  --
  id number(8) not null primary key,
  plsql_identifier   null references nd_plsql_identifier
);
