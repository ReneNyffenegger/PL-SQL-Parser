create or replace type tst_result as object (

  records tst_record_t,

  constructor function tst_result(table_ in varchar2, where_ in varchar2) return self as result
  
);
/
