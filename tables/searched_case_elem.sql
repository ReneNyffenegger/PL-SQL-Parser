create table nd_searched_case_elem (
--TODO_0099 table should probably better be named 'searched_case_expr_elem' as it belongs to a nd_searched_case_expression_
  searched_case_expression not null references nd_searched_case_expression,
--WHEN
  condition     not null references nd_condition,
--THEN
  return_expr   not null references nd_expression
);
