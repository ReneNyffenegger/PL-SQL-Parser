create table nd_if_statement (
  id number(8) primary key,
  boolean_expression     not null references nd_condition,
  statement_list         not null references nd_statement_list,
  elsif_list                 null references nd_elsif_list,
  else_statement_list        null references nd_statement_list
);
