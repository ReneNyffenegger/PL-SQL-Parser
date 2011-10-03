create table nd_query_table_expression (
  id       number(8) not      null primary key,
  name_                       null references nd_plsql_identifier, -- This name_ can be: 'query_name', or 'schema.table/view name'                           
  subquery                    null references nd_subquery,
  subquery_restriction_clause null references nd_subquery_restriction_clause,
  table_collection_expression null references nd_table_collection_expression,
  check (  (name_ is not      null and subquery is     null and table_collection_expression is     null) or
           (name_ is          null and subquery is not null and table_collection_expression is     null) or
           (name_ is          null and subquery is     null and table_collection_expression is not null)
        ),
  check ( subquery_restriction_clause is null or subquery is not null)
);
