create table nd_windowing_clause (
  id                              number(8) primary key,
  rows_                           number(1) null check (rows_                in (1)),
  range_                          number(1) null check (range_               in (1)),
  --
  between_                        number(1) null check (between_             in (1)),
  unbounded_preceding_            number(1) null check (unbounded_preceding_ in (1)),
  current_row_                    number(1) null check (current_row_         in (1)),
  value_expression_preceeding               null references nd_expression,
  --
  check (
    nvl(rows_,0) + nvl(range_,0) = 1
  ),
  check (
    nvl(between_, 0) + nvl(unbounded_preceding_, 0) + nvl(current_row_, 0) + nvl2(value_expression_preceeding,1,0) = 1
  )
);
