create or replace type body scanner_dba_source as

  -- NOTE: all parameters (owner_, name_ and type_) are case sensitive!
  constructor function scanner_dba_source(owner_ in varchar2, name_ in varchar2, type_ in varchar2) return self as result is/*{*/
    dummy       number;

    cnt_fetched number;

  begin

      self.init();

      cursor_ := dbms_sql.open_cursor;

      -- The following SQL statement needs an explicit
      --    grant select on dba_source to ...
      -- TODO_0005: There should be a more sophisticated way
      --            to deal with the case when a user doesn't
      --            have sufficient rights to select from dba_source
      dbms_sql.parse(
        cursor_, 
       'select text from dba_source where owner = :owner and name = :name and type = :type order by line',
        dbms_sql.v7
      );

      dbms_sql.bind_variable(cursor_, ':owner', owner_);
      dbms_sql.bind_variable(cursor_, ':name' , name_ );
      dbms_sql.bind_variable(cursor_, ':type' , type_ );

      dbms_sql.define_column(cursor_, 1, current_text_, 4000);

      dummy := dbms_sql.execute(cursor_);

      -------------------------------------------------------------
      -- Fetch first row into current_text_.
      -- If there is no row to be fetched, it is assumed that
      -- the package doesn't exist, and an -> unknown_source 
      -- is thrown.
      cnt_fetched := dbms_sql.fetch_rows(cursor_);
      if cnt_fetched = 0 then
         dbms_sql.close_cursor(cursor_);
         raise errors.unknown_source;
      end if;
      dbms_sql.column_value(cursor_, 1, current_text_ );
      -------------------------------------------------------------

      next_line_         := 1;
      next_pos_in_text_  := 0;

      return;

  end scanner_dba_source;/*}*/

  overriding instantiable final member function read_char(self in out scanner_dba_source) return char/*{*/
  is 
    cnt_fetched number; 
  begin


     if nvl(length(current_text_), 0) = next_pos_in_text_ then

        cnt_fetched := dbms_sql.fetch_rows(cursor_);

        if cnt_fetched = 0 then
           
           dbms_sql.close_cursor(cursor_);
           cursor_ := -1;
           return null;
        end if;

        dbms_sql.column_value(cursor_, 1, current_text_ );

        next_pos_in_text_ := 0;
        next_line_        := next_line_ + 1;

     end if;

     next_pos_in_text_ := next_pos_in_text_ + 1;

     return substr(current_text_, next_pos_in_text_, 1);

  end read_char;/*}*/

end;
/
