create table nd_collection_type_definition (
  id number(8)                not null primary key,
  name varchar2(30)           not null,
  assoc_array_type_def            null references nd_assoc_array_type_def,
  nested_table_type_def           null references nd_nested_table_type_def,
  check ( (assoc_array_type_def is not null and nested_table_type_def is     null) or 
          (assoc_array_type_def is     null and nested_table_type_def is not null)
  )
);
