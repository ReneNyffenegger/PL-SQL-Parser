create table parser_log (
  seq  number (8) primary key,
  txt  varchar2(4000) not null
);

comment on table parser_log is 'Used by plsql_parser for debugging messages.';

create sequence parser_log_seq;
