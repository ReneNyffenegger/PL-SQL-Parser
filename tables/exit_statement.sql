create table nd_exit_statement (
-- TODO_0076: note the similarity to the 'continue statement'
  id                  number(8) primary key,
  label               varchar2(30) null,
  condition           null references nd_condition -- Tahiti says: 'boolean expression'
);
