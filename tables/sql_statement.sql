create table nd_sql_statement (
  id number(8) primary key,
  dml_statement             null references nd_dml_statement,
  commit_statement          null references nd_commit_statement,
  lock_table_statement      null references nd_lock_table_statement,
  rollback_statement        null references nd_rollback_statement,
  savepoint_statement       null references nd_savepoint_statement,
  set_transaction_statement null references nd_set_transaction_statement,
  check (
    nvl2(dml_statement             , 1, 0) +
    nvl2(commit_statement          , 1, 0) +
    nvl2(lock_table_statement      , 1, 0) +
    nvl2(savepoint_statement       , 1, 0) +
    nvl2(set_transaction_statement , 1, 0) = 1
  )
);
