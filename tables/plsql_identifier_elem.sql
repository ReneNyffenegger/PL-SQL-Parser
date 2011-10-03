create table nd_plsql_identifier_elem (
  plsql_identifier_list not null references nd_plsql_identifier_list,
  plsql_identifier      not null references nd_plsql_identifier
);
