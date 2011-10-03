create table nd_query_partition_clause (
  id                       number(8) primary key,
  expression_list not null references nd_expression_list
);
