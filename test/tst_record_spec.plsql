create or replace type tst_record force as object (

  fields       tst_field_t,

  constructor function tst_record(table_ in varchar2, where_ in varchar2) return self as result

);
/

create or replace type tst_record_t force as table of tst_record;
/
