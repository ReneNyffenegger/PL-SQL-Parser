create table nd_order_by_elem (
  order_by_clause   not null references nd_order_by_clause,
  expression        not null references nd_expression,
  asc_desc          char(1)    null check (asc_desc         in ('A', 'D')),
  nulls_first_last  char(1)    null check (nulls_first_last in ('F', 'L'))
);
