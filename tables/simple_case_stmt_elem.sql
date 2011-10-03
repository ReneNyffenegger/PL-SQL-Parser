create table nd_simple_case_stmt_elem (
--TODO: should probably be better named nd_simple_case_expr_elem (as it belongs to a nd_case_expression)
  simple_case_statement  not null references nd_simple_case_statement,
  --
--WHEN
  comparison_expr        not null references nd_expression,
--THEN
  statement_list         not null references nd_statement_list
);
