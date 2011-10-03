declare
--  This anonymous block uses the plsql_parser
--  to fill the node tables (ND%).
--
--  The file parser_2.sql then verifies
--  the content of the node tables.

  procedure test(name in varchar2, type in varchar2) is/*{*/
    s  scanner_dba_source;
    l  lexer;
    t  token_getter_into_table;
  begin

    dbms_output.put_line('  parsing: ' || name || ' (' || type || ')');

    s := new scanner_dba_source (user, name, type);
    l := new lexer(s);
    t := new token_getter_into_table(l);


    if    type = 'PACKAGE' then
          plsql_parser."package"(t);
    elsif type = 'PACKAGE BODY' then
          plsql_parser."package_body"(t);
    else  raise_application_error(-20900, 'unknown type: ' || type);
    end if;
  end test;/*}*/

begin

  test('TQ84_PCK_1', 'PACKAGE');
  test('TQ84_PCK_2', 'PACKAGE');
  test('TQ84_PCK_3', 'PACKAGE');
  test('TQ84_PCK_4', 'PACKAGE');
  test('tq84_pck_5', 'PACKAGE');
  test('TQ84_PCK_6', 'PACKAGE');
  test('TQ84_PCK_7', 'PACKAGE');

  test('TQ84_PCK_4', 'PACKAGE BODY');

end;
/
