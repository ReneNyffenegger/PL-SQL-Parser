create table nd_complex_plsql_ident (
  -- This node should be able to 'parse' plsql-identifier constructs such as
  --   abc.def(1)(5).ghi(8).jkl ...
  -- as opposed to the plsql_identifier node
  -- that can "only" parse simple constructs such as
  --    abc.def.ghi
  --
  id number(8) primary key,
  --complex_plsql_ident_list not null references nd_complex_plsql_ident_list
  found  number(1) check (found in (1)) -- %found
);
