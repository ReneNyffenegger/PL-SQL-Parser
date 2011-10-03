declare

   s   scanner_varchar2 := scanner_varchar2('ad ' || chr(10) || 'h' || chr(13) || 'j');

   procedure next_char(expected_char in char, expected_pos in number) is/*{*/
   begin

       s.next_char;

       if nvl(s.next_position_, -42) != nvl(expected_pos, -42) then
          raise_application_error(-20800, 'next_position_: ' || s.next_position_ || ', expected: ' || expected_pos);
       end if;
          
       if nvl(s.current_character_, 'n/a') != nvl(expected_char,'n/a') then
          raise_application_error(-20800, 'current_char: ' || s.current_character_ || ', expected: ' || expected_char);
       end if;

   end next_char;/*}*/

begin

   if s.next_position_ != 0 then/*{*/
      dbms_output.put_line('Error #1');
      return;
   end if;/*}*/


   next_char(      'a' , 1);
   next_char(      'd' , 2);
   next_char(      ' ' , 3);
   next_char(  chr(10) , 4);
   next_char(      'h' , 5);
   next_char(  chr(13) , 6);
   next_char(      'j' , 7);

   if s.eof_reached_ != 0 then/*{*/
      raise_application_error(-20800, 'eof_reached_ should be 0');
   end if;/*}*/

   next_char(    null  , null);

   if s.eof_reached_ != 1 then/*{*/
      raise_application_error(-20800, 'eof_reached_ should be 0');
   end if;/*}*/
   
   begin/*{*/
     s.next_char;
     raise_application_error(-20800, 'scanner_eof_reached should be thrown');
   exception 
     when errors.scanner_eof_reached then
       null;
   end;/*}*/


   dbms_output.put_line('Test ok: scanner_varchar2');

   exception when others then
     dbms_output.put_line(sqlerrm);

end;
/
