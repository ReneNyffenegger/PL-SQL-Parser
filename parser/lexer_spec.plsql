create or replace type lexer as object (
   scanner_             scanner,

-- The token that was read with the last call of -> next_token.
-- If -> next_token encounters the EOF, current_token_ will
-- be set to null.
   current_token_       token,

   current_line_        number(5),
   current_pos_in_line_ number(4),

   constructor function lexer(scanner in scanner) return self as result,

   final member procedure scan_next_char,

   final member function isWhiteSpace      return boolean,
   final member function isIdentStartChar  return boolean,
   final member function isIdentChar       return boolean,
   final member function isDigit           return boolean,
   final member function isAlpha           return boolean,

   final member procedure completeNumber(isFloat in boolean),

   final instantiable member procedure next_token(self in out lexer)

) final instantiable;
/
