create or replace type tst_field force as object (

  column_name    varchar2(30),
  table_name     varchar2(30),

  field_value    varchar2(1000),

  member function foreign_key_table return varchar2

) final;
/

create or replace type tst_field_t force as table of tst_field;
/
