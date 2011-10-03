create table nd_cast (
--http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/functions023.htm#SQLRF00613
  id                number (8) primary key,
  expression        null references nd_expression,
  multiset_subquery null references nd_subquery,
  datatype          null references nd_datatype,
  check (expression is     null and multiset_subquery is not null or
         expression is not null and multiset_subquery is     null)
);
