create or replace package tst_parse_tree as

    procedure dive_from_pk_to_fk(from_tab in varchar2, tab in varchar2, pk in number, indent_level in number);
    procedure dive_from_fk_to_pk(from_tab in varchar2, tab in varchar2, pk in number, indent_level in number);

end tst_parse_tree;
/
