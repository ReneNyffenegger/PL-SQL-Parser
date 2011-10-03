create table nd_expression_list_elem (
  expression_list not null references nd_expression_list,
  expression      not null references nd_expression
);
