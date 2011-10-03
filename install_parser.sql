connect sys/&password as sysdba
drop user tq84_parser cascade;

create user tq84_parser identified by tq84_parser;
grant dba to tq84_parser;

-- Following grant needed for scanner_dba_source. See also TODO_0005
grant select on dba_source to tq84_parser;

connect tq84_parser/tq84_parser;

set feedback off


@@ parser/errors_spec.plsql

-- The base class of the scanner
@@ parser/scanner_spec.plsql
@@ parser/scanner_body.plsql

-- Derived from the scanner's base class,
-- the varchar2 scanner is able to 'read'
-- text from a varchar2 source.
--
-- See test/scanner_varchar2.plsql for a 
-- testcase.
@@ parser/scanner_varchar2_spec.plsql
@@ parser/scanner_varchar2_body.plsql

-- scanner_dba_source is also derived from scanner,
-- but is able to read dba_source, thus allows to
-- parse the source of installed packages.
@@ parser/scanner_dba_source_spec.plsql
@@ parser/scanner_dba_source_body.plsql

-- The parser operates on tokens.
-- Instances of the 'token' class represent
-- such tokens:
@@ parser/token_spec.plsql
@@ parser/token_body.plsql

-- The lexer can create such tokens 
-- from the stream (scanner) that is passed
-- in the sconstructor
@@ parser/lexer_spec.plsql
@@ parser/lexer_body.plsql


-- The token getter is an abstract base class
-- that reads tokens vie the lexer that are 
-- specified in the constructor.
-- With its ability to go forward and backward
-- tokenwise vie its methods push_state, pop_state
-- and remove_state, it is able to parse non LR1
-- languages (of which I believe SQL is one)
@@ parser/token_getter_spec.plsql
@@ parser/token_getter_body.plsql

@@ parser/numbers_t.sql

@@ parser/number_stack_spec.plsql
@@ parser/number_stack_body.plsql

-- Test case for number_stack is test/number_stack.plsql

@@ parser/token_table.sql

@@ parser/token_getter_into_table_spec.plsql
@@ parser/token_getter_into_table_body.plsql

-- The parser can write debug messages that
-- go into the table parser_log:
@@ parser/parser_log.sql

-- The parsed tree goes into these tables (called nodes)
@@ tables/install_nodes.sql

-- The parser!
@@ parser/plsql_parser_spec.plsql
@@ parser/plsql_parser_body.plsql
