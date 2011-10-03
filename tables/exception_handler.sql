create table nd_exception_handler (
  -- http://download.oracle.com/docs/cd/E11882_01/appdev.112/e17126/exception_handler.htm#i33826
  exception_handler_list  not null references nd_exception_handler_list,
  -- WHEN
  exception_list              null references nd_exception_list,
  others_                     number(1) null check (others_ in (1)),
  -- THEN
  statement_list          not null references nd_statement_list,
  check ( (exception_list is     null and others_ is not null ) or
          (exception_list is not null and others_ is     null )
        )
);
