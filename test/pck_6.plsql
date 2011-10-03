create or replace package tq84_pck_6 as

    type some_type       is table of number                index by binary_integer;
    type some_other_type is table of varchar2(10) not null index by string(5);
    type record_type     is record(elem_num number, elem_vc varchar2(20), elem_dt date);

    type ref_cursor_type is ref cursor return record_type;  -- Strong declaration

    type ref_cursor_weak is ref cursor;                     -- Weak declaration
    -- TODO: type "name_within_quotes" is ...  
end tq84_pck_6;
/
