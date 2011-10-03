create table nd_simple_case_elem (
--TODO: should probably be better named nd_simple_case_expr_elem (as it belongs to a nd_case_expression)
  simple_case_expression not null references nd_simple_case_expression,
  --
--WHEN
  comparison_expr        not null references nd_expression,
--THEN
  return_expr            not null references nd_expression
);
