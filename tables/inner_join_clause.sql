create table nd_inner_join_clause (
  id number(8) primary key,
  inner_           number(1) not null check(inner_   in (1)), -- different semantics for 'INNER JOIN' and 'NATURAL INNER JOIN'?
  cross_           number(1) not null check(cross_   in (1)),
  natural_         number(1) not null check(natural_ in (1)),
  table_reference           not null references nd_table_reference,
  join_on_using                 null references nd_join_on_using  -- TODO_0091 must not be null if 'INNER JOIN'.
);
