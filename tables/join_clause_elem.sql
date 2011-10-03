create table nd_join_clause_elem (
  join_clause not null references nd_join_clause,
  inner_join_clause null references nd_inner_join_clause,
  outer_join_clause null references nd_outer_join_clause,
  check (
    (inner_join_clause is not null and outer_join_clause is     null) or
    (inner_join_clause is     null and outer_join_clause is not null)
  )
);
