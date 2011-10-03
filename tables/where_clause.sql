create table nd_where_clause (
  id number(8)        not null primary key,
  condition           not null references nd_condition
--boolean_expression  not null references nd_boolean_expression
);
