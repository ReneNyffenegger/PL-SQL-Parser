create table nd_cursor_definition (
-- 
--   Note: There is also a 
--         cursor_declaration
--
  id                         number(8)     not null primary key,
  name                       varchar2(30)  not null,
  parameter_declaration_list                   null references nd_parameter_declaration_list,
  rowtype_returned           varchar2(30)  , -- TODO_0077 used?
  select_statement                         not null references nd_select_statement
);
