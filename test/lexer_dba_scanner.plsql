declare

-- Tests the lexer with the scanner_dba_source type

  s scanner_dba_source;
  l lexer;


  procedure check_token(token in varchar2, type_ in varchar2) is begin/*{*/

      if token != l.current_token_.token_ then
         raise_application_error(-20800, 'Expected token: ' || token || ', but was: ' || l.current_token_.token_);
      end if;
       
      if type_ != l.current_token_.type_ then
         raise_application_error(-20800, 'Expected type: ' || type_);
      end if;

      l.next_token;

  end check_token;/*}*/

begin

  execute immediate 'create or replace package   "tq84_test_scanner_dba_source" as procedure dummy; end "tq84_test_scanner_dba_source";';

  s := new scanner_dba_source(user, 'tq84_test_scanner_dba_source', 'PACKAGE');

  l := new lexer(s);

  check_token('package'                       , 'ID');                            check_token('   ', 'WS' );
  check_token('"tq84_test_scanner_dba_source"', 'Id');                            check_token(  ' ', 'WS' );
  check_token('as'                            , 'ID');                            check_token(  ' ', 'WS' );
  check_token('procedure'                     , 'ID');                            check_token(  ' ', 'WS' );
  check_token('dummy'                         , 'ID'); check_token(  ';', 'SYM'); check_token(  ' ', 'WS' );
  check_token('end'                           , 'ID');                            check_token(  ' ', 'WS' );
  check_token('"tq84_test_scanner_dba_source"', 'Id'); check_token(  ';', 'SYM');

  if l.current_token_ is not null then
     raise_application_error(-20800, 'current_token_ should be null');
  end if;

  execute immediate 'drop package "tq84_test_scanner_dba_source"';

  dbms_output.put_line('Test ok: lexer dba scanner');

end;
/
