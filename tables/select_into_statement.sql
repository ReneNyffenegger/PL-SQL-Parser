create table nd_select_into_statement (
  id number(8)              primary key,
  select_statement not null references nd_select_statement
);
