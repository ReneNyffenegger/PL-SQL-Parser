create or replace type body token_getter as

  instantiable final member procedure read_tokens(self in out token_getter, lexer in out lexer) is/*{*/
  begin

     current_token_ := lexer.current_token_;

     while lexer.current_token_ is not null loop /*{*/

           store_token(lexer.current_token_);
           lexer.next_token;

     end loop; /*}*/

  end read_tokens;/*}*/

  instantiable final member procedure next_stored_program_token is/*{*/
  begin

      self.next_stored_token;

      while current_token_.type_ in ('WS', 'REM') loop
            self.next_stored_token;
      end loop;

  end next_stored_program_token;/*}*/

  instantiable final member function compare_i(self in out token_getter, token_value in varchar2, token_type in varchar2 := 'ID') return boolean is/*{*/
  begin
    
      if current_token_.type_ != token_type then/*{*/
         return false;
      end if;/*}*/

      if upper(current_token_.token_) != upper(token_value) then/*{*/
         return false;
      end if;/*}*/

      return true;

  end compare_i;/*}*/

  instantiable final member function type_(self in out token_getter, token_type in varchar2) return boolean is/*{*/
  begin

      if current_token_.type_ != token_type then
         return false;
      end if;

      return true;

  end type_;/*}*/

  instantiable final member function type_(self in out token_getter) return varchar2 is/*{*/
  begin

      return current_token_.type_;

  end type_;/*}*/

  instantiable final member function token_value(self in out token_getter) return varchar2 is/*{*/
  begin

      if not type_('ID') then
         raise errors.not_an_id;
      end if;

      return current_token_.token_;

  end token_value;/*}*/

  instantiable final member function token_value_id(self in out token_getter) return varchar2 is/*{*/
  begin

      if not type_('ID') and not type_('Id') then
         --    TODO_0002: raise different error.
         raise errors.not_an_id;
      end if;

      return current_token_.token_;

  end token_value_id;/*}*/

  instantiable final member function token_value_sym(self in out token_getter) return varchar2 is/*{*/
  begin

      if not type_('SYM') then
         raise errors.not_a_symbol;
      end if;

      return current_token_.token_;

  end token_value_sym;/*}*/

  instantiable final member function token_value_num(self in out token_getter) return number is/*{*/
  begin

      if not type_('NUM') then
         raise errors.not_a_number;
      end if;

      return to_number(current_token_.token_);

  end token_value_num;/*}*/

  instantiable final member function token_value_str(self in out token_getter) return varchar2 is/*{*/
  begin

      if not type_('STR') then
         raise errors.not_a_string;
      end if;

      return current_token_.token_;

  end token_value_str;/*}*/

  instantiable final member function  what_and_where(self in out token_getter) return varchar2 is/*{*/
  begin
  --  TODO_0003 Testcase for this method.

      return rtrim(current_token_.token_ || ' @ ' || current_token_.line_ || '/' || current_token_.pos_in_line_);

  end what_and_where;/*}*/

end;
/
