create table nd_analytic_clause (
  id number(8) primary key,
  query_partition_clause  null references nd_query_partition_clause,
  order_by_clause         null references nd_order_by_clause,
  windowing_clause        null references nd_windowing_clause,
  check(windowing_clause is null or order_by_clause is not null)
);
