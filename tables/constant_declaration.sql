create table nd_constant_declaration (
--TODO__0048
--  A constant declaration could be 'the same' as a
--  variable declarion with the additional 'constant'.
  id                  number primary key,
  name                varchar2(30)    not null,
  datatype                            not null references nd_datatype   on delete cascade,
  not_null            number(1)           null,
  expression                          not null references nd_expression on delete cascade
);
