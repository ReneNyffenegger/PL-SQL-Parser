create table nd_restrict_references_pragma (
  id number(8) primary key,
  subprogram_method varchar2(30),
  default_ number(1) check (default_ in (1)),
  rnds_    number(1) check (rnds_    in (1)),
  wnds_    number(1) check (wnds_    in (1)),
  rnps_    number(1) check (rnps_    in (1)),
  wnps_    number(1) check (wnps_    in (1)),
  trust_   number(1) check (trust_   in (1))
);
