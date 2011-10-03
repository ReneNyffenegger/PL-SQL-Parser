create or replace type body scanner as

  instantiable final member procedure init (self in out scanner) is/*{*/
  begin
     next_position_ := 0;
     eof_reached_   := 0;
  end init;/*}*/

  instantiable final member procedure next_char(self in out scanner) is/*{*/
  begin

      if  eof_reached_ is null or/*{*/
          eof_reached_ not in (0, 1) then

      --  eof_reached_ should be set in the constructor and the implentation
      --  of the scanner should make sure that eof_reached_ is always either
      --  0 or 1. Otherwise, something is seriously wrong and warants
      --  a risen application error:
          raise_application_error(-20900, 'eof_reached_: ' || eof_reached_);
      end if;/*}*/

      if eof_reached_ = 1 then/*{*/
         raise errors.scanner_eof_reached;
      end if;/*}*/

      current_character_ := read_char;
      if current_character_ is null then/*{*/
         eof_reached_   := 1;
         next_position_ := null;
         return;
      end if;/*}*/

      next_position_ := next_position_ + 1;

  end next_char;/*}*/

end;
/
