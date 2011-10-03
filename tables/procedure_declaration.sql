create table nd_procedure_declaration (
  id number(8)         not null primary key,
  procedure_heading    not null references nd_procedure_heading
);
