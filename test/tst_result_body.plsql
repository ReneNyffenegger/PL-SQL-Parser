create or replace type body tst_result as

  constructor function tst_result(table_ in varchar2, where_column in varchar2, where_value in varchar2) return self as result -- {
  is

      stmt                       varchar2(30000);
      stmt_1                     varchar2(30000);
      stmt_2                     varchar2(30000);
      stmt_order_by              varchar2(30000);

      function is_foreign_key(tab in varchar2, col in varchar2) return boolean is -- {
         cnt number;
      begin

          select count(*) into cnt
          from user_constraints  cons
          join user_cons_columns cols on cons.constraint_name   = cols.constraint_name
         where cons.constraint_type = 'R' and
               cols.column_name     =  col and
               cons.table_name      =  tab;

          return cnt > 0;

      end is_foreign_key; -- }

  begin

      stmt_1     :=               'declare fields_  tst_field_t;' || chr(10);

      stmt_1     := stmt_1     || 'begin ' || chr(10);
      stmt_1     := stmt_1     || '  :1 := new tst_record_t();' || chr(10);

      stmt_1     := stmt_1     || '  for r in (select * from ' || table_ || ' where ' || where_column || '=' || where_value;

      --                              ORDER BY HERE (stmt_order_by)
      
      stmt_2     := stmt_2     || ') loop' || chr(10);
      stmt_2     := stmt_2     || '    fields_ := new tst_field_t();' || chr(10);



      for c in (select column_name from user_tab_columns where table_name = table_ order by column_id) loop -- {

          stmt_2     := stmt_2     || '    fields_.extend;' || chr(10);
          stmt_2     := stmt_2     || '    fields_(fields_.count) := new tst_field (table_name => ''' || table_ || 
                                                                   ''', column_name => ''' || c.column_name || 
                                                                   ''', field_value => r.' || c.column_name || ');' || chr(10);

          if c.column_name != where_column and is_foreign_key(table_, c.column_name) then

             if stmt_order_by is null then

                stmt_order_by := ' order by coalesce(null, ' || c.column_name;

             else

                stmt_order_by := stmt_order_by || ', ' || c.column_name;

             end if;

          end if;


      end loop; -- }

      stmt_2     := stmt_2     || '    :1 .extend;' || chr(10);
      stmt_2     := stmt_2     || '    :1 (:1 .count) := new tst_record(fields => fields_);' || chr(10);

      stmt_2     := stmt_2     || '  end loop;' || chr(10);
      stmt_2     := stmt_2     || 'end;';

      if stmt_order_by is not null then
         stmt_order_by := stmt_order_by || ')';
      end if;

      stmt := stmt_1 || stmt_order_by || stmt_2;

      begin
        execute immediate stmt using in out self.records;
      exception when others then

        dbms_output.put_line('---------------');
        dbms_output.put_line(sqlerrm);
        dbms_output.put_line(stmt);
        raise_application_error(-20800, 'tst_result could not execute immediate');

      end;

      return;

  end tst_result; -- }

end;
/
