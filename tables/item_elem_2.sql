create table nd_item_elem_2 (
  item_list_2           not null references nd_item_list_2,
  function_declaration      null references nd_function_declaration, -- TODO_0092: Still used????
  procedure_declaration     null references nd_procedure_declaration,
  --  There should probably be a check that there is no function definition for a declare section in a 'package' (as opposed to
  --  a package body).
  function_definition       null references nd_function_definition,
  procedure_definition      null references nd_procedure_definition,
--type_definition           null references nd_type_definition            -- Tahiti Mess: According to 'spec', the elem 2 cannot be a type definition... 
                                                                          -- See also http://stackoverflow.com/questions/7174937/is-oracles-syntax-diagram-for-pl-sql-blocks-wrong
  check (
    nvl2(function_declaration , 1, 0) +
    nvl2(procedure_declaration, 1, 0) +
    nvl2(function_definition  , 1, 0) +
    nvl2(procedure_definition , 1, 0) = 1
  )
);
