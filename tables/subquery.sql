create table nd_subquery (
  id                   number(8)      primary key,
  order_by_clause                null references nd_order_by_clause
);
