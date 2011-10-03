create table nd_basic_loop_statement (
-- TODO_0073
--   To prevent an infinite loop, at least one statement 
--   must transfer control outside the loop. The statements that can 
--   transfer control outside the loop are:
--        o  CONTINUE
--        o  EXIT
--        o  GOTO
--        o  RAISE
  id number(8) primary key,
  statement_list  not null references nd_statement_list,
  label               varchar2(30) null -- <<LABEL>>
);
