create table nd_close_statement (
  id    number(8) primary key,
  name  references nd_plsql_identifier
);
