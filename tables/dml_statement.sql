create table nd_dml_statement (
--http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/statements_8005.htm#SQLRF01505
  id number (8) primary key,
  delete_statement   null references nd_delete_statement,
  update_statement   null references nd_update_statement,
  insert_statement   null references nd_insert_statement,
  check (
        nvl2(delete_statement, 1, 0) + 
        nvl2(update_statement, 1, 0) +
        nvl2(insert_statement, 1, 0) = 1
  )
);
