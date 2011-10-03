create or replace package tq84_pck_3

  -- authid definer

as

    c_foo_3 constant varchar2(20) := 'A constant';
    c_bar_3 constant varchar2(40) := 'Another constant';
    c_num_3 constant number       := -42;
    c_flt_3 constant number(5,2)  := 22.8;
    c_dat_3 constant date         := to_date('20.10.2010', 'dd.mm.yyyy');
--  c_prc constant number(5,2)  := 4.2;
    c_chr_2 constant char(2)      := 'XY';

end tq84_pck_3;
/
