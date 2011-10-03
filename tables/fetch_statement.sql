create table nd_fetch_statement (
  id          number(8) primary key,
  name        not null references nd_plsql_identifier,
  into_clause not null references nd_into_clause,
  limit           null references nd_expression    -- TODO_0081: Numeric expression, and implement it.
--  TODO_0084 check limit is null or into_clause.bulk_collect_ = 1
);
