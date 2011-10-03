create table nd_subquery_factoring_elem (
    subquery_factoring_clause not null references nd_subquery_factoring_clause,
    query_name  varchar2(30),
    column_alias_list null references nd_plsql_identifier_list,
    subquery      not null references nd_subquery
--  TODO_0101: search_clause null references nd_search_clause,
--  TODO_0102: cycle_clause  null references nd_cycle_clause
);
