create table nd_null_condition (
  id number(8) primary key,
  expression         null references nd_expression,
  not_               number(1) check (not_ in (1))
);
