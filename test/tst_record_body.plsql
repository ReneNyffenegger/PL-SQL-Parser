create or replace type body tst_record as 

  constructor function tst_record(table_ in varchar2, where_ in varchar2) return self as result
  is
    
    stmt_intro varchar2(30000);

  begin


      stmt_intro :=               'declare ' || chr(10);
      stmt_intro := stmt_intro || '  r ' || table_ || '%rowtype;' || chr(10);
      stmt_intro := stmt_intro || 'begin ' || chr(10);
      stmt_intro := stmt_intro || '  :1 := new tst_field_t();' || chr(10);
      stmt_intro := stmt_intro || '  begin select * into r from ' || table_ || ' ' || where_ || ';' || chr(10);

      stmt_intro := stmt_intro || '  exception when no_data_found then return; end;' || chr(10);

      for c in (select column_name from user_tab_columns where table_name = table_ order by column_id) loop

          stmt_intro := stmt_intro || '   :1 .extend;' || chr(10);
          stmt_intro := stmt_intro || '   :1 (:1 .count) := new tst_field (table_name  => ''' || table_ || 
                                                                      ''', column_name => ''' || c.column_name || 
                                                                      ''', field_value => r.' || c.column_name || ');' || chr(10);



      end loop;

      stmt_intro := stmt_intro || 'end;';

      begin
        execute immediate stmt_intro using in out self.fields;
      exception when others then
        dbms_output.put_line('------------- ' || sqlerrm || ' The statement is');
        dbms_output.put_line(stmt_intro);
        dbms_output.put_line('------------- ..');
      end;

      return;

  end tst_record;

end;
/
