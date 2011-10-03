-- Install the required packages to be parsed
@@ install.sql

truncate table parser_log;

exec plsql_parser.init_lvl;

@@ parser_1.sql
@@ parser_2.sql

-- uninstall the required packages to be parsed
@@ uninstall.sql

-- spool parser_into temp file {
set trimspool on
set termout off
spool c:\temp\p.txt

select 
  rtrim(txt)
from
  parser_log
order by
  seq;

spool off
set termout on
set trimspool off
-- }
