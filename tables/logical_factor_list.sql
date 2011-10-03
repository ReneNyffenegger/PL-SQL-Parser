create table nd_logical_factor_list (
  --
  -- A logical factor list connects factors with "AND"s
  -- TODO_0055: AND has the higher precedence than OR:
  --   select count(*) from dual where (1=1 and 2=2) or (3=2 and 2=1)
  -- vs 
  --   select count(*) from dual where 1=1 and (2=2 or 3=2) and 2=1
  -- vs
  --   select count(*) from dual where 1=1 and 2=2 or 3=2 and 2=1
  --
  -- http://cui.unige.ch/db-research/Enseignement/analyseinfo/SQL7/logical_term.html
  --
  id number(8) primary key
);
