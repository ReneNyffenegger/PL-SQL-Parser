create table nd_select_statement (
  id                         number(8)    not null primary key,
  subquery_factoring_clause                   null references nd_subquery_factoring_clause,
  subquery                                not null references nd_subquery,
  for_update_clause                           null references nd_for_update_clause
------------------------------------------------------------
--   ACCORDING to TAHITI DIAGRAM (?)
--   --------------------------------
--   
--     select      +------------------ +------------------ +--------------  +--------------
--       a,b,c     | select stmt       | subquery          | subquery       | query block
--     from        |                   |                   |                |
--       dual      |                   | /* excatly one    +--------------- +---------------
--   UNION (       |                   |    subquery per     UNION
--       select    |                   |    select stmt */ +--------------- +---------------  +-------------- +--------------
--         a,b,c   |                   |                   |subquery        |subquery         | subquery      | query block
--       from      |                   |                   |                |/* in            |               |
--         t_2     |                   |                   |                |   paranthesis*/ +-------------- +--------------
--     UNION       |                   |                   |                |                   UNION                 
--       select    |                   |                   |                |                 +-------------- +--------------
--         a,b,c   |                   |                   |                |                 | subquery      | query block  
--       from      |                   |                   |                |                 |               |
--         t_3     |                   |                   |                |                 |               |
--   )             +------------------ +------------------ +--------------- +---------------  +-------------- +--------------
--     
--   
--   MY PROPOSAL:
--   ------------
--   
--     select      +------------------ +------------------ +--------------  +--------------
--       a,b,c     | select stmt       | subquery          | subquery_elem  | query block
--     from        |                   |                   |                |  <-- Only first query block can have into_clause
--       dual      |                   | /* excatly one    +--------------- +---------------
--   UNION (       |                   |    subquery under   UNION
--       select    |                   |    select stmt */ +--------------- +---------------  +-------------- +--------------
--         a,b,c   |                   |                   |subquery_elem   |subquery         | subquery_elem | query block
--       from      |                   |                   |                |/* in            |               |
--         t_2     |                   |                   |                |   paranthesis*/ +-------------- +--------------
--     UNION       |                   |                   |                |                   UNION                 
--       select    |                   |                   |                |                 +-------------- +--------------
--         a,b,c   |                   |                   |                |                 | subquery_elem | query block  
--       from      |                   |                   |                |                 |               |
--         t_3     |                   |                   |                |                 |               |
--   )             +------------------ +------------------ +--------------- +---------------  +-------------- +--------------
--   
--     
--     select statment
--       subquery   
--         subquery_elem
--           query_block
--         UNION
--         subquery_elem
--           subquery
--             subquery_elem
--               query_block
--             UNION
--             subquery_elem
--               query_block
);
