--  Parse all packages currently installed
--  in a specific schema.

truncate table parser_log;

declare

  procedure test(name in varchar2, type in varchar2) is/*{*/
    s  scanner_dba_source;
    l  lexer;
    t  token_getter_into_table;
  begin

    dbms_output.put_line('  parsing: ' || name || ' (' || type || ')');

    s := new scanner_dba_source (user, name, type);
    l := new lexer(s);
    t := new token_getter_into_table(l);


    if    lower(type) = 'package' then
          parser."package"(t);
    elsif lower(type) = 'package body' then
          parser."package_body"(t);
    else  raise_application_error(-20800, 'unknown type ' || type);
    end if;
  end test;/*}*/

begin

  parser.init_lvl;

  for p in (select object_name package_name,
                   object_type 
              from all_objects 
             where owner       =   owner              and
                   object_type =  'PACKAGE BODY'      and
                   object_name =  'ANLAGEZIELALLOKATIONEN'
             order by object_name
  ) loop

      dbms_output.put_line('Parsing: ' || p.package_name);

      test(p.package_name, p.object_type);

  end loop;

end;
/

set trimspool on
set termout off
spool c:\temp\i.txt

select 
  rtrim(txt)
from
  parser_log
order by
  seq;


spool off
set termout on
set trimspool off
