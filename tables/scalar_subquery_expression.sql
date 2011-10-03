create table nd_scalar_subquery_expression (
--     A 'scalar subquery expression' is a subquery that returns exactly one column value.
--     If the subquery returns 0 rows, then the value of the scalar subquery expression is NULL.
--     If the subquery returns more than one row, then Oracle returns an error.
--
--     In all cases, a scalar subquery must be enclosed in its own parentheses, even 
--     if its syntactic location already positions it within parentheses (for example, 
--     when the scalar subquery is used as the argument to a built-in function).
--
--     Scalar subqueries are not valid expressions in the following places:
--       o   As default values for columns
--       o   As hash expressions for clusters
--       o   In the RETURNING clause of DML statements
--       o   As the basis of a function-based index
--       o   In CHECK constraints
--       o   In GROUP BY clauses
--       o   In statements that are unrelated to queries, such as CREATE PROFILE
--
  id number(8) primary key,
--TODO_0098: shouldn't that be 'subquery factoring clause' ?
  subquery     not null references nd_subquery
);
