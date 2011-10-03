create table nd_group_by_elem (
  group_by_clause not  null references nd_group_by_clause,
  expression           null references nd_expression,
  rollup_cube_clause   null references nd_rollup_cube_clause,   -- TODO_0089: Implement me
  grouping_sets_clause null references nd_grouping_sets_clause, -- TODO_0090: Implement me
  check (nvl2(expression          , 1, 0) +
         nvl2(rollup_cube_clause  , 1, 0) +
         nvl2(grouping_sets_clause, 1, 0)
         = 1)
);
