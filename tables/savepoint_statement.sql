create table nd_savepoint_statement (
-- http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/statements_10001.htm#SQLRF01701
--
-- Creates a name for a system change number (scn) to which can be rolled back later on.
--
   id number(8) primary key
-- rollback_name not null references nd_plsql_identifier
);
