create table nd_subquery_elem (
  subquery                 not null references nd_subquery,
  set_operator             varchar2(10) null check (upper(set_operator) in ('UNION', 'UNION ALL', 'MINUS', 'INTERSECT')),
  subquery_in_paranthesis  null references nd_subquery,
  query_block              null references nd_query_block,
  check (
    (subquery_in_paranthesis is not null and query_block is     null) or
    (subquery_in_paranthesis is     null and query_block is not null)
  )
  -----------------------------------------------------------------------------------
  --  All set operators have equal precedence. If a SQL statement contains         --
  --  multiple set operators, then Oracle Database evaluates them from the left to --
  --  right unless parentheses explicitly specify another order.                   --
  -----------------------------------------------------------------------------------
);
