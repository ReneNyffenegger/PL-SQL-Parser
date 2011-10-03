declare

  s  scanner_varchar2 := scanner_varchar2(

     '  IDentifier1.IDEnT2'        || chr(10) ||/*{*/
     '+42'                         || chr(13) || chr(10) ||
     ' func(bla);'                 || chr(10) ||
     '  here -- is a comment'      || chr(13) || chr(10) ||
     '  and /* another # ! ( / * ' || chr(10) ||
     'comment */ '                 || chr(13) || chr(10) || 
     'b:=c;'                       || chr(10) ||
     '  label: goto label;'        || chr(10) ||
     '  string'                    || chr( 9) || ' := ''stringvalue'' || ''more''''string'';' || chr(10) ||
     '  qab :=  4.4;q := .98;q1:=q''!foo'' ! bar!'';' || chr(10) ||
     '  "xne"."two" (42.0,-24)'    || chr(10) ||
     '  C_FOO foo_tab%ROWTYPE > <  bcd<=efg>=hij   != <> << >> >< => '/*}*/

  );

  l lexer := lexer(s);

  procedure check_token(type_ in varchar2, position_ in number, line_ in number, pos_in_line_ in number, token_ in varchar2) is/*{*/
  begin

      if l.current_token_.type_ != type_ then
         raise_application_error(-20800, 'expected type: ' || type_ || ', but is: ' || l.current_token_.type_ || ', line_: ' || line_ || ', pos_in_line_: ' || pos_in_line_);
      end if;

      if nvl(l.current_token_.pos_,-1) != position_ then
         raise_application_error(-20800, 'expected position: >' || position_ || '<, but is: >' || l.current_token_.pos_ || '<');
      end if;

      if nvl(l.current_token_.line_,-1) != line_ then
         raise_application_error(-20800, 'expected line: >' || line_ || '<, but is: >' || l.current_token_.line_ || '<');
      end if;

      if nvl(l.current_token_.pos_in_line_,-1) != pos_in_line_ then
         raise_application_error(-20800, 'expected pos in line: >' || pos_in_line_ || '<, but is: >' || l.current_token_.pos_in_line_ || '<');
      end if;

      if l.current_token_.token_ != token_ then
         raise_application_error(-20800, 'expected token: ' || token_ || ', but is: ' || l.current_token_.token_ || ' pos: ' || l.current_token_.pos_in_line_ || ', line: >' || l.current_token_.line_ || '<');
      end if;

      l.next_token;

  end check_token;/*}*/

begin

  check_token('WS'  ,   0, 0,  0, '  ');                       -- Line 0/*{*/
  check_token('ID'  ,   2, 0,  2, 'IDentifier1');
  check_token('SYM' ,  13, 0, 13, '.');
  check_token('ID'  ,  14, 0, 14, 'IDEnT2');
  check_token('WS'  ,  20, 0, 20, chr(10));
  /*}*/
  check_token('SYM' ,  21, 1,  0, '+');                        -- Line 1/*{*/
  check_token('NUM' ,  22, 1,  1, '42');
  check_token('WS'  ,  24, 1,  3, chr(13) || chr(10) || ' ');
  /*}*/
  check_token('ID'  ,  27, 2,  1, 'func');                     -- Line 2/*{*/
  check_token('SYM' ,  31, 2,  5, '(');
  check_token('ID'  ,  32, 2,  6, 'bla');
  check_token('SYM' ,  35, 2,  9, ')');
  check_token('SYM' ,  36, 2, 10, ';');
  check_token('WS'  ,  37, 2, 11, chr(10) || '  ');
  /*}*/
  check_token('ID'  ,  40, 3,  2, 'here');                     -- Line 3/*{*/
  check_token('WS'  ,  44, 3,  6, ' ');
  check_token('REM' ,  45, 3,  7, '-- is a comment' || chr(13) || chr(10));
  check_token('WS'  ,  62, 4,  0, '  ');
  /*}*/
  check_token('ID'  ,  64, 4,  2, 'and');                      -- Line 4/*{*/
  check_token('WS'  ,  67, 4,  5, ' ');
  check_token('REM' ,  68, 4,  6, '/* another # ! ( / * ' || chr(10) || 'comment */');
  /*}*/
  check_token('WS'  , 100, 5,  10, ' ' || chr(13) || chr(10)); -- Line 5/*{*/
  /*}*/
  check_token('ID'  , 103, 6,   0, 'b');                       -- Line 6/*{*/
  check_token('SYM' , 104, 6,   1, ':=');
  check_token('ID'  , 106, 6,   3, 'c');
  check_token('SYM' , 107, 6,   4, ';');
  check_token('WS'  , 108, 6,   5, chr(10) || '  ');
  /*}*/
  check_token('ID'  , 111, 7,   2, 'label');                   -- Line 7/*{*/
  check_token('SYM' , 116, 7,   7, ':');
  check_token('WS'  , 117, 7,   8, ' ');
  check_token('ID'  , 118, 7,   9, 'goto');
  check_token('WS'  , 122, 7,  13, ' ');
  check_token('ID'  , 123, 7,  14, 'label');
  check_token('SYM' , 128, 7,  19, ';');
  check_token('WS'  , 129, 7,  20, chr(10) || '  ');
  /*}*/
  check_token('ID'  , 132, 8,   2, 'string');                  -- Line 8/*{*/
  check_token('WS'  , 138, 8,   8, chr(9) || ' ');
  check_token('SYM' , 140, 8,  10, ':=');
  check_token('WS'  , 142, 8,  12, ' ');
  check_token('STR' , 143, 8,  13, '''stringvalue''');
  check_token('WS'  , 156, 8,  26, ' ');
  check_token('SYM' , 157, 8,  27, '||');
  check_token('WS'  , 159, 8,  29, ' ');
  check_token('STR' , 160, 8,  30, '''more''''string''');
  check_token('SYM' , 174, 8,  44, ';');
  /*}*/
  check_token('WS'  , 175, 8,  45, chr(10) || '  ');           -- Line 9/*{*/
  check_token('ID'  , 178, 9,   2, 'qab');
  check_token('WS'  , 181, 9,   5, ' ');
  check_token('SYM' , 182, 9,   6, ':=');
  check_token('WS'  , 184, 9,   8, '  ');
  check_token('FLT' , 186, 9,  10, '4.4');
  check_token('SYM' , 189, 9,  13, ';');
  check_token('ID'  , 190, 9,  14, 'q');
  check_token('WS'  , 191, 9,  15, ' ');
  check_token('SYM' , 192, 9,  16, ':=');
  check_token('WS'  , 194, 9,  18, ' ');
  check_token('FLT' , 195, 9,  19, '.98');
  check_token('SYM' , 198, 9,  22, ';');
  check_token('ID'  , 199, 9,  23, 'q1');
