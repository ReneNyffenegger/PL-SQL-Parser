create table nd_assignment_statement (
  id number(8) primary key,
  target              not null references nd_complex_plsql_ident,
  expression          not null references nd_expression
);
