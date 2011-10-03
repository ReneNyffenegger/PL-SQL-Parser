create table nd_update_set_clause_elem (
  update_set_clause not null references nd_update_set_clause,
  column_      not null references nd_complex_plsql_ident,
  expression_  not null references nd_expression
  --
  -- TODO: (column_1, column_2...) = (subquery)
  --
);
