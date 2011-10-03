create table nd_assoc_array_type_def (
  id number(8)               not null primary key,
  datatype                   not null references nd_datatype,
  --
  --  TODO_0010: Probably better to just have the index_by_datatype field...
  --
  index_by_pls_integer       number(1) not null check (index_by_pls_integer    in (0, 1)),
  index_by_binary_integer    number(1) not null check (index_by_binary_integer in (0, 1)),
  index_by_varcharX          number(1) not null check (index_by_varcharx       in (0, 1)),
  index_by_string            number(1) not null check (index_by_string         in (0, 1)),
  index_by_long              number(1) not null check (index_by_long           in (0, 1)),
  --
  index_by_datatype                        null references nd_datatype,
  v_size                     number(4)     null,
  check (
          ( index_by_pls_integer + index_by_binary_integer + index_by_long = 1 and
            index_by_varcharX + index_by_string                            = 0 and
            v_size is null
          ) 
          or
          ( index_by_pls_integer + index_by_binary_integer + index_by_long = 0 and
            index_by_varcharX + index_by_string                            = 1 and
            v_size is not null
          ) 
          or (
            index_by_pls_integer + index_by_binary_integer + index_by_long + index_by_varcharx + index_by_string = 0 and
            index_by_datatype is not null
          )
        )
);
