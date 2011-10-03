create table nd_factor (
  -- TODO_0082: is this id really necessary?
  id number(8) not null primary key,
  --
  sign_  varchar2(1)        check (sign_ in ('+', '-')),
  -- A factor belongs to a term.
  -- mulop is not set for the first factor in a term,
  -- but for all the other factors.
  mulop                      varchar2(1) check (mulop in ('*', '/')),
  term                       not null references nd_term,
  --
  null_                      number(1) check(null_ in (1)), -- TODO_0083: what is this null_ for?
  function_expression        null references nd_function_expression, -- TODO_0006: this attribute still needed?
  aggregate_function         null references nd_aggregate_function,
  case_expression            null references nd_case_expression,
  complex_plsql_ident        null references nd_complex_plsql_ident,
  scalar_subquery_expression null references nd_scalar_subquery_expression,
  expression                 null references nd_expression,         -- Within paranthesis
  cast_                      null references nd_cast,
  string_                    varchar2(4000), -- If Factor is a STR,
  num_flt                    varchar2(40),   -- If Factor is a NUM or FLT
  -- 
  check( nvl2(null_                        , 1, 0) +
         nvl2(function_expression          , 1, 0) +
         nvl2(aggregate_function           , 1, 0) +
         nvl2(case_expression              , 1, 0) +
         nvl2(complex_plsql_ident          , 1, 0) +
         nvl2(scalar_subquery_expression   , 1, 0) +
         nvl2(expression                   , 1, 0) +
         nvl2(cast_                        , 1, 0) +
         nvl2(string_                      , 1, 0) +
         nvl2(num_flt                      , 1, 0) = 1)
);
