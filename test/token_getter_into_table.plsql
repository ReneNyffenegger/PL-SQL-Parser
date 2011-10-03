declare

  s  scanner_varchar2;
  l  lexer;
  t  token_getter_into_table;
  
  procedure check_row (
    exp_r           in number, 
    exp_token       in varchar2, 
    exp_type_       in varchar2, 
    exp_pos         in number, 
    exp_line        in number, 
    exp_pos_in_line in number,
    --
    got_r           in number, 
    got_token       in varchar2, 
    got_type_       in varchar2, 
    got_pos         in number, 
    got_line        in number, 
    got_pos_in_line in number
    
    ) is
  begin

    
    if exp_r = got_r then


       if  exp_token != got_token then
           raise_application_error(-20800, 'Expected token: ' || exp_token || ', token gotten: ' || got_token || ', r: ' || exp_r);
       end if;

       if  exp_type_ != got_type_ then
           raise_application_error(-20800, 'Expected type_: ' || exp_type_ || ', type_ gotten: ' || got_type_ || ', r: ' || exp_r);
       end if;

       if  exp_pos != got_pos then
           raise_application_error(-20800, 'Expected pos: ' || exp_pos || ', pos gotten: ' || got_pos || ', r: ' || exp_r);
       end if;

       if  exp_line != got_line then
           raise_application_error(-20800, 'Expected line: ' || exp_line || ', line gotten: ' || got_line || ', r: ' || exp_r);
       end if;

       if  exp_pos_in_line != got_pos_in_line then
           raise_application_error(-20800, 'Expected pos_in_line: ' || exp_pos_in_line || ', pos_in_line gotten: ' || got_pos_in_line || ', r: ' || exp_r);
       end if;

    end if;


  end check_row;

begin

  s := new scanner_varchar2 (
    q'!create or replace package  
       /* this is a test */ 
       tq84_test 
          procedure dummy; 
       end tq84_test;!'
  );

  l := new lexer(s);
  t := new token_getter_into_table(l);


  for r in (

    select 
            rownum r, 
            t.token.token_          token, 
            t.token.type_           type_, 
            t.token.pos_            pos, 
            t.token.line_           line, 
            t.token.pos_in_line_    pos_in_line
       from token_table t 
      where t.unit_id = t.unit_id_
   order by t.seq

  ) loop

--  dbms_output.put_line(r.r || ' , ''' || r.token || ''', ''' || r.type_ || ''', ' || r.pos || ', ' || r.line || ', ' || r.pos_in_line);

    check_row( 1 , 'create'                      , 'ID' ,   0, 0,  0, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row( 2 , ' '                           , 'WS' ,   6, 0,  6, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row( 3 , 'or'                          , 'ID' ,   7, 0,  7, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row( 4 , ' '                           , 'WS' ,   9, 0,  9, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row( 5 , 'replace'                     , 'ID' ,  10, 0, 10, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row( 6 , ' '                           , 'WS' ,  17, 0, 17, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row( 7 , 'package'                     , 'ID' ,  18, 0, 18, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row( 8 , chr(10) || '       '          , 'WS' ,  25, 0, 25, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row( 9 , '/* this is a test */'        , 'REM',  33, 1,  7, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(10 , chr(10) || '       '          , 'WS' ,  53, 1, 27, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(11 , 'tq84_test'                   , 'ID' ,  61, 2,  7, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(12 , chr(10) || '          '       , 'WS' ,  70, 2, 16, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(13 , 'procedure'                   , 'ID' ,  81, 3, 10, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(14 , ' '                           , 'WS' ,  90, 3, 19, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(15 , 'dummy'                       , 'ID' ,  91, 3, 20, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(16 , ';'                           , 'SYM',  96, 3, 25, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(17 , chr(10) || '       '          , 'WS' ,  97, 3, 26, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(18 , 'end'                         , 'ID' , 105, 4,  7, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(19 , ' '                           , 'WS' , 108, 4, 10, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(20 , 'tq84_test'                   , 'ID' , 109, 4, 11, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);
    check_row(21 , ';'                           , 'SYM', 118, 4, 20, r.r, r.token, r.type_, r.pos, r.line, r.pos_in_line);


  end loop;

    if not t.compare_i('CREAte') then
       raise_application_error(-20800, 'compare_i [create] failed');
    end if;

    t.next_stored_token;

  t.push_state;

    t.next_stored_token;

    if not t.compare_i('or') then
       raise_application_error(-20800, 'compare_i [or] failed');
    end if;

    t.next_stored_token;

    if not t.compare_i(' ', 'WS') then
       raise_application_error(-20800, 'compare_i [WS] failed');
    end if;

    if not t.type_('WS') then
       raise_application_error(-20800, 'type_ [WS] failed');
    end if;

    t.next_stored_program_token;
  t.push_state;
    if not t.compare_i('replace') then
       raise_application_error(-20800, 'compare_i [replace] failed');
    end if;

  t.push_state;
    t.next_stored_program_token;
  t.remove_state;
    t.next_stored_program_token;
  t.remove_state;

    if not t.compare_i('tq84_test') then
       raise_application_error(-20800, 'compare_i [tq84_test] failed');
    end if;

    t.pop_state;
    if not t.compare_i(' ', 'WS') then
       raise_application_error(-20800, 'compare_i [ , WS] failed');
    end if;

  t.next_stored_token;

    if not t.compare_i('or') then
       raise_application_error(-20800, 'compare_i [or] failed');
    end if;

  t.push_state;

    t.next_stored_token;

  t.push_state;

    t.next_stored_token;

  t.push_state;

    t.next_stored_token;

  t.push_state;

    t.next_stored_token;
    if not t.compare_i('package') then
       raise_application_error(-20800, 'compare_i [package] failed');
    end if;

  t.pop_state;
  t.pop_state;
  t.pop_state;

    t.next_stored_token;
    if not t.compare_i('replace') then
       raise_application_error(-20800, 'compare_i [replace] failed');
    end if;

  t.next_stored_program_token;
  t.next_stored_program_token;
  t.next_stored_program_token;
  t.next_stored_program_token;

  
  begin
    if t.token_value_sym !=';' then
       raise_application_error(-20800, 'Token Value SYM ;');
    end if;
  exception
    when errors.not_a_symbol then
      null;
  end;

  t.next_stored_program_token;

  dbms_output.put_line('Test ok: token_getter_into_table');

end;
/


-- select replace(replace(t.token.token_, chr(10), '@'), ' ', '#') from tq84_token_table t;

--rollback;
