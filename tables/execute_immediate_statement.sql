create table nd_execute_immediate_statement (
  id number(8) primary key,
  dynamic_sql_statment_expr not null references nd_expression, -- TODO_0081: Must evaluate to a 'string' expression
  into_clause                   null references nd_into_clause,
  using_clause                  null references nd_using_clause
);
