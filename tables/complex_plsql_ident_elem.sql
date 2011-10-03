create table nd_complex_plsql_ident_elem (
  complex_plsql_ident not null references nd_complex_plsql_ident,
  -- for example
  --    abc.def(1).ghi(2, 'abc', 2+3)(3)
  -- consists of six plsql_ident_elem's:
  --   abc
  --   def
  --   (1)
  --   ghi
  --   (2, 'abc', arg_3 => 2+3)
  --   (3)
  plsql_identifier        null references nd_plsql_identifier,
  paran_parameter_list    null references nd_parameter_list,
  check (  ( plsql_identifier is not null and paran_parameter_list is     null ) or
           ( plsql_identifier is     null and paran_parameter_list is not null ) 
        )
);
