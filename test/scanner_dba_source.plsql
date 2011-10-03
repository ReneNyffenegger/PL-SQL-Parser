declare
  s scanner_dba_source;

  type lines_t is table of varchar2(100);
  lines lines_t := lines_t(/*{*/
    'package tq84_test_dba_source as',
    '',
    '  num number; ',
    '',
    '  procedure dummy_p;',
    '',
    '  function  dummy_f return number;',
    ' ',
    'end tq84_test_dba_source;',
    '  -- Line with a comment',
    '  /* More Comments */'
  );/*}*/


  text varchar2(4000);

  procedure check_line(line in varchar2) is/*{*/

    line_ varchar2(100);
  begin

    line_ := line || chr(10);

    for i in 1 .. length(line_) loop/*{*/

        if nvl(s.eof_reached_, -49) != 0 then
           raise_application_error(-20800, 'eof_reached_: ' || s.eof_reached_);
        end if;

        s.next_char;

        if s.current_character_ != substr(line, i, 1) then
           raise_application_error(-20800, 'line: ' || line || ', i: ' || i || ', current_char >' || s.current_character_ || '<');
        end if;

    end loop;/*}*/

  end check_line;/*}*/

begin

  text := ' /* just some comments and '    || chr(10) ||
          '    meaningless whitespaces */' || chr(10) ||
          ' -- foo bar '                   || chr(10) || 
          'create or replace ';


  for i in 1 .. lines.count loop
      text := text || lines(i) || chr(10);
  end loop;

  execute immediate text;

  begin
    s := scanner_dba_source(user, 'UNKNWOWN_NAME', 'PACKAGE');
  exception
    when errors.unknown_source then
    --   It is expected that this error is thrown.
    --   Therefore, we catch it and do ... nothing, yeah.
         null;
  end;

  s := scanner_dba_source(user, 'TQ84_TEST_DBA_SOURCE', 'PACKAGE');

  for i in 1 .. lines.count loop
      check_line(lines(i));
  end loop;

  s.next_char;

  if nvl(s.eof_reached_, -49) != 1 then/*{*/
     raise_application_error(-20800, 'eof_reached_ should be 1, is: ' || s.eof_reached_);
  end if;/*}*/

  if s.current_character_ is not null then/*{*/
     raise_application_error(-20800, 'Current character != null');
  end if;/*}*/

  if s.next_position_ is not null then/*{*/
     raise_application_error(-20800, 'next position should be null');
  end if;/*}*/

  begin
    s.next_char;
  exception when errors.scanner_eof_reached then
    null;
  end;

  execute immediate 'drop package tq84_test_dba_source';

  dbms_output.put_line('Test ok: scanner_dba_source');

end;
/
