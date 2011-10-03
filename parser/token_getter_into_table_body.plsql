create or replace type body token_getter_into_table as

  constructor function token_getter_into_table(lexer in out lexer) return self as result is/*{*/
  begin

      select token_sequence.nextval into unit_id_  from dual;

      seq_       := 0;
      seq_stack_ := number_stack();

      self.read_tokens(lexer);

      seq_     := 0;
      return;

  end token_getter_into_table;/*}*/

  overriding instantiable final member procedure store_token(token in token) is begin/*{*/

       insert into token_table values (unit_id_, seq_, token);
       seq_ := seq_ + 1;

  end store_token;/*}*/

  overriding instantiable final member procedure next_stored_token is/*{*/
  begin

      seq_ := seq_ + 1;

      select token into current_token_ from token_table where unit_id = unit_id_ and seq = seq_;

  end next_stored_token;/*}*/

  overriding instantiable final member procedure push_state is/*{*/
  begin
      seq_stack_.push(seq_);
  end push_state;/*}*/

  overriding instantiable final member procedure pop_state is/*{*/
  begin
      seq_ := seq_stack_.pop;
      select token into current_token_ from token_table where unit_id = unit_id_ and seq = seq_;
  end pop_state;/*}*/

  overriding instantiable final member procedure remove_state is/*{*/
      dummy number;
  begin
      dummy := seq_stack_.pop;
  end remove_state;/*}*/

end;
/
