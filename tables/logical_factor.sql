create table nd_logical_factor (
  -- http://cui.unige.ch/db-research/Enseignement/analyseinfo/SQL7/logical_factor.html
  --
  -- A logical factor seems to be something that can be 
  -- true or false (such as  
  --         1 > 5  
  --         9 != 20
  --     not 3 < 8
  --
  logical_factor_list not null references nd_logical_factor_list,  -- The >logical factor list< connects >logical factors< 
                                                                   -- with ANDs
  --
  not_                         number(1) check (not_ in (1)), -- Indicates whether the logical factor starts with a NOT
  condition                    null references nd_condition,       -- A >condition< is found within parantheses:
  relation                     null references nd_relation,
  in_condition                 null references nd_in_condition,
  exists_condition             null references nd_exists_condition,
  between_condition            null references nd_between_condition,
  null_condition               null references nd_null_condition,
  like_condition               null references nd_like_condition,
  -- Following fields used in PLSQL Context
  -- Probably, the 'keywords' TRUE, FALSE (and NULL?) should be implemeted, too.
  boolean_plsql_identifier     null references nd_plsql_identifier,    -- Only valid in PLSQL Context. 
                                                                       --   That is:
                                                                       --      select x, y from t where boolean_value
                                                                       --   is invalid, whereas 
                                                                       --      if boolean_value then ... 
                                                                       --   is valid.
                                                                       --
  boolean_function_expression  null references nd_function_expression, -- Only valid in PLSQL Context. 
                                                                       --   That is:
                                                                       --      select x, y from t where boolean_function(3)
                                                                       --   is invalid, whereas 
                                                                       --      if boolean_function(4) then ... 
                                                                       --   is valid.
  --
  check (
    nvl2(relation                    , 1, 0) + 
    nvl2(condition                   , 1, 0) +
    nvl2(in_condition                , 1, 0) +
    nvl2(exists_condition            , 1, 0) +
    nvl2(null_condition              , 1, 0) +
    nvl2(like_condition              , 1, 0) +
    nvl2(between_condition           , 1, 0) +
    nvl2(boolean_plsql_identifier    , 1, 0) +
    nvl2(boolean_function_expression , 1, 0 )
    = 1
  )
);
