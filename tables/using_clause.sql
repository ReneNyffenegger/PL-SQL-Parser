create table nd_using_clause (
  id                  number(8) primary key,
  in_                 number(1) check (in_  in (1)),
  out_                number(1) check (out_ in (1)),
  bind_arguments not null references nd_plsql_identifier_list
);
