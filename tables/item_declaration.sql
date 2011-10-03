create table nd_item_declaration (
  id                    number(8)  not null primary key,
  constant_declaration                 null references nd_constant_declaration on delete cascade, 
  exception_declaration                null references nd_exception_declaration,
  variable_declaration                 null references nd_variable_declaration,
  check (
    (constant_declaration is not null and exception_declaration is     null and variable_declaration is     null) or
    (constant_declaration is     null and exception_declaration is not null and variable_declaration is     null) or
    (constant_declaration is     null and exception_declaration is     null and variable_declaration is not null) 
  )
);
