create or replace package body tq84_pck_4 as

    function bbbbbb return boolean is begin
      return true;
    end;

    function  f1_pck4(arg3 in varchar2) return number is /*1*//*{*/
      f1_pck4_cnt number;
      f1_pck4_max varchar2(40);
      f1_pck4_foo varchar2(40);
      sysdate_    date /* TODO: := sysdate */;

      the_statement varchar2(500);
      the_result    number;

      another_result tq84_najanaja_t;

      function boolean_function(boolean_function_arg_1 in number) return boolean is/*{*/
        uuuuuuuu tq84_pck_4_type := tq84_pck_4_type();
      begin
        uuuuuuuu.extend;
        uuuuuuuu.extend;
        uuuuuuuu.extend;
        uuuuuuuu.extend;
        uuuuuuuu.extend;
        uuuuuuuu.extend;
        uuuuuuuu(1+2+3) := 42424242;

        return true;
      end boolean_function;/*}*/

    begin 

      select count(*), max(dummy)
        into f1_pck4.f1_pck4_cnt,
                     f1_pck4_max
        from dual
       where 2=2
       having count(*) > 1;

       select tq84_najanaja(1,2) bulk collect into another_result from dual;

       case f1_pck4_cnt when 1 then dbms_output.put_line('case-expression(1)'); null; f1_pck4_max := f1_pck4_max + 1;
                        when 2 then null;
                        else null; null; null;
       end case;
                              
       case when f1_pck4_cnt = 1 then null; dbms_output.put_line('case-expression(2)'); f1_pck4_max := f1_pck4_max + 1;
            when f1_pck4_cnt = 2 then null;
            else null; 
                 if boolean_function(5) or false then
                    if 2=2 then
                       if 9=9 then
                          null;
                       end if;
                    end if;
                 end if;
                 null;
       end case; -- TODO: LABEL after case.

       f1_pck4_foo := f1_pck4_cnt || f1_pck4_max;

       if not boolean_function(5) and boolean_function(6) or (1=2) then
          dbms_output.put_line('xyzabc');
       end if;

       return to_number(arg3) || '-' || f1_pck4_foo;

     exception 
       when no_data_found or too_many_rows then
            p1_pck4(f1_pck4_max, arg2 => sysdate_);

            if boolean_function(2+3) then
               delete from tq84_pck_4_table where col_1 = 1 and col_2 = trunc(sysdate);
            end if;

       when zero_divide then

            if    1=2 then 
                  null;

                  case when boolean_function(4) then
                    return 2;
                  else
                    return 1;
                  end case;

                  null;
            elsif boolean_function(1) or boolean_function(2) then
             
                  execute immediate the_statement using out the_result;
                  null;

                  update tq84_pck_4_table set col_1 = 4+5+9, col_2 = sysdate + 2 where col_2 between sysdate - 1 and sysdate + 1;
                  
            elsif boolean_function(1) then
                  
                  insert into tq84_pck_4_table values (1, sysdate);
                  insert into tq84_pck_4_table (col_1, col_2) values (2, sysdate+1);

                  

            end if;

       when others then
            null;
            null;

    end f1_pck4;/*}*/

    procedure p1_pck4(arg1 in out number, arg2 out date) is /*2*//*{*/
      pragma autonomous_transaction;
      tq84_pck_5_cur_5_row "tq84_pck_5".cur_5_1%rowtype;
      cnt number;
    begin

      select count(*) into cnt from (
         select * from dual
           start with 1=0
           connect by dummy = prior dummy
           order siblings by dummy
      );
      

      <<MYLABEL>>
      loop

        if false then
           exit MYLABEL;
        end if;

        exit MYLABEL;
      end loop MYLABEL;

      open "tq84_pck_5".cur_5_1(4, p_2 => 'foo_bar', p_3 => sysdate);
      fetch "tq84_pck_5".cur_5_1 into  tq84_pck_5_cur_5_row;
      close "tq84_pck_5".cur_5_1;

    end p1_pck4;/*}*/

    function  f2_pck4 return tq84_pck_4_table.col_1%type /* deterministic pipelined*/ is /*3*//*{*/
      var_exec_immediate varchar2(50) := 'select count(*) from dual';
      var_exec_immediate_into number;
    begin
      -- TODO: in Testcase: check, if this is a logical_term.
        for f2_pck4_index in 20/10 .. 20/5 loop


            for select_loop in (

                 with subquery_factoring_1 as (
                   select * from dual minus
                   select * from dual
                 ),
                 subquery_factoring_2 as (
                   select * from dual
                 )
                 select subquery_factoring_1.dummy from subquery_factoring_1, subquery_factoring_2

            ) loop

                -- TODO: LABEL can be here.
                declare
                  declared number;
                begin
                  null;
                  null;

                  begin 
                    null;
                  end;

                  null;
                end;

            end loop;



            for record_cur_pck4 in cur_pck4 loop

                null;
                execute immediate 'delete execute_immediate_table';

            end loop;

            for record_2 in (
                  select * from dual join (select * from dual) using (dummy)
                  
                  ) loop

                execute immediate var_exec_immediate into var_exec_immediate_into;

            end loop;

        end loop FOO_BAR_BAZ;
        return null;
    end f2_pck4;/*}*/

    procedure p2_pck4 (arg5 number default null, arg_5_1 tq84_pck_4_type default tq84_pck_4_type()) is /*4*//*{*/
    begin
        null;
    end p2_pck4;/*}*/

    procedure p3_pck4 is /*5*//*{*/
      tttt tq84_najanaja_4_t;
      tttt_tttt tq84_najanaja_tttt;
    begin

      tttt(1).j                     :=  9;
      tttt(1).t(2).h                := 10;
      tttt(1).t(2).t(3).e           := 20;
      tttt(1).t(2).t(3).t(4).c      := 30;
      tttt(1).t(2).t(3).t(4).t(5).a := 60;

      tttt_tttt(1)(2)(3)(4).a := 99;

    end p3_pck4;/*}*/

    function  f3_pck4 return tq84_pck_4_type is /*6*//*{*/
          v_sys_refcursor sys_refcursor;
          table_thing tq84_najanaja_t;
    begin

        open v_sys_refcursor for select * from  table (cast (table_thing as tq84_najanaja_t)) order by a;

        while v_sys_refcursor%found loop
              null;
        end loop;

