create table nd_forall_statement (
  id     number(8) primary key,
  index_   not null references nd_plsql_identifier,
  bounds_clause not null references nd_bounds_clause,
  save_exceptions_ number(1) check (save_exceptions_ in (1)), -- TODO_0065: implement me!
  dml_statement not null references nd_dml_statement
);
