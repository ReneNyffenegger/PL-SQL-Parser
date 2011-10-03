create or replace type body token as 

  constructor function token(pos in number, line in number, pos_in_line in number) return self as result is begin/*{*/

      type_        := '?';

      pos_         := pos;
      line_        := line;
      pos_in_line_ := pos_in_line;

      return;

  end token;/*}*/

  final member procedure append(self in out token, c in char) is/*{*/
  begin

      token_ := token_ || c;

  exception when others then
      
      if sqlcode = -6502 then --  PL/SQL: numeric or value error: character string buffer too small
         raise_application_error(-20800, 'token.append: token_: ' || substr(token_, 1, 100) || '<< is too large');
      end if;

      raise;

  end append;/*}*/

end;
/
