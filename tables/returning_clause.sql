create table nd_returning_clause (
  id number(8)     primary key,
  expression_list  not null references nd_expression_list,
  data_item_list   not null references nd_plsql_identifier_list
);
