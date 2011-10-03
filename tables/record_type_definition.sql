create table nd_record_type_definition (
  id number(8)                not null primary key,
  name varchar2(30)           not null,
  field_definition_list       not null references nd_field_definition_list
);
