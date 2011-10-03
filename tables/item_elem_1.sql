create table nd_item_elem_1 (
  item_list_1           not null references nd_item_list_1,
  --
  cursor_declaration        null references nd_cursor_declaration,
--Tahiti mess: cursor_definition only in item_elem_2! See also http://stackoverflow.com/questions/7174937/is-oracles-syntax-diagram-for-pl-sql-blocks-wrong
  cursor_definition         null references nd_cursor_definition,
  item_declaration          null references nd_item_declaration,
  function_declaration      null references nd_function_declaration,
  procedure_declaration     null references nd_procedure_declaration,
  pragma_                   null references nd_pragma,
  type_definition           null references nd_type_definition,
  --
  check (
      nvl2(cursor_declaration   , 1, 0) + 
      nvl2(cursor_definition    , 1, 0) +
      nvl2(item_declaration     , 1, 0) +
      nvl2(function_declaration , 1, 0) +
      nvl2(procedure_declaration, 1, 0) + 
      nvl2(pragma_              , 1, 0) +
      nvl2(type_definition      , 1, 0) = 1
  )
);