--  TODO: also with ( in front of the table!
--      open v_sys_refcursor for select * from (table (cast (table_thing as tq84_najanaja_t)));


        return null;
    end f3_pck4;/*}*/

    function f5_pck4(arg6 in out nocopy number) return boolean is/*{*/
      qqqqqqqq number;


      t1t1t1 tq84_najanaja_tttt;

      tixtixtix  tq84_varchar2_tab;

--    dummy1 tq84_najanaja_2;
--    dummy2 tq84_najanaja_1_t;
--    dummy3 tq84_najanaja_1;
--    dummy4 tq84_najanaja_tttt;

      procedure three_arguments(aaa in varchar2, bbb in varchar2, ccc in varchar2) is/*{*/
        vvvvvvvv tq84_pck_4_type := tq84_pck_4_type();
      begin

         for i in 1 .. vvvvvvvv.count loop
            null;
         end loop;
      end three_arguments;/*}*/

      function nested_nested return tq84_najanaja_2 is/*{*/
      begin
        return tq84_najanaja_2(null, null, null);
      end nested_nested;/*}*/

    begin

      if  5=10 then
          return not f5_pck4(qqqqqqqq);
      end if;

--    dummy1   := nested_nested;
--               |
--               +----------- tq84_najanaja_2 
--
--
--    dummy2   := nested_nested().t;
--                               |   
--                               +-------- tq84_najanaja_1_t
--
--    dummy3   := nested_nested().t(4);
--                                 |
--                                 +------------ tq84_najanaja_1;
--
--    dummy4   := nested_nested().t(4).object_method(99+99, 'ninety-nine');
--                                     |
--                                     +---------------- tq84_najanaja_tttt

      qqqqqqqq := nested_nested().t(4).object_method(99+99, object_method_b => 'ninety-nine')(100)(200)(300)(400).a;


      forall ixixix in 1 .. tixtixtix.count
             insert into tq84_pck_4_table values (tixtixtix(ixixix), sysdate);

--    t1t1t1 := nested_nested().t(2)(3).object_method(99+99, 'ninety-nine')(100)(200)(300)(400);

      return lower(substr(ltrim('lower-substr-ltrim'),1,2)) = 'strawberry';

     exception when others then
          f5_pck4.three_arguments(   'aaa'   , 'bbb'   , 'ccc'   );
          return true;

    end f5_pck4;/*}*/

end tq84_pck_4;
/
