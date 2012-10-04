create or replace package body tst_parse_tree as

    procedure iterate_record(record_ in tst_record, from_tab in varchar2, tab in varchar2, indent_level in number) is -- {
        parent_tab                varchar2(   30);
    begin

        dbms_output.put_line(lpad(' ', indent_level * 2) || tab || ' ' || chr(123));

        for c in 1 .. record_.fields.count loop 

            if    record_.fields(c).column_name = 'ID' then

                  dive_from_pk_to_fk(from_tab, tab, record_.fields(c).field_value, indent_level+1);

            else 

                  parent_tab := record_.fields(c).foreign_key_table;

                  if parent_tab is not null then
                   
                     if parent_tab != from_tab then

                        dive_from_fk_to_pk(tab, parent_tab, record_.fields(c).field_value, indent_level+1);

                     end if;

                  else
                 
                     dbms_output.put_line(lpad(' ', indent_level * 2 + 2) || record_.fields(c).column_name || ': ' || record_.fields(c).field_value);

                  end if;

            end if;

        end loop;

        dbms_output.put_line(lpad(' ', indent_level * 2) || chr(125));

    end iterate_record; -- }

    procedure dive_from_fk_to_pk(from_tab in varchar2, tab in varchar2, pk in number, indent_level in number) is -- {


        record_           tst_record;
       
    begin

        if pk is null then
           return;
        end if;

        record_ := new tst_record(tab, 'where id = ' || pk);

        iterate_record(record_, from_tab, tab, indent_level);

    end dive_from_fk_to_pk; -- }

    procedure dive_from_pk_to_fk(from_tab in varchar2, tab in varchar2, pk in number, indent_level in number) is -- {

        result_  tst_result;

    begin

        for r_tab in (select rcon.table_name, cols.column_name
                        from user_constraints  cons join
                             user_constraints  rcon on cons.constraint_name = rcon.r_constraint_name join
                             user_cons_columns cols on rcon.constraint_name = cols.constraint_name
                       where cons.table_name  =      tab and
                             rcon.table_name != from_tab and
                             cons.constraint_type = 'P') loop -- {


            result_ := new tst_result(r_tab.table_name, r_tab.column_name, pk);

            if result_.records.count > 0 then

               for c in 1 .. result_.records.count loop

                   iterate_record(result_.records(c), tab, r_tab.table_name, indent_level);

               end loop;

            end if;

        end loop; -- }

    end dive_from_pk_to_fk; -- }

end tst_parse_tree;
/

