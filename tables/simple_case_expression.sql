create table nd_simple_case_expression (
  id number(8)      primary key,
  expression        not null references nd_expression,
  else_clause           null references nd_else_clause
);
