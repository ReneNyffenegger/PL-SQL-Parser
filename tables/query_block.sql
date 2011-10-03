create table nd_query_block (
  id                         number(8) not null primary key,
  ---
  hint                       varchar2(100),
  --
  distinct_                  number(1)  null check(distinct_ in (1)),
  unique_                    number(1)  null check(unique_   in (1)),
  all_                       number(1)  null check(all_      in (1)),
  ---
  select_list                       not null references nd_select_list,
  --
  into_clause                           null references nd_into_clause, -- Only used in PL/SQL
  --
  from_list                         not null references nd_from_list,
  where_clause                          null references nd_where_clause,
  hierarchical_query_clause             null references nd_hierarchical_query_clause,
  group_by_clause                       null references nd_group_by_clause,
  having_condition                      null references nd_condition,
  model_clause                          null references nd_model_clause,
  --
  check ( ( distinct_ is     null and unique_ is     null and all_ is     null ) or
          ( distinct_ is not null and unique_ is     null and all_ is     null ) or
          ( distinct_ is     null and unique_ is not null and all_ is     null ) or
          ( distinct_ is     null and unique_ is     null and all_ is not null )
        )
);
