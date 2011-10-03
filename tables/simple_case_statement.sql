create table nd_simple_case_statement (
  id number(8)          primary key,
  selector                  null references nd_expression,
  else_statement_list       null references nd_statement_list
);
