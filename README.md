The aim of this project is to be able to parse PL/SQL.

The parsing is done by the package plsql_parser (whose implementation 
is found in the files parser/plsql_parser_body.plsql and 
parser/plsql_parser_spec.plsql)

The parser will create a parse tree into (what I call) node
tables, prefixed with 'nd_' (for node).
These tables are found in the tables directory.
This directory also contains tables/install_nodes.sql
in order to install the tables in the correct order.
The same tables can then be uninstalled with
tables/uninstall_nodes.sql

A parser needs a scanner and a lexer. These are found
under the directory parser as well.

# INSTALLATION

It is recommended to create a schema for the database objects
needed by the parser.

    create user TQ84_PARSER identified by TQ84_PARSER;
    grant dba to TQ84_PARSER;
    connect TQ84_PARSER/TQ84_PARSER;

    @install_parser.sql


# TESTS

A few test cases are found under the directrory test/

After the parser is installed, the tests can be
executed with 

    @@ tests/go.sql
