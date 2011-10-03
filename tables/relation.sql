create table nd_relation (
  id           number(8)   not null primary key,
  expression_1             not null references nd_expression,
  relop        varchar2(2)     null check (relop in ('>', '<', '!=',  '<>', '!=', '=', '>=', '<=')),
  expression_2                 null references nd_expression
);
