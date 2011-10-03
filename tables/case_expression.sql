create table nd_case_expression (
  --
  -- CASE expressions let you use IF ... THEN ... ELSE logic in SQL statements
  -- without having to invoke procedures.
  --
  id number(8) not null primary key,
  simple_case_expression   null references nd_simple_case_expression,
  searched_case_expression null references nd_searched_case_expression,
  --
  else_clause              null references nd_else_clause,
  --
  check (
    (simple_case_expression is     null and searched_case_expression is not null) or
    (simple_case_expression is not null and searched_case_expression is     null)
  )
);
