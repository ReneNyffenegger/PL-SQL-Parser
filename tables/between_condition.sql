create table nd_between_condition (
--http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/conditions011.htm#SQLRF52164
  id number (8) primary key,
  expr1 not null references nd_expression,
  not_ number(1) check (not_ in (1)),
  expr2 not null references nd_expression,
  expr3 not null references nd_expression
);
