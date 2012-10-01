create table nd_package (
-- TODO_0109: why has nd_package no id? Compare with nd_package_body.
  package_name      varchar2(30) primary key,  -- TODO_0095: should probably be nd_plsql_identifier, see nd_package_body.
  invoker_right     varchar2(12) check (invoker_right in ('CURRENT_USER', 'DEFINER')),
  declare_section   references nd_declare_section on delete cascade
);
