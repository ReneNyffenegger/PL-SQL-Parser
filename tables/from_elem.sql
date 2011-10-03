create table nd_from_elem (
  from_list                    not null references nd_from_list,
  table_reference                  null references nd_table_reference,
  join_clause                      null references nd_join_clause
);
