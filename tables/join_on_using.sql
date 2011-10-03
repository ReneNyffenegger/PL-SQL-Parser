create table nd_join_on_using (
   id number(8)            primary key,
   -- Not part of Tahiti's syntax diagrams.
   --
   -- used for inner_join_clause and outer_join_clause since they
   -- have the same part for it in their syntax diagrams.
  on_condition             null references nd_condition,
  using_                   null references nd_plsql_identifier_list
);
