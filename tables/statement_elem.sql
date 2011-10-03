create table nd_statement_elem (
--  TODO: http://download.oracle.com/docs/cd/E11882_01/appdev.112/e17126/block.htm#CJACHDGG
    statement_list not null references nd_statement_list,
    label_    varchar2(30)           null,  -- <<LABEL>>
    assignment_statement             null references nd_assignment_statement,
    basic_loop_statement             null references nd_basic_loop_statement,
    case_statement                   null references nd_case_statement,
    close_statement                  null references nd_close_statement,
--  collection_method_call,
    continue_statement               null references nd_continue_statement, -- TODO_0076 new node exit/continue statement?  // TODO_0073
    cursor_for_loop_statement        null references nd_cursor_for_loop_statement,
    execute_immediate_statement      null references nd_execute_immediate_statement,
    exit_statement                   null references nd_exit_statement,
    fetch_statement                  null references nd_fetch_statement,
    for_loop_statement               null references nd_for_loop_statement,
    forall_statement                 null references nd_forall_statement,
--  goto_statement,
    if_statement                     null references nd_if_statement,
    null_statement     number(1)     null check (null_statement in (1)),
    open_statement                   null references nd_open_statement,
    open_for_statement               null references nd_open_for_statement,
--  pipe_row_statement,
    plsql_block                      null references nd_plsql_block, -- http://download.oracle.com/docs/cd/E11882_01/appdev.112/e17126/block.htm#CJACBIJG
--  procedure 
    procedure_call                   null references nd_procedure_call,
--  raise_statement,
    return_statement                 null references nd_return_statement,
    select_into_statement            null references nd_select_into_statement,
    sql_statement                    null references nd_sql_statement,
    while_loop_statement             null references nd_while_loop_statement,
--
    check (
      nvl2(assignment_statement        , 1, 0) +
      nvl2(basic_loop_statement        , 1, 0) +
      nvl2(case_statement              , 1, 0) +
      nvl2(close_statement             , 1, 0) +
      nvl2(continue_statement          , 1, 0) +
      nvl2(cursor_for_loop_statement   , 1, 0) +
      nvl2(execute_immediate_statement , 1, 0) +
      nvl2(exit_statement              , 1, 0) +
      nvl2(fetch_statement             , 1, 0) +
      nvl2(forall_statement            , 1, 0) +
      nvl2(for_loop_statement          , 1, 0) +
      nvl2(if_statement                , 1, 0) +
      nvl2(null_statement              , 1, 0) +
      nvl2(open_for_statement          , 1, 0) +
      nvl2(plsql_block                 , 1, 0) +
      nvl2(open_statement              , 1, 0) +
      nvl2(procedure_call              , 1, 0) +
      nvl2(sql_statement               , 1, 0) +
      nvl2(return_statement            , 1, 0) +
      nvl2(while_loop_statement        , 1, 0) +
      nvl2(select_into_statement       , 1, 0) 
      = 1
    )
--
--  TODO_0100
--    The 'pragma inline' should probably be regarded as a
--    statement. 
);
