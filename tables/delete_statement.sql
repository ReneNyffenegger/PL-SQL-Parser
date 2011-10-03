create table nd_delete_statement (
--   http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/statements_8005.htm#SQLRF01505
  id number(8) primary key,
  hint  varchar2(100),
  from_ number(1)    check (from_ in (1)),
  dml_table_expression_clause null references nd_dml_table_expression_clause,
  -- TODO_0047 "ONLY (dml_table_expression_clause)",
  alias_  varchar2(30),
  where_clause   null references nd_where_clause,
  returning_clause null references nd_returning_clause,
  error_logging_clause null references nd_error_logging_clause
);
