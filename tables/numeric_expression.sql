create table nd_numeric_expression (
  id  number(8)             primary key,
  numeric_subexpression_1           not null references nd_numeric_subexpression on delete cascade,
  op                        char(1)     null check (op in ('+', '-', '*', '/')),
  numeric_subexpression_2               null references nd_numeric_subexpression on delete cascade,
  --
  check ( (op is not null and numeric_subexpression_2 is not null) or
          (op is     null and numeric_subexpression_2 is     null)
        )
);
