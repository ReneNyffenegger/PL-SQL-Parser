create table nd_case_statement (
  --
  -- CASE statement let you use IF ... THEN ... ELSE logic in SQL statements
  -- without having to invoke procedures.
  --
  id number(8) not null primary key,
  simple_case_statement   null references nd_simple_case_statement,
  searched_case_statement null references nd_searched_case_statement,
  --
  else_statement_list      null references nd_statement_list,
  --
  check (
    (simple_case_statement is     null and searched_case_statement is not null) or
    (simple_case_statement is not null and searched_case_statement is     null)
  )
);
