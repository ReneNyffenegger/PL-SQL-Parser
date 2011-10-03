create or replace type body lexer as

    constructor function lexer(scanner in scanner) return self as result is/*{*/
    begin
 
        scanner_ := scanner;

        current_line_        :=  0;
        current_pos_in_line_ := -1;

        scan_next_char;

        next_token;

        return;
 
    end lexer;/*}*/

    final member procedure scan_next_char as/*{*/
    begin

        if scanner_.current_character_ = chr(10) then/*{*/

           current_line_        := current_line_ + 1;
           current_pos_in_line_ := -1;

        end if;/*}*/
        
        scanner_.next_char;

        current_pos_in_line_  := current_pos_in_line_ + 1;

    end scan_next_char;/*}*/

    final member function isWhiteSpace return boolean is/*{*/
    begin

        if scanner_.current_character_ in (' ', chr(9), chr(10), chr(13)) then
           return true;
        end if;

        return false;

    end isWhiteSpace;/*}*/

    final member function isDigit return boolean is/*{*/
    begin

        if scanner_.current_character_ between '0' and '9' then
           return true;
        end if;

        return false;

    end isDigit;/*}*/

    final member function isAlpha return boolean is /*{*/
    begin

        if upper(scanner_.current_character_) between 'A' and 'Z' then
           return true;
        end if;

        return false;

    end isAlpha;/*}*/

    final member function isIdentStartChar return boolean is/*{*/
    begin
        
        if isAlpha then 
           return true;
        end if;

        return false;

    end isIdentStartChar;/*}*/

    final member function isIdentChar return boolean is/*{*/
    begin

        if isAlpha or isDigit then/*{*/
           return true;
        end if;/*}*/

        if scanner_.current_character_ in ('_') then/*{*/
           return true;
        end if;/*}*/

        -- PL/SQL: Special characters allowed for identifiers...
        if scanner_.current_character_ in ('$', '#') then return/*{*/
           true;
        end if;/*}*/

        return false;

    end isIdentChar;/*}*/

    final member procedure completeNumber(isFloat in boolean) is/*{*/
        -- Complete a number whose first character
        -- is already read.

        isFloat_ boolean := isFloat;
    begin


        while isDigit or scanner_.current_character_ = '.' loop/*{*/

            if scanner_.current_character_ = '.' then
               if isFloat_ then
                  raise_application_error(-20000, 'Second dot seen in number.');
               else
                  isFloat_ := true;
               end if;
            end if;

            current_token_.append(scanner_.current_character_);
            scan_next_char;

        end loop;/*}*/

        if isFloat_ then
           current_token_.type_ := 'FLT';
        else
           current_token_.type_ := 'NUM';
        end if;
 
    end completeNumber;/*}*/

    final instantiable member procedure next_token(self in out lexer) is/*{*/
    begin

        if scanner_.eof_reached_ = 1 then/*{*/
           current_token_ := null;
           return;
        end if;/*}*/
      
        current_token_ := new token(scanner_.next_position_-1, current_line_, current_pos_in_line_);

        if isWhiteSpace then/*{*/
           
           current_token_.type_ := 'WS';
  
           while isWhiteSpace loop
  
                 current_token_.append(scanner_.current_character_);
                 scan_next_char;
  
           end loop;
  
           return;
   
        end if;/*}*/

        if scanner_.current_character_ = '-' then/*{*/

           scan_next_char;

           if scanner_.current_character_ != '-' then/*{*/

              current_token_.type_  := 'SYM';
              current_token_.token_ := '-';

              return;

           end if;/*}*/

           -- Comment "--"
           current_token_.type_  := 'REM';
           current_token_.token_ := '-';

           -- Read comment until eol
           while scanner_.current_character_ not in (chr(13), chr(10)) loop/*{*/

--               current_token_.token_ := current_token_.token_ || scanner_.current_character_;
                 current_token_.append(scanner_.current_character_);
             
                 scan_next_char;

           end loop;/*}*/

           current_token_.append(scanner_.current_character_);
           scan_next_char;

           -- Read optional chr(10) for Windows-Systems (?):
           if scanner_.current_character_ = chr(10) then/*{*/
