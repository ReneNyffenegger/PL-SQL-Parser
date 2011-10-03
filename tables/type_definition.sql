create table nd_type_definition (
  id number(8)                 not null primary key,
  collection_type_definition       null references nd_collection_type_definition,
  record_type_definition           null references nd_record_type_definition,
  ref_cursor_type_definition       null references nd_ref_cursor_type_definition,
  subtype_definition               null references nd_subtype_definition,
  check (
    ( collection_type_definition is not null and record_type_definition is     null and ref_cursor_type_definition is     null and subtype_definition is     null) or
    ( collection_type_definition is     null and record_type_definition is not null and ref_cursor_type_definition is     null and subtype_definition is     null) or
    ( collection_type_definition is     null and record_type_definition is     null and ref_cursor_type_definition is not null and subtype_definition is     null) or
    ( collection_type_definition is     null and record_type_definition is     null and ref_cursor_type_definition is     null and subtype_definition is not null) 
  )
);
