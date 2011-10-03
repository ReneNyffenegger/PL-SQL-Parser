create table nd_select_elem (
--id number(8) not null primary key
  select_list     not               null references nd_select_list,
--plsql_identifier                  null references nd_plsql_identifier,
--star_               number(1)     null check(star_ in (1)),
  expression                        null references nd_expression,
--function_expression               null references nd_function_expression,
  as_                 number(1)     null check(as_ in (1)),
  c_alias             varchar2(30)  null,
  --
  check ( (as_ is not null and c_alias is not null) or
          (as_ is     null                        )
        ) ,
-- star_  check ( (star_          is not null and c_alias is null) or
-- star_          (star_          is     null)
-- star_),
  check ( --(plsql_identifier is not null and   expr       is     null and function_expression is     null) or
          --(plsql_identifier is     null and   expression is not null and function_expression is     null) or
          (/*plsql_identifier is     null and */expression is not null /*and function_expression is not null*/) /* star_ or
          (star_ is not null) */
        ) 
);