--            current_token_.token_ := current_token_.token_ || scanner_.current_character_;
              current_token_.append(scanner_.current_character_);

              scan_next_char;
           end if;/*}*/

           return;

        end if;/*}*/

        if scanner_.current_character_ = '/' then/*{*/

           scan_next_char;

           if scanner_.current_character_ != '*' then/*{*/

              current_token_.type_  := 'SYM';
              current_token_.token_ := '/';

              return;

           end if;/*}*/

           -- Comment "--"
           current_token_.type_  := 'REM';
           current_token_.token_ := '/';

           -- Read comment until '*/'

           loop /*{*/
               current_token_.append(scanner_.current_character_); 

               scan_next_char;

               if scanner_.current_character_ = '*' then

                  current_token_.append('*'); 

                  while scanner_.current_character_ = '*' loop
                  --    Find the first non '*' character.
                  --    This is necessary because a comment can also look like
                  --    /********* */
                  --
                        scan_next_char;

                        if scanner_.current_character_ = '/' then
                           current_token_.append('/'); 
                           scan_next_char;
                           return;
                        end if;
                  end loop;

               end if;

           end loop;/*}*/

        end if;/*}*/

        if scanner_.current_character_ = '''' then/*{*/

           -- Scanning a string
           --
           -- token_ will be including the starting and ending apostrophe (')
           --
           -- If the string contains another apostrophe, the producing '' will
           -- be returned as two characters.


           current_token_.token_ := '''';
           current_token_.type_  := 'STR';


           loop -- Until we find the end of the string.

             scan_next_char;
             current_token_.append(scanner_.current_character_);


             if scanner_.current_character_ = '''' then

                -- Potential end of string.
                --
                -- Check if following character is another '
                
                scan_next_char;

                if scanner_.current_character_ = '''' then
                   -- another ' found.
                   -- so, its' not yet the end of the String
                   current_token_.append('''');

                else
                   -- We're past the end of the string, so we can
                   -- jump out:
                   exit;
                end if;

             end if;

           end loop;

           return;

        end if;/*}*/

        if scanner_.current_character_ = '"'  then/*{*/

           -- Scanning an identifier that is case sensitive (because enclosed
           -- in "..."). This fact is indicated that the token-type is 'Id' rather
           -- than 'ID'.

           current_token_.token_ := '"';
           current_token_.type_  := 'Id';

           scan_next_char;
           while scanner_.current_character_ != '"' loop 
                 current_token_.append(scanner_.current_character_);
                 scan_next_char;
           end loop;
                 
           current_token_.append(scanner_.current_character_);
           scan_next_char;

           return;

        end if;/*}*/

        if isIdentStartChar then/*{*/

           current_token_.type_  := 'ID';

           if scanner_.current_character_ in ('q', 'Q') then/*{*/
              -- Possibly a quoted string (such as q'!foo'bar!')

              current_token_.append(scanner_.current_character_);
              scan_next_char;

              if scanner_.current_character_ = '''' then/*{*/
                 -- It is such a quoted string
                 declare/*{*/
                   character_after_apostrophe char(1);
                 begin

                   current_token_.append('''');
                   current_token_.type_ := 'STR';

                   scan_next_char;
                   character_after_apostrophe := scanner_.current_character_;
                   current_token_.append(character_after_apostrophe);

                   loop -- Until we find the end of the quoted string./*{*/

                     scan_next_char;
                     current_token_.append(scanner_.current_character_);
                     
                     if scanner_.current_character_ = character_after_apostrophe then

                        scan_next_char;
                        current_token_.append(scanner_.current_character_);

                        if scanner_.current_character_ = '''' then

                           -- End of quoted string;
                           exit;
                        end if;

                     end if;

                   end loop;/*}*/
                 end;/*}*/

                 scan_next_char;
                 return;
                
              end if;/*}*/

           end if;/*}*/

           while isIdentChar loop/*{*/

               current_token_.append(scanner_.current_character_);
               scan_next_char;

           end loop;/*}*/

           return;

        end if;/*}*/

        if scanner_.current_character_ = '.' then/*{*/
           current_token_.token_ := '.';

           scan_next_char;

           if isDigit then
              -- Number, starting with .
              completeNumber(isFloat => true);
              return;
           end if;

           current_token_.type_ := 'SYM';
           return;

        end if;/*}*/

        if scanner_.current_character_ = ':' then/*{*/

           current_token_.token_ := ':';
           current_token_.type_  := 'SYM';

           scan_next_char;

           if scanner_.current_character_ = '=' then/*{*/
              current_token_.token_ := ':=';
              scan_next_char;
           end if;/*}*/

           return;

        end if;/*}*/

        if scanner_.current_character_ = '|' then/*{*/
           current_token_.token_ := '|';
           current_token_.type_  := 'SYM';

           scan_next_char;

           if scanner_.current_character_ = '|' then/*{*/
              current_token_.token_ := '||';
              scan_next_char;
           else
              current_token_.token_ := '?';
           end if;/*}*/

           return;

        end if;/*}*/

        if scanner_.current_character_ = '!' then/*{*/

           scan_next_char;

           if scanner_.current_character_ != '=' then
              raise_application_error(-20800, '= expected after !');
           end if;
           
           scan_next_char;

           current_token_.token_ := '!=';
           current_token_.type_  := 'SYM';

           return;
        end if;/*}*/

        if scanner_.current_character_ in ('+', '-', '*', '(', ')', ';', ',', '%', '=', '>', '<') then/*{*/
           current_token_.token_ := scanner_.current_character_;
           current_token_.type_  := 'SYM';
           scan_next_char;

           if    current_token_.token_ in ('<', '>') then/*{*/

              if     scanner_.current_character_ in ('<', '=', '>') then/*{*/

                     -- The following five are allowed:
                     --   o <=
                     --   o >=
                     --   o <<
                     --   o >>
                     --   o <>
                     --
                     -- But this symbol isn't:
                     --   o ><

                     if    current_token_.token_ = '>' and scanner_.current_character_ = '<' then

                           null;

                     else
                   
                           current_token_.token_ := current_token_.token_ || scanner_.current_character_;
                           scan_next_char;

                     end if;

              end if;/*}*/
              
               /*}*/
           elsif current_token_.token_ = '=' then/*{*/

                 if  scanner_.current_character_ = '>' then/*{*/

                     current_token_.token_ := current_token_.token_ || scanner_.current_character_;
                     scan_next_char;
                     
                 end if;/*}*/

           end if;/*}*/

           return;

        end if;/*}*/

        if isDigit then/*{*/
           completeNumber(isFloat => false);
           return;
        end if;/*}*/

        raise_application_error(-20800, 'Unparsable character, character is ascii(' || ascii(scanner_.current_character_) || ') at position ' || (scanner_.next_position_ -1) || '.');
 
    end next_token;/*}*/

end;
/
