create table nd_function_expression (
  --
  -- TODO_0068: very similar to nd_procedure_call.
  --
  --
  -- Note: within *this* framework, there are
  -- also functions that are not stored as 
  --'function expressions' but rather as
  --'simple expressions': those that don't
  -- have paranthesis.
  --
  id    number(8) not null primary key,
  name            not null references nd_plsql_identifier,
  parameter_list  not null references nd_parameter_list
);
