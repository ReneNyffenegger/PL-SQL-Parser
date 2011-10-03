create table nd_exception (
  exception_list not null references nd_exception_list,
  --
  --  TODO_0080: Maybe better called nd_exception_elem
  --
  --  An exception is
  --     either a predefined exception:
           access_into_null_        number(1) null check(access_into_null_         in (1)), -- -6530
           case_not_found_          number(1) null check(case_not_found_           in (1)), -- -6592
           collection_is_null_      number(1) null check(collection_is_null_       in (1)), -- -6531
           cursor_already_open_     number(1) null check(cursor_already_open_      in (1)), -- -6511
           dup_val_on_index_        number(1) null check(dup_val_on_index_         in (1)), -- -1
           invalid_cursor_          number(1) null check(invalid_cursor_           in (1)), -- -1001
           invalid_number_          number(1) null check(invalid_number_           in (1)), -- -1722
           login_denied_            number(1) null check(login_denied_             in (1)), -- -1017
           no_data_found_           number(1) null check(no_data_found_            in (1)), -- +100
           no_data_needed_          number(1) null check(no_data_needed_           in (1)), -- -6548
           not_logged_on_           number(1) null check(not_logged_on_            in (1)), -- -1012
           program_error_           number(1) null check(program_error_            in (1)), -- -6501
           rowtype_mismatch_        number(1) null check(rowtype_mismatch_         in (1)), -- -6504
           self_is_null_            number(1) null check(self_is_null_             in (1)), -- -30625
           storage_error_           number(1) null check(storage_error_            in (1)), -- -6500
           subscript_beyond_count_  number(1) null check(subscript_beyond_count_   in (1)), -- -6533
           subscript_outside_limit_ number(1) null check(subscript_outside_limit_  in (1)), -- -6532
           sys_invalid_rowid_       number(1) null check(sys_invalid_rowid_        in (1)), -- -1410
           timeout_on_resource_     number(1) null check(timeout_on_resource_      in (1)), -- -51
           too_many_rows_           number(1) null check(too_many_rows_            in (1)), -- -1422
           value_error_             number(1) null check(value_error_              in (1)), -- -6502
           zero_divide_             number(1) null check(zero_divide_              in (1)), -- -1476
  --    or a user-defined exception
           user_defined_exception varchar2(30)null
);
