create or replace type body tst_field as

  member function foreign_key_table return varchar2 is -- {
        parent_tab varchar2(30);
  begin

        select max(rcon.table_name) into parent_tab
          from user_constraints  cons
          join user_cons_columns cols on cons.constraint_name   = cols.constraint_name
          join user_constraints  rcon on cons.r_constraint_name = rcon.constraint_name
         where cons.constraint_type = 'R' and
               cols.column_name     =  self.column_name and
               cons.table_name      =  self.table_name;

        return parent_tab;

  end foreign_key_table; -- }

end;
/
