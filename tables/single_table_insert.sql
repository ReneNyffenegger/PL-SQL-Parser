create table nd_single_table_insert (
  id number(8) primary key,
  insert_into_clause  not null references nd_insert_into_clause,
  values_clause           null references nd_values_clause,
  returning_clause        null references nd_returning_clause,
  subquery                null references nd_subquery,
  error_logging_clause    null references nd_error_logging_clause,
  check (
    values_clause is     null and subquery is not null or
    values_clause is not null and subquery is     null
  ),
  check (
     returning_clause is null or values_clause is not null
  )
);
