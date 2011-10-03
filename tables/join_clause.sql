create table nd_join_clause (
  id              number(8) primary key,
  table_reference not null references nd_table_reference
);
