create table nd_insert_statement (
--   http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/statements_9014.htm#i2163698
  id                   number(8) primary key,
  hint                 varchar2(100),
  single_table_insert  null references nd_single_table_insert,
  multi_table_insert   null references nd_multi_table_insert,
  check ( single_table_insert is     null and multi_table_insert is not null or
          single_table_insert is not null and multi_table_insert is     null
        )
);
