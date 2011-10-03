create table nd_group_by_clause (
  id number(8) not null primary key
--Tahiti claims that the having_condition is part
--of the group by clause.
--But a query can have a condition without (an explicit) group by clause...
--Therefor: commented out
--having_condition null references nd_condition 
--The having_condition is moved to the query_block
);
