create table nd_table_collection_expression (
  id number(8) primary key,
  collection_expression not null references nd_expression
  -- 
  -- TODO_0105: it seems as though the table_collection_expression can have an outer join symbol:
  --   from TABLE (.....) (+)
  --
);
