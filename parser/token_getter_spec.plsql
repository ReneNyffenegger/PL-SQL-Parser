create or replace type token_getter as object (

   current_token_ token,

   instantiable final member procedure read_tokens(self in out token_getter, lexer in out lexer),
  
-- Compare token value case insensitivly. By default, token type is checked againts 'ID'.
-- Return true if matches, false if it doesn't match.
   instantiable final member function  compare_i(self in out token_getter, token_value in varchar2, token_type in varchar2 := 'ID') return boolean,

   instantiable final member function type_(self in out token_getter, token_type in varchar2) return boolean,

   instantiable final member function type_(self in out token_getter) return varchar2,

   not instantiable not final member procedure store_token(token in token),

-- Moves to the next token.
   not instantiable not final member procedure next_stored_token,

-- Moves to the next token that is not a 'REM' or a 'WS'
   instantiable final member procedure next_stored_program_token,

-- Checks if the token type is ID. If so, it returns the token (value).
-- If it is not ID, it throws a errors.not_an_id exception.
   instantiable final member function  token_value(self in out token_getter) return varchar2,

-- Checks if the token type is ID or Id. If so, it returns the token (value).
-- If it is neither ID nor Id, it throws an error (TODO_0072: which one?)
-- If it is an Id, it returns the Id within quotes.
   instantiable final member function  token_value_id(self in out token_getter) return varchar2,

-- Checks if the token type is SYM. If so, it returns the token (value).
-- If it is not SYM, it throws a errors.not_a_symbol exception.
   instantiable final member function  token_value_sym(self in out token_getter) return varchar2,

   instantiable final member function  token_value_num(self in out token_getter) return number,

   instantiable final member function  token_value_str(self in out token_getter) return varchar2,

-- Return a string that shows the current token where it was found in '@ line/pos' form.
   instantiable final member function  what_and_where(self in out token_getter) return varchar2,


-- The following two procedures allow to push and pop the (current-token)
-- state of the token getter. That is, after push_state, a series of calls
-- to -> next_stored_program_token can be made and then a pop_state can
-- be made in order to return to the current_token that was 'active' at the
-- time of the push_state.
   not instantiable not final member procedure push_state,
   not instantiable not final member procedure pop_state,

-- If after a push_state the pop_state is not needed, we
-- can forget about the pushed state with
   not instantiable not final member procedure remove_state
  
)  not instantiable not final;
/
