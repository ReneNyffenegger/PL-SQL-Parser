create table nd_initialize_section (
--  TODO_0050: similarity to nd_body
    id number(8) primary key,
    statement_list         not null references nd_statement_list,
    exception_handler_list     null references nd_exception_handler_list
);
