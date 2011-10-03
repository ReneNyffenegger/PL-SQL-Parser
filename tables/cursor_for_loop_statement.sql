create table nd_cursor_for_loop_statement (
-- TODO_0085: Note similarity to 'for_loop_statement'
  id number(8) primary key,
  record_ varchar2(30) not null, -- not null references nd_plsql_identifier,
  cursor_  varchar2(30)    null,
  actual_cursor_parameter  null references nd_parameter_list,
  select_statement         null references nd_select_statement,
  statement_list       not null references nd_statement_list,
  label_  varchar2(30)
);
