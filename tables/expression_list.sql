create table nd_expression_list (
--An 'expression list' is a list of expressions, seperated by
--commas, not within paranthesis.
--Usually used for constructs such as
--  abc.def(expression_list_elem_1, expression_list_elem_2...)
  id number(8) not null primary key 
);
