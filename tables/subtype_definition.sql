create table nd_subtype_definition (
  id            number(8)       primary key,
  name          varchar2(30)    not null,
  basetype                      not null references nd_datatype
  -- TODO_0103 CHARACTER SET
  -- TODO_0104 'NOT NULL' constraint
);
