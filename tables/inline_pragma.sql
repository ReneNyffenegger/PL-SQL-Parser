create table nd_inline_pragma (
  id number(8) primary key,
  subprogram varchar2(30) not null,
  yes_no varchar2(3) not null check (lower(yes_no) in ('yes', 'no'))
);
