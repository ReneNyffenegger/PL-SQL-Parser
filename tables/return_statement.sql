create table nd_return_statement (
  id             number(8) primary key,
  -- TODO_0040: is this correct that it is either expr or logical_term_list?
  --            Maybe an 'expr_or_logical_term_list' node is warranted?
  expr                null references nd_expression,
  logical_term_list   null references nd_logical_term_list,
  check ( ( expr is     null and logical_term_list is not null ) or
          ( expr is not null and logical_term_list is     null )
        )
);
