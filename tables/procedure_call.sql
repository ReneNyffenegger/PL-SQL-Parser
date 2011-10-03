create table nd_procedure_call(
--
-- TODO_0097: very similar to nd_function_expression.
--
  id number(8) primary key,
  name            not null references nd_plsql_identifier,
  parameter_list      null references nd_parameter_list
);
