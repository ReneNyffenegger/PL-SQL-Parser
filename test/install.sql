create table tq84_pck_4_table (
  col_1 number,
  col_2 date
);


create type tq84_pck_4_type as table of number;
/

create table "tq84_pck_5_table" (
  "col_1" number,
  "col_2" varchar2(10),
  "col_3" date,
   col_4  number
);

create type tq84_najanaja as object (
   a number,
   b number
)
/

create type tq84_najanaja_t as table of tq84_najanaja
/

create type tq84_najanaja_tt as table of tq84_najanaja_t
/

create type tq84_najanaja_ttt as table of tq84_najanaja_tt
/

create type tq84_najanaja_tttt as table of tq84_najanaja_ttt
/

create type tq84_najanaja_1 as object (
   t  tq84_najanaja_t,
   c number,
   d number,
   member function object_method(a in number, object_method_b in varchar2) return tq84_najanaja_tttt
);
/

create type tq84_najanaja_1_t as table of tq84_najanaja_1;
/

create type tq84_najanaja_2 as object (
   t  tq84_najanaja_1_t,
   e number,
   f number
);
/

create type tq84_najanaja_2_t as table of tq84_najanaja_2;
/


create type tq84_najanaja_3 as object (
   t  tq84_najanaja_2_t,
   g number,
   h number
);
/

create type tq84_najanaja_3_t as table of tq84_najanaja_3;
/

create type tq84_najanaja_4 as object (
   t  tq84_najanaja_3_t,
   i number,
   j number
);
/

create type tq84_najanaja_4_t as table of tq84_najanaja_4;
/

create type tq84_varchar2_tab as table of number
/


@@ pck_1.plsql
@@ pck_2.plsql
@@ pck_3.plsql
@@ pck_4.plsql
@@ pck_5.plsql
@@ pck_6.plsql
@@ pck_7.plsql

@@ pck_4_body.plsql
