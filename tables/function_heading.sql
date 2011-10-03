create table nd_function_heading (
  id    number(8)                 primary key,
  name  varchar2(30)              not null,
  parameter_declaration_list          null references nd_parameter_declaration_list,
  datatype_returned               not null references nd_datatype
);
