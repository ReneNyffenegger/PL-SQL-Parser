create table nd_parameter_declaration (
  id                           number(8)    not null primary key,  -- TODO_0096: Is this ID actually used?
                                                                   -- It seems as though it is used for ordering the parameters (in
                                                                   -- which case it could probably better be named seq).
  parameter_declaration_list                not null references nd_parameter_declaration_list,
  name                         varchar2(30) not null,
  in_                          number(1)        null check(in_      in (1)),
  out_                         number(1)        null check(out_     in (1)),
  nocopy_                      number(1)        null check(nocopy_  in (1)),
  datatype                                      null references nd_datatype,
  default_                     number(1)        null check(default_ in (1)),
  expression                                    null references nd_expression,
  --
  constraint nd_parameter_declaration_c1 check (  nocopy_ is null or default_ is null),
  --
  constraint nd_parameter_declaration_c2 check ( (default_ is not null and expression is not null ) or
                                                 (default_ is     null and expression is     null )),
  --
  constraint nd_parameter_declaration_c3 check ( (out_     is     null or  expression is     null ))
);
