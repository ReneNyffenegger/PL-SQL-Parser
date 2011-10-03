create table nd_expression (
  -- Don't confuse nd_expression with nd_expr!
  id        number(8)     primary key,
  prior_    number(1)  null check (prior_ in (1)) -- Only used in -> "connect_by_condition" (TODO_0060: is this the correct place for the prior 'operator' ?)
);
