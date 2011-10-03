create or replace package tq84_pck_4 as

    -- Items 1 following

    function  f1_pck4(arg3 in varchar2) return number; /*1*/

    procedure p1_pck4(arg1 in out number, arg2 out date); /*2*/

    function  f2_pck4 return tq84_pck_4_table.col_1%type; /*3*/

    procedure p2_pck4 (arg5 number default null, arg_5_1 tq84_pck_4_type default tq84_pck_4_type()); /*4*/

    procedure p3_pck4; /*5*/

    function  f3_pck4 return tq84_pck_4_type; /*6*/

    c_num_pck4 constant number := tq84_pck_3.c_flt_3; /*7*/


    -- This is a "cursor definition" because
    -- it has a select statement.
    cursor cur_pck4 is  /*8*/
           select /*+ hint */ col_1 
             from tq84_pck_4_table;

    function f5_pck4(arg6 in out nocopy number) return boolean; /*9*/

    variable_of_type tq84_pck_4_type; /* 10 */

    type table_of_type is table of sys.anydata; /* 11 */

    type table_of_number_5 is table of number(5); /* 12 */

    type table_type_type_type is  /*13*/
         table of sys.dual.dummy%type 
         index by sys.dual.dummy%type;

    pragma restrict_references (f3_pck4, wnds, wnps); /*14*/

    decimal_2_4 decimal(2,4); /*15*/

--  cursor cur_declaration (p_cur_declaration number) return tq84_pck_4_table%rowtype;

    -- Items 2 following (none)

end tq84_pck_4;
/
