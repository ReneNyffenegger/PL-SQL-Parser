create table nd_in_condition (
--http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/conditions013.htm
  id number(8) primary key,
  expression         null references nd_expression,
  expression_list_1  null references nd_expression_list,
  not_               number(1) check (not_ in (1)),
  expression_list_2  null references nd_expression_list,
  subquery           null references nd_subquery,
  ----
  check (
     (  ( expression is     null and expression_list_1 is not null ) or
        ( expression is not null and expression_list_1 is     null ) )    and
        ------------
     (   expression_list_2 is     null and subquery is not null or
         expression_list_2 is not null and subquery is     null      )
  )
);
