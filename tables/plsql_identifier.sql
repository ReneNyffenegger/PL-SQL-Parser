create table nd_plsql_identifier (
  id   number(8)       not null primary key,
  --   This table is used for plsql_identifiers
  --   that might usually look like package_name.proc_name
  --   or similar, although it can also be a simple function
  --   name or also schema_name.type_name.member_name
  --   and so on.
  --   Therefore, there are three identifiers
  identifier_1   varchar2(30) not null,
  identifier_2   varchar2(30)     null,
  identifier_3   varchar2(30)     null,
  outer_join_symbol    number(1)  null check (outer_join_symbol in (1)), -- Obviously correctly called outer join operator (Cf. ORA-30563)
  found_ number(1) check (found_ in (1)) -- %found  
);
