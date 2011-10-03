create table nd_term (
  id        number(8) not null primary key,
  -- The first term within an 'expression' is not connected by
  -- an addop, therefore, it can be null
  addop     varchar2(2) check (addop in ('+', '-', '||')),
  expression           not null references nd_expression
);
