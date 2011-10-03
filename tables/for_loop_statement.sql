create table nd_for_loop_statement (
-- TODO_0085: Note similarity to 'cursor_for_loop_statement'
  id     number(8) primary key,
  index_ not null references nd_plsql_identifier, -- TODO_0086: should this not be a varchar2(30), see also 'record_' in -> nd_cursor_for_loop_statement
  reverse_ number(1) check (reverse_ in (1)),
  statement_list not null references nd_statement_list,
  lower_bound    not null references nd_expression, -- TODO_0081: should evaluate to an integer
  upper_bound    not null references nd_expression, -- TODO_0081: should evaluate to an integer
  label_   varchar2(30)
);
