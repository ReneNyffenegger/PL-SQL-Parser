create table nd_body (
--   http://download.oracle.com/docs/cd/E11882_01/appdev.112/e17126/block.htm#CJACHDGG
     id number(8) primary key,
     statement_list not      null references nd_statement_list,
     exception_handler_list  null references nd_exception_handler_list
);
