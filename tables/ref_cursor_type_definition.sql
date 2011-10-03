create table nd_ref_cursor_type_definition (
  id number(8)       primary key,
  name varchar2(30)  not null,
  strong_declaration number(1) not null check (strong_declaration in (0, 1)),
  plsql_identifier references nd_plsql_identifier,
  check (
    ( strong_declaration = 1 and plsql_identifier is not null) or
    ( strong_declaration = 0 and plsql_identifier is     null)
  )
);
