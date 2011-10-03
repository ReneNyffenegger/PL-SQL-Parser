create table nd_while_loop_statement (
  id number(8) primary key,
  condition      not null references nd_condition,
  statement_list not null references nd_statement_list,
  label               varchar2(30) null -- <<LABEL>>
);
