create table nd_else_clause (
--Note:
--  The else_clause is used within
--    o  case_expression
--  It is not to be confused with the else part in 
--  an pl/sql if statement.
  id number(8) primary key,
  expression not null references nd_expression
);
