create table nd_aggregate_function (
  id                        number  (8) primary key,
  name                      varchar2(20) not null, --        'count', 'avg' ...
  expression                references nd_expression,
  analytic_clause      null references nd_analytic_clause,
  check (
    (lower(name) in ('row_number')
      and analytic_clause is not null
    ) or 
    lower (name) in ('avg', 'min', 'count')
  )
);
