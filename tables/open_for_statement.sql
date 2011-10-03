create table nd_open_for_statement (
  -- TODO_0093: Host Variable
  id            number(8) primary key,
  cursor_variable      not null references nd_complex_plsql_ident,
  select_statement         null references nd_select_statement,
  dynamic_string           null references nd_expression, -- TODO_0081: check for string expression
  using_clause             null references nd_using_clause
);
