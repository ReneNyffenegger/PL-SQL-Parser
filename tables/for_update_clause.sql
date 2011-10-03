create table nd_for_update_clause (
  id  number(8)         primary key,
  plsql_identifier_list null references nd_plsql_identifier_list,
  nowait_      number( 1)  null check (nowait_ in (1)),
  wait_        number(10)  null,
  skip_locked_ number( 1)  null check (skip_locked_ in (1))
);
