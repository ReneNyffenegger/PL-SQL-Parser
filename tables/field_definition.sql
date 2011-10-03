create table nd_field_definition (
-- http://download.oracle.com/docs/cd/E11882_01/appdev.112/e17126/record_definition.htm#CJAJCHJA (called: field_definition)
   field_definition_list       not null references nd_field_definition_list,
   name                        varchar2(30) not null,
   datatype                    not null references nd_datatype -- Implicit order via "order by datatype"
-- not_null                    number(1) not null check (not_null in (0, 1)),
);
