create or replace type scanner_varchar2 under scanner (

     program_ varchar2(4000),

     constructor function scanner_varchar2(program in varchar2) return self as result,

     overriding instantiable final member function read_char(self in out scanner_varchar2) return char

) final instantiable
/
