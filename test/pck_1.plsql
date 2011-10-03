create or replace package tq84_pck_1

-- This package is supposed to test
-- the authid clause of a package.

   authid current_user
   /*
      TODO: check if a really long (that is longer than 4000 bytes) comment
      is parsed and stored corectly.
                                                                                                   1 
         1         2         3         4         5         6         7         8         9         0
      78 0 2345678 0 2345678 0 2345678 0 2345678 0 2345678 0 2345678 0 2345678 0 2345678 0 2345678 0
                                                                                                    x 2
                                                                                                    x 3
                                                                                                    x 4
                                                                                                    x 5
                                                                                                    x 6
                                                                                                    x 7
                                                                                                    x 8
                                                                                                    x  
                                                                                                    x10
             F i l l i n g    m o r e    t h a n   50 x 100   b y t e s                             x 1
                                                                                                    x 2
             r e s u l t i n g    i n    m o r e   t h a n    5000  b y t e s.                      x 3
                                                                                                    x 4
                                                                                                    x 5
                                                                                                    x 6
                                                                                                    x 7
                                                                                                    x 8
                                                                                                    x  
                                                                                                    x20
                                                                                                    x  
                                                                                                    x 2
                                                                                                    x 3
                                                                                                    x 4
                                                                                                    x 5
                                                                                                    x 6
                                                                                                    x 7
                                                                                                    x 8
                                                                                                    x  
                                                                                                    x40
                                                                                                    x  
                                                                                                    x 2
                                                                                                    x 3
                                                                                                    x 4
                                                                                                    x 5
                                                                                                    x 6
                                                                                                    x 7
                                                                                                    x 8
                                                                                                    x  
           --------------------------------------------------------------------------------------   x50


*/

as

end tq84_pck_1;
/
