create or replace type scanner as object (

         current_character_  char(1),

--       Flag that determines if EOF was encountered.
--       Is set to 0 in -> init() and to 1 in -> next_char()
--       when -> read_char returns null.
         eof_reached_        number(1),

--       0 based index of the character that is to be 
--       read with read_char
--       Will be set to null as soon as EOF is reached (and
--       eof_reached_ set to 1)
         next_position_      number(7),

--       Initializes the 'base' class. Used because PL/SQL lacks a 'super' keyword (or
--       its respective functionality). Supposed to be called by the constructors of 
--       derived classes;
         instantiable     final member procedure init(self in out scanner),

--       This procedure is supposed to be called by the lexter.
--       It will call read_char.
         instantiable     final member procedure next_char(self in out scanner),

--       This function is not supposed to be called by anyone except the scanner itself,
--       more specifically by next_char.
--       The next_char->read_char mechanism was chosen in order to have specialized
--       scanners for varchar2 inputs or reading directly from dba_source and the like.
--       If there were something like a private keyword, this procedure would be labelled
--       as such.
--       read_char should return null after the last character was read.
    not  instantiable not final member function read_char(self in out scanner) return char
    

) not final not instantiable;
/
