create table nd_bounds_clause (
  -- http://download.oracle.com/docs/cd/E11882_01/appdev.112/e17126/forall_statement.htm#i34324
  id number(8) primary key,
  lower_bound  null references nd_expression,
  upper_bound  null references nd_expression  -- TODO_0064 see similarity with >> FOR I IN 1 .. 1000 <<
);
