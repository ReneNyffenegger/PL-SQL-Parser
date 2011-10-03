create table nd_order_by_clause (
   id number(8) primary key,
   siblings_ number(1) check (siblings_ in (1))
);
