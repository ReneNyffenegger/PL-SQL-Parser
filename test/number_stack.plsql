declare
  ns   number_stack := number_stack;
begin

  ns.push(5);
  ns.push(10);
  ns.push(13);

  if ns.pop != 13 then 
     raise_application_error(-20800, 'should be 13');
  end if;

  if ns.pop != 10 then 
     raise_application_error(-20800, 'should be 10');
  end if;

  ns.push(-20);
  ns.push(null);
  ns.push(-60);

  if ns.pop != -60 then 
     raise_application_error(-20800, 'should be -60');
  end if;

  if ns.pop is not null then 
     raise_application_error(-20800, 'should be null');
  end if;

  if ns.pop != -20 then 
     raise_application_error(-20800, 'should be -20');
  end if;

  if ns.pop != 5 then 
     raise_application_error(-20800, 'should be 5');
  end if;

  declare 
    dummy number;
  begin
     dummy := ns.pop;
  exception when others then
    if sqlcode != 6532 then -- Subscript outside of limit
       null;
    else 
      raise;
    end if;
  end;

  dbms_output.put_line('Test ok: Number Stack');

end;
/
