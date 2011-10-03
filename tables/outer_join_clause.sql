create table nd_outer_join_clause (
  id number(8)                primary key,
  query_partition_clause_1 null references nd_query_partition_clause, -- TODO_0094: Implement me in the parser.
  --
  natural_                 number(1) null check(natural_ in (1)),
  -- outer join type {
  full_                    number(1) null check(full_    in (1)),
  left_                    number(1) null check(left_    in (1)),
  right_                   number(1) null check(right_   in (1)),
  outer_                   number(1) null check(outer_   in (1)),
  -- }
  table_reference not null references nd_table_reference,
  query_partition_clause_2 null references nd_query_partition_clause, -- TODO_0094: Implement me in the parser.
  join_on_using            null references nd_join_on_using
);
