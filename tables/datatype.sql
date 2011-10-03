create table nd_datatype (
  id               number(8)    not null primary key,
  scalar_datatype                   null references nd_scalar_datatype,
  typename_plsql_identifier         null references nd_plsql_identifier, 
  rowtype_                          number(1) null check (rowtype_ in (1)), -- Set for example for something like 'subtype xyz is foo%ROWTYPE'
  type_                             number(1) null check (type_    in (1))
  --
  -- TODO_0078: Reasonable check condition.
--check ( ( scalar_datatype is not null and  typename_plsql_identifier is     null ) or
--        ( scalar_datatype is     null and  typename_plsql_identifier is not null )
--      ),
--check ( (scalar_datatype is not null and typename_plsql_identifier is      null and    rowtype_ is     null and type_ is     null ) or
--        (scalar_datatype is     null and typename_plsql_identifier is not  null and ( (rowtype_ is not null and type_ is     null ) or
--                                                                                      (rowtype_ is     null and type_ is not null )
--                                                                                    )                                                                            
--        )
--      )
);
