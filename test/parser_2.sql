@@tst_field_spec.plsql
@@tst_field_body.plsql
@@tst_record_spec.plsql
@@tst_record_body.plsql
@@tst_result_spec.plsql
@@tst_result_body.plsql
@@tst_parse_tree_spec.plsql
@@tst_parse_tree_body.plsql

set termout   off
set trimspool on

spool parsed.actual

begin

  for package in (select * from nd_package order by lower(package_name)) loop

      dbms_output.put_line('package ' || package.package_name || ' ' || package.invoker_right || ' {');

      if package.declare_section is not null then 
         tst_parse_tree.dive_from_fk_to_pk('ND_PACKAGE', 'ND_DECLARE_SECTION', package.declare_section, 1);
      end if;

      dbms_output.put_line('}');

  end loop;

  for package_body in (select id from nd_package_body) loop

      tst_parse_tree.dive_from_fk_to_pk('n/a', 'ND_PACKAGE_BODY', package_body.id, 0);

  end loop;
 
end;
/

spool off
set termout on

$fc parsed.actual parsed.expected
