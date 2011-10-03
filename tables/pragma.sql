create table nd_pragma (
  id number(8) primary key,
  autonomous_transaction_     number(1) check (autonomous_transaction_  in (1)),
  serially_reusable_pragma_   number(1) check (serially_reusable_pragma_ in (1)),
  exception_init_pragma       null references nd_exception_init_pragma,
  inline_pragma               null references nd_inline_pragma,
  restrict_references_pragma  null references nd_restrict_references_pragma
);
