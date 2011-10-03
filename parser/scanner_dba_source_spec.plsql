create or replace type scanner_dba_source under scanner (

  cursor_               integer,

  current_text_         varchar2(4000),

  next_line_            number(7),
  next_pos_in_text_     number(5),

  -- NOTE: all parameters (owner_, name_ and type_) are case sensitive!
  constructor function scanner_dba_source(owner_ in varchar2, name_ in varchar2, type_ in varchar2) return self as result,

  overriding instantiable final member function read_char(self in out scanner_dba_source) return char

)
/