--check_token('WS'  , 201, 9,  25, ' ');
  check_token('SYM' , 201, 9,  25, ':=');
  check_token('STR' , 203, 9,  27, 'q''!foo'' ! bar!''');
  check_token('SYM' , 218, 9,  42, ';');
  check_token('WS'  , 219, 9,  43, chr(10) || '  ');
/*}*/
  check_token('Id'  , 222,10,   2, '"xne"');                   -- Line 10/*{*/
  check_token('SYM' , 227,10,   7, '.');
  check_token('Id'  , 228,10,   8, '"two"');
  check_token('WS'  , 233,10,  13, ' ');
  check_token('SYM' , 234,10,  14, '(');
  check_token('FLT' , 235,10,  15, '42.0');
  check_token('SYM' , 239,10,  19, ',');
  check_token('SYM' , 240,10,  20, '-');
  check_token('NUM' , 241,10,  21, '24');
  check_token('SYM' , 243,10,  23, ')');
  check_token('WS'  , 244,10,  24, chr(10) || '  ');
/*}*/
  check_token('ID'  , 247,11,   2, 'C_FOO');                   -- Line 11/*{*/
  check_token('WS'  , 252,11,   7, ' ');
  check_token('ID'  , 253,11,   8, 'foo_tab');
  check_token('SYM' , 260,11,  15, '%');
  check_token('ID'  , 261,11,  16, 'ROWTYPE');
  check_token('WS'  , 268,11,  23, ' ');
  check_token('SYM' , 269,11,  24, '>');
  check_token('WS'  , 270,11,  25, ' ');
  check_token('SYM' , 271,11,  26, '<');
  check_token('WS'  , 272,11,  27, '  ');
  check_token('ID'  , 274,11,  29, 'bcd');
  check_token('SYM' , 277,11,  32, '<=');
  check_token('ID'  , 279,11,  34, 'efg');
  check_token('SYM' , 282,11,  37, '>=');
  check_token('ID'  , 284,11,  39, 'hij');
  check_token('WS'  , 287,11,  42, '   ');
  check_token('SYM' , 290,11,  45, '!=');
  check_token('WS'  , 292,11,  47, ' ');
  check_token('SYM' , 293,11,  48, '<>');
  check_token('WS'  , 295,11,  50, ' ');
  check_token('SYM' , 296,11,  51, '<<');
  check_token('WS'  , 298,11,  53, ' ');
  check_token('SYM' , 299,11,  54, '>>');
  check_token('WS'  , 301,11,  56, ' ');
  check_token('SYM' , 302,11,  57, '>' );
  check_token('SYM' , 303,11,  58, '<' );
  check_token('WS'  , 304,11,  59, ' ');
  check_token('SYM' , 305,11,  60, '=>' ); 
  check_token('WS'  , 307,11,  62, ' ');--/*}*/

  if l.current_token_ is not null then/*{*/
     raise_application_error(-20800, 'Current token should be null but is: ' || l.current_token_.token_);
  end if;/*}*/

  dbms_output.put_line('Test ok: lexer varchar2');

end;
/
