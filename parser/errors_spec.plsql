create or replace package errors as

   scanner_eof_reached   exception;
   unknown_source        exception;

-- Thrown in token_getter.token_value_sym:
   not_a_symbol          exception;

-- Thrown in token_getter.token_value_num:
   not_a_number          exception;

-- Thrown in token_getter.token_value_str:
   not_a_string          exception;

-- Thrown in token_getter.token_value:
   not_an_id             exception;

end errors;
/
