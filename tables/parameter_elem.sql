create table nd_parameter_elem (
  parameter_list                   not null references nd_parameter_list,
  name              varchar2(30)       null,  -- Name of parameter
  expression                       not null references nd_expression
  --
  --  If the parameter looks like
  --         p_foo => 9+2
  --  then
  --    name is 'P_FOO' and
  --    9+2 is the expression.
);
