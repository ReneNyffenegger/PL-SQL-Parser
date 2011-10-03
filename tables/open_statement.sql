create table nd_open_statement (
  id                         number(8) primary key,
  name                       not null references nd_plsql_identifier,
  actual_cursor_parameters       null references nd_parameter_list
);
