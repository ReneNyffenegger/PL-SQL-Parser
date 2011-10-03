create table nd_searched_case_stmt_elem (
  searched_case_statement not null references nd_searched_case_statement,
--WHEN
  condition      not null references nd_condition, -- Tahiti says it's a boolean expression rather than a condition
--THEN
  statement_list not null references nd_statement_list
);
