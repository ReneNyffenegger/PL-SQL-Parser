create table nd_values_clause (
  id number(8) primary key,
  expression_list not null references nd_expression_list -- Note, the keyword DEFAULT can be in the expression list
);
