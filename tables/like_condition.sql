create table nd_like_condition (
--http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/conditions007.htm
  id       number(8) primary key,
  char1    not null references nd_expression, -- TODO_0081: should be 'character expression' ...
  --
  not_     number(1) check (not_   in (1)),
  --
  like_    number(1) check (like_  in (1)),
  likec_   number(1) check (likec_ in (1)),
  like2_   number(1) check (like2_ in (1)),
  like4_   number(1) check (like4_ in (1)),
  --
  char2    not null references nd_expression, -- TODO_0081: should be 'character expression' ...
  --
  escape_  null references nd_expression,     -- TODO_0081: should be 'character expression' ...
  --
  check ( nvl(like_ , 0) + 
          nvl(likec_, 0) +
          nvl(like2_, 0) +
          nvl(like4_, 0) = 1)
);
