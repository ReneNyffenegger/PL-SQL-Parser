create table nd_update_statement (
--http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/statements_10008.htm#SQLRF01708
  id number(8) primary key,
  hint  varchar2(100),
  -- TODO_0107: dml_table_expression_clause, ONLY ..., alias, returning_clause, error_logging_clause   seems to be part in all dml_statement's.
  dml_table_expression_clause null references nd_dml_table_expression_clause,
  -- TODO_0047: "ONLY ( dml_table_expression_clause )"
  alias_   varchar2(30),
  update_set_clause   not null references nd_update_set_clause,
  where_clause            null references nd_where_clause,
  returning_clause        null references nd_returning_clause,
  error_logging_clause    null references nd_error_logging_clause
);
