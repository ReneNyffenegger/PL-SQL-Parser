create table nd_declare_section (
  id             number(8)  primary key,
  item_list_1    references nd_item_list_1,
  item_list_2    references nd_item_list_2,
  --
  check ( ( item_list_1 is not null) or -- If item_list_2 is not null then
          ( item_list_2 is not null)    -- item_list_1 must not be null!
        )
);
