create table nd_package_body (
  id                         number(8) primary key,
  package_name      not null references nd_plsql_identifier,
  declare_section       null references nd_declare_section,
  initialize_section    null references nd_initialize_section 
);
