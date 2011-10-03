create or replace package "tq84_pck_5" as

    cursor "cur_5" is /*{*/
            select  t5."col_1",
                    substr(t5."col_2", 4, 2)
              from "tq84_pck_5_table" t5
             for update of "col_1";/*}*/

    cursor cur_5_1(p_1 in number, p_2 in varchar2, p_3 in date) is/*{*/
           select * 
             from "tq84_pck_5_table"
    --     Just a bunch of mostly stupid relations and the like.
            where  -- Now: a CONDITION
                   --  First logical term within condition:
                        "col_1" = p_1      /* "col_1" = p1   is a 'logical_factor' */                  and                             
                        "col_2" > p_2      
                   --  end  first logical term which is connected by
                   or -- this OR starts the second LOGICAL TERM:
                    "col_3" < p_3                                                                      and -- and's connecting logical_factors.
                not "col_3" != sysdate                                                                 and
                    "col_3" <> to_date("col_2", 'yyyy.mm.dd')                                          and
                    -- TODO: In Testcase: is the following expression correct?
                    sysdate >= to_date("col_2", 'yyyy.mm.dd') + -2.09*-3.2*-4 - -5*6.54321* (700.0+333.3-400)*8 and
                    '14''39' || 2.01 <= 14.2                                                              and /* next logical factor */ ( /* <-- This paranthes starts/opens a condition */
                                                     (2+3)/4 > 9/(8+1) or
                                                /*   ^^^^^^^^^^^^^^^^^----+  */
                                                /*   | logical term,      |  */
                                                /*   | logical factor and |  */
                                                /*   | relation           |  */
                                                /*   +--------------------+  */

                                                     (5)+(9*4) <= (8/3)+2
                                            )  /* <-- condition closed */                              and
                    ( ( to_char("col_3") = 'BLABLA' and 2 = 3 ) or
                      ( to_char("col_3")!= 'BLABLA' and 2!= 3 ) )
--            order by "col_1", col_4
    ;/*}*/

    cursor cur_5_2 is -- Test Outer Join Symbol/*{*/
      select a.*, b.*,
        min(a.dummy || 'foo') as min_dummy_foo,
        5.1 * row_number() over (partition by b.dummy order by a.dummy) as rrr,
        case a.dummy when '#'            then 1.01 when           '*' then 2.02 else 3.03 end simple_case_expression,
        case when a.dummy = '!'          then 4.04 
             when a.dummy = '*'          then 5.05 
             when a.dummy = 'strawberry' then (select 6.06 as scalar_subquery_expression from dual)
             else 7.07 end searched_case_expression
      from 
        dual a, 
        dual b
      where
        a.dummy = b.dummy ( + ) or
        b.dummy in (chr(20), 'F') or
        b.dummy not like 'NOT-LIKE' or
        b.dummy is null;/*}*/

    cursor cur_5_3 is /*{*/
      select col53, count(1) from (
         select dummy COL53 from dual dual_cur_5_3
      )
      where 
        col53 = 'COL53VALUE'
      group by col53;/*}*/

    cursor cur_5_4 is /*{*/
      select col53, count(1) from (
         select dummy COL53 
           from dual dual_cur_5_3
          where dummy = 'cur_5_4_dummy' and 345678 = (
            select max(rownum) from dual
          )
      )
      group -- This test case to ensure that the keyword 'group' is not falsly recognized as an alias.
      by col53; /*}*/

    cursor cur_5_5 is
      select rownum from dual
       where 1 = 1
       start with dummy = 'X'
       connect by rownum < 50
     union (
       select rownum from dual dual_loj_right join dual dual_join using (dummy) left outer join dual dual_loj_left on dual_loj_left.dummy = dual_loj_left.dummy
        where 280870=280871 and 
              not exists (select null as exists_condition_test from dual)
      );

end "tq84_pck_5";
/
