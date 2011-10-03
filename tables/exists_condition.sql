create table nd_exists_condition (
--http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/conditions012.htm
--The exists condition is valid in a 'where clause' only.
  id number(8) primary key,
  subquery not null references nd_subquery
);
