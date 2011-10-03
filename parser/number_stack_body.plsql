create or replace type body number_stack as 

  constructor function number_stack return self as result is
  begin

      numbers_ := numbers_t();
      return;

  end number_stack;

  final instantiable member procedure push  (i in number) is
  begin

      numbers_.extend;
      numbers_(numbers_.count) := i;

  end push;

  final instantiable member function  pop(self in out number_stack) return number is
      i number;
  begin

      i := numbers_(numbers_.count);
      numbers_.trim;
      return i;
  end pop;

end;
/
