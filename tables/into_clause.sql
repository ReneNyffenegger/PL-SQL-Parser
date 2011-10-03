create table nd_into_clause (
  id             number primary key,
  bulk_collect_  number(1) null check (bulk_collect_ in (1)),
  variables not null references nd_plsql_identifier_list
);
