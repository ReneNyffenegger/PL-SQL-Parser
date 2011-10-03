create table nd_hierarchical_query_clause (
  id number(8)  not null primary key,
  connect_by_condition not null references nd_condition, -- Tahiti's syntax diagram has condtion [AND condition [AND condition...]] (But that doesn't seem to make sense)
  start_with_condition     null references nd_condition,
  nocycle_                 number(1) null check(nocycle_ in (1))
);
