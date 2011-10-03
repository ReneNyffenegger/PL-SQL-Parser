create table nd_procedure_definition (
  id                          number(8)   not null primary key,
--relies_on_clause                            null references nd_relies_on_clause, -- TODO does a procedure have a relies on clause?    
  procedure_heading                       not null references nd_procedure_heading,
  declare_section                             null references nd_declare_section,
  body_                                   not null references nd_body
);
