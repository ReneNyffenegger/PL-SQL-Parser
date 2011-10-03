create or replace type token_getter_into_table under token_getter (

  unit_id_    number(8),
  seq_        number(8),
  seq_stack_  number_stack,

  constructor function token_getter_into_table(lexer in out lexer) return self as result,

  overriding instantiable final member procedure store_token(token in token),

  overriding instantiable final member procedure next_stored_token,

  overriding instantiable final member procedure push_state,
  overriding instantiable final member procedure pop_state,
  overriding instantiable final member procedure remove_state

) final;
/
