create table nd_commit_statement (
--  All clauses after the COMMIT keyword are optional, the default being:
--    commit work write wait immediate.
--   
--   http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/statements_4010.htm#SQLRF01110
  id number(8) primary key
);
