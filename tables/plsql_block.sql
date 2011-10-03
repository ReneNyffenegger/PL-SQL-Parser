create table nd_plsql_block (
  id number(8) primary key,
  declare_section     null references nd_declare_section,
  body_           not null references nd_body
);
