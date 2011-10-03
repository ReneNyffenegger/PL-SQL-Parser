create table nd_scalar_datatype (
  id                  number(8)    not null primary key,
  type_               varchar2(8)  not null check (type_ in ('NUMBER', 'VARCHAR2', 'CHAR', 'DATE', 'BOOLEAN', 'DECIMAL')),
  size_               number  (5)      null check (size_ > 0),
  precision           number,
  char_byte_semantics number(1)
);
