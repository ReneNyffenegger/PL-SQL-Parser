create table nd_table_reference (
  id number(8)                    not null primary key,
  query_table_expression_ONLY         null references nd_query_table_expression,
  --
  query_table_expression              null references nd_query_table_expression,
  pivot_clause                        null references nd_pivot_clause,
  unpivot_clause                      null references nd_unpivot_clause,
  flashback_query_clause              null references nd_flashback_query_clause,
  t_alias                varchar2(30) null
);
