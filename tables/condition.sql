create table nd_condition (
   id number(8)      not null primary key,
   -- http://cui.unige.ch/db-research/Enseignement/analyseinfo/SQL7/condition.html
   logical_term_list not null references nd_logical_term_list -- A logical term list connects logical terms with an OR
);
