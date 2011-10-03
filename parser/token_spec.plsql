create or replace type token as object (

  token_       clob, 
  --
  --           TODO_0001: There should also be a type_ HINT.
  type_        varchar2(   5),  -- 'WS', 'REM', 'FLT', 'NUM', 'ID', 'Id'

  pos_         number(6),
  line_        number(5),
  pos_in_line_ number(4),

  constructor function token(pos in number, line in number, pos_in_line in number) return self as result,
  final member procedure append(self in out token, c in char)


) final instantiable;
/
