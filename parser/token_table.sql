create table token_table (
  unit_id     number(6),
  seq         number(6),
  -- TODO_0004: the column token could be named differently in order
  --            to prevent confusion with the token type.
  token       token not null,
  constraint tq84_token_table_pk primary key (unit_id, seq)
);

comment on table token_table is 'needed for token_getter_into_table';

create sequence token_sequence;
