create table nd_procedure_heading (
  id       number(8)            not null primary key,
  name     varchar2(30)         not null,
  parameter_declaration_list        null references nd_parameter_declaration_list
);
