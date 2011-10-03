create table nd_elsif_elem (
  elsif_list         not null references nd_elsif_list,
  boolean_expression not null references nd_condition,
  statement_list     not null references nd_statement_list
);
