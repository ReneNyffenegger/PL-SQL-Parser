create table nd_insert_into_clause (
  id number(8) primary key,
  dml_table_expression_clause not null references nd_dml_table_expression_clause,
  alias_      varchar2(30),
  column_list null references nd_plsql_identifier_list
);
