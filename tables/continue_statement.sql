create table nd_continue_statement (
--TODO_0075: Testcase.
--TODO_0076: note the similarity to the exit statement.
  id                  number(8) primary key,
  label               varchar2(30) null,
  condition           null references nd_condition -- Tahiti says: 'boolean expression'
);
