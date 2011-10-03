create table nd_logical_term (
  logical_term_list    not null references nd_logical_term_list,
  logical_factor_list  not null references nd_logical_factor_list
);
