create table nd_dml_table_expression_clause (
  id number (8) primary key,
  plsql_identifier   null references nd_plsql_identifier
  -- TODO_0079:
  --   partition_extension_clause
  --   subquery [ subquery_restriction_clause ]
  --   table_collection_expression
);
