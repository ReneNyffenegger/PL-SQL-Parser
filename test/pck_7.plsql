create or replace package tq84_pck_7 as

    some_exception       exception;
    some_other_exception exception;

    pragma exception_init(some_other_exception, -20900);

end tq84_pck_7;
/
