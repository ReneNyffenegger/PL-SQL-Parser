create table nd_nested_table_type_def (
  id number(8)               not null primary key,
  datatype                   not null references nd_datatype,
  not_null_       number(1)      null check (not_null_ in (1))
);
