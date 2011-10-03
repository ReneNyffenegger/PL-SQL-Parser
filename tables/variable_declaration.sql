create table nd_variable_declaration (
--  TODO_0048
--    A variable declaration could be 'the same' as a
--    constant declarion without the additional 'constant'.
    id                  number primary key,
    name                varchar2(30)    not null,
    datatype                            not null references nd_datatype   on delete cascade,
    not_null            number(1)           null,
--
--  expression is not null if the variable is initialized with an expression.
--  otherwise, it's null
    expression                              null references nd_expression on delete cascade
);
