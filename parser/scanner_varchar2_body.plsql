create or replace type body scanner_varchar2 as

     constructor function scanner_varchar2(program in varchar2) return self as result is/*{*/
     begin

         self.init;

         program_           := program;
         next_position_     := 0;

         return;

     end scanner_varchar2;/*}*/

     overriding instantiable final member function read_char(self in out scanner_varchar2) return char/*{*/
     is begin

        if length(program_) = next_position_ then
        -- As per the comment in scanner_spec.plsql:
        -- read_char should return null after the last character was read.
           return null;
        end if;

        if length(program_) < next_position_  then
           null; -- TODO_0071
        end if;

        return substr(program_, next_position_+1, 1);

     end read_char;/*}*/

end;
/
