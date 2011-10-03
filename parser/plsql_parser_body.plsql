create or replace package body plsql_parser as

 --  Flag if the 'debugging' functions e, p and l
 --  should print something:
 dbg boolean := true;

 --  Determines where the debug trail (procedures e, l and p)
 --  is written to. 
 --    'table' :       trail is written to plsql_parser_log
 --    'dbms_output' : trail is written to dbms_output
 --  Evaluated in procedure 'log_'
 dbg_trail varchar2(20) := 'table';

 --  Current indent level of the debugging functions
 --  e, p, and l.
 lvl number := 0;

 procedure init_lvl is begin/*{*/
   lvl := 0;
 end init_lvl;/*}*/

 procedure log_(txt in varchar2) is/*{*/
   pragma autonomous_transaction;
 begin

     if    dbg_trail = 'table'       then
           insert into parser_log values (parser_log_seq.nextval, txt);
           commit;
     elsif dbg_trail = 'dbms_output' then
           dbms_output.put_line(txt);
     else
           raise_application_error(-20800, 'Unknown dbg_trail >' || dbg_trail || '<');
     end if;

 end log_;/*}*/

 -- Debugging functions { :
 procedure e (func in varchar2, t in out token_getter) is/*{*/
 -- One of the three debugging functions, to be called
 -- on entering a function or procedure:

    txt parser_log.txt%type;
 begin

   if not dbg then
      return;
   end if;

   lvl := lvl+1;

   -- chr(123) is an opening curly brace
   txt := lpad(' ', lvl*2) || '*' || rpad(func, 30) || chr(123) ||
          lpad(' ', lvl*2) || ' Token: '  || t.what_and_where;


   log_(txt);
      
 end e;/*}*/

 procedure p (txt in varchar2, t in out token_getter) is/*{*/
 -- One of the three debugging functions, to be called
 -- to emit a message.
 begin

     if not dbg then
        return;
     end if;
    
     log_(lpad(' ', lvl*2) || '.' || txt || '       Token: ' || t.what_and_where);

 end p;/*}*/

 procedure p (txt in varchar2) is/*{*/
 -- One of the three debugging functions, to be called
 -- to emit a message.
 begin

     if not dbg then
        return;
     end if;
    
     log_(lpad(' ', lvl*2) || '.' || txt);

 end p;/*}*/

 procedure l is/*{*/
 -- One of the three debugging functions, to be called
 -- on leaving a function or procedure:
 begin

   if not dbg then
      return;
   end if;

   -- chr(125) is a closing curly brace
   log_(lpad(' ', lvl*2) || chr(125));
   lvl := lvl-1;

 end l;/*}*/
 -- }

     procedure raise_error(tg in out token_getter, err in varchar2) is/*{*/
     begin

         raise_application_error(
           -20800, 
           err || ' @ ' || tg.current_token_.line_ || '/' || tg.current_token_.pos_in_line_ || 
                  ', Token is: ' || tg.current_token_.token_ || ' (' || tg.current_token_.type_ || ')');

     end raise_error;/*}*/

     function is_id_eaten(tg in out token_getter, word in varchar2) return boolean is/*{*/
     begin

         if not tg.type_('ID') then
            return false;
         end if;

         if not tg.compare_i(word) then
            return false;
         end if;

         tg.next_stored_program_token;

         return true;

     end is_id_eaten;/*}*/

     function eat_id_or_return_null(tg in out token_getter) return varchar2 is/*{*/
       ret varchar2(4000);
     begin

       if not tg.type_('ID') then
          return null;
       end if;
       ret := tg.token_value;
       tg.next_stored_program_token;
       return ret;
     end eat_id_or_return_null;/*}*/

     function get_id(tg in out token_getter, error_msg in varchar2 := null) return varchar2 is/*{*/
        id varchar2(30); 
     begin
       
         if     tg.type_('ID') then
                id := upper(tg.current_token_.token_);

         elsif  tg.type_('Id') then
                id := substr(tg.current_token_.token_, 2, length(tg.current_token_.token_) -2 );

         else   raise_error(tg, error_msg);
         end if;

         tg.next_stored_program_token;

         return id;

     end get_id;/*}*/

     function eat_is_or_as(tg in out token_getter) return boolean is/*{*/
     begin
          
          e('eat_is_or_as', tg);

          if not tg.type_('ID') then/*{*/
             p('eat_is_or_as: nothing to eat');
             return false;
          end if;/*}*/

          if upper(tg.token_value) not in ('IS', 'AS') then/*{*/
             p('eat_is_or_as: nothing to eat');
             return false;
          end if;/*}*/

         tg.next_stored_program_token;
         l;
         return true;
     end eat_is_or_as;/*}*/

     procedure eat_semicolon(tg in out token_getter) as/*{*/
     begin

           if not tg.type_('SYM') then
              raise_error(tg, '; expected');
           end if;

           if tg.token_value_sym != ';' then 
              raise_error(tg, '; expected');
           end if;

           tg.next_stored_program_token;

     end eat_semicolon;/*}*/

     function func_or_proc_call(tg in out token_getter, name in out varchar2, parameter_list in out number, check_outer_join_symbol in boolean, parameter_list_required in boolean) return boolean is/*{*/
     begin

          e('func_or_proc_call', tg);

          tg.push_state;
 
          -- TODO_0007: Should complex_plsql_identifier_ident be used instead?
          name := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);
 
          if name is null then
             tg.pop_state;
             p('func_or_proc_call: name is null, returning false', tg);
             l;
             return false;
          end if;
 
          p('func_or_proc_call: trying parameter_list for plsql_identifier with id ' || name);
          parameter_list := "parameter_list"(tg, check_outer_join_symbol=>check_outer_join_symbol);
 
          if parameter_list_required and parameter_list is null then
             tg.pop_state;
             p('func_or_proc_call: no parameter_list found although required, returning false', tg);
             l;
             return false;
          end if;

          tg.remove_state;

          p('func_or_proc_call: no parameter_list found, returning true', tg);
          l;
          return true;

     end func_or_proc_call;/*}*/

     function numeric_literal(tg in out token_getter) return number is/*{*/
     --  function used because token_getter sees '-42' as
     --  a SYM (-) followed by a NUM (42), yet, some parsed elements
     --  need a numeric literal (for example -> exception_init_pragma).
     --  
     --  HELP: I'd be very surprised if this function worked without changing it.
     --
      
         ret number := 1;
     begin
       
         if tg.type_('SYM') then

            if    tg.token_value_sym  = '-' then
                  ret := -1;
            elsif tg.token_value_sym != '+' then
                  raise_error(tg, 'numeric literal, SYM supposed to be either - or +');
            end if;

            tg.next_stored_program_token;

         end if;

         ret := ret * tg.token_value_num;
         tg.next_stored_program_token;

         return ret;

     end numeric_literal;/*}*/

     procedure next_nd_seq(id in out number) is/*{*/
     begin
       select nd_sequence.nextval into id from dual;
     end next_nd_seq;/*}*/

     function det_pip_par_res(tg in out token_getter, /*{*/
                              deterministic_   in out number,
                              pipelined_       in out number,
                              parallel_enable_ in out number,
                              result_cache_    in out number
                             ) return boolean is

     begin

       if not tg.type_('ID') then
          return false;
       end if;

       case upper(tg.token_value) /*{*/
                   when 'DETERMINISTIC'   then deterministic_        := 1; tg.next_stored_program_token; return true;
                   when 'PIPELINED'       then pipelined_            := 1; tg.next_stored_program_token; return true;
                   when 'PARALLEL_ENABLE' then parallel_enable_      := 1; tg.next_stored_program_token; return true;
                   when 'RESULT_CACHE'    then result_cache_         := 1; tg.next_stored_program_token; return true;
                   else                                                                                  return false;
       end case;/*}*/

     end det_pip_par_res;/*}*/

     function is_keyword(suspect in varchar2) return boolean /*{*/
     is begin
          return upper(suspect) in ('BEGIN', 'BULK', 'CASE', /*'DELETE', */ 'END', 'ELSE', 'ELSIF', 'EXISTS', 'FROM', 'FUNCTION', 'GROUP', 'INTO', 'IS', 
                                    'JOIN', 'MINUS', 'ORDER', 'PROCEDURE', 'SELECT', 'START', 'USING', 'WHILE', 'WHEN', 'WHERE', 'WITH');
     end is_keyword;/*}*/

     function is_default_assignment(tg in out token_getter) return boolean/*{*/
     is
     --       Checks whether the current token is 
     --         either a    := 
     --         or          DEFAULT
     --       and returns true if that is the case, and
     --       false otherwise.
     --
     begin

         if tg.type_('SYM') then/*{*/
            if tg.token_value_sym = ':=' then
               tg.next_stored_program_token;
               return true;
            end if;
            return false;
         end if;/*}*/

         if tg.type_('ID' ) then/*{*/
            if tg.compare_i('default') then
               tg.next_stored_program_token;
               return true;
            end if;
            return false;
         end if;/*}*/

         return false;

     end is_default_assignment;/*}*/

     function is_outer_join_symbol(tg in out token_getter) return boolean /*{*/
     is
     begin

         if not tg.type_('SYM') then
            return false;
         end if;

         if tg.token_value_sym != '(' then
            return false;
         end if;

         tg.push_state;
         tg.next_stored_program_token;

         if not tg.type_('SYM') or tg.token_value_sym != '+' then
            tg.pop_state;
            return false;
         end if;

         tg.next_stored_program_token;

         if not tg.type_('SYM') or tg.token_value_sym != ')' then
            tg.pop_state;
            return false;
         end if;

         tg.next_stored_program_token;
         tg.remove_state;

         return true;

     end is_outer_join_symbol;/*}*/

     function statmt_list_exc_handler(tg in out token_getter, statement_list in out number, exception_handler_list in out number) return boolean is/*{*/
     begin

         e('statmt_list_exc_handler', tg);

         p('statmt_list_exc_handler: begin?', tg);

         if not is_id_eaten(tg, 'begin') then
            p('statmt_list_exc_handler: not BEGIN, returning false');
            l;
            return false;
         end if;


         p('statmt_list_exc_handler: begin found, statement_list?');
         statement_list := "statement_list"(tg);
         if statement_list is null then/*{*/
            p('statmt_list_exc_handler: no statement_list, returning false');
            l;
            return false;
         end if;/*}*/

         p('statmt_list_exc_handler: exception_handler_list?');
         exception_handler_list := "exception_handler_list"(tg);

         p('statmt_list_exc_handler: returning true');
         l;

         return true;

     end statmt_list_exc_handler;/*}*/

--     procedure "item_elem_1_"(id_ in number) is 
--     begin
--
--         "item_declaration_
--          delete from nd_item_elem_1 where id = id_;
--
--     end "item_elem_1_";
--
--     procedure "item_list_1_"(id_ in number) is/*{*/
--     begin
--        
--        "item_elem_1_"(id_);
--
--         delete from nd_item_list_1 where id = id_;
--
--     end "item_list_1_";/*}*/
--
--     procedure "declare_section_"(id_ in number) is/*{*/
--       r nd_declare_section%rowtype;
--     begin
--
--       begin
--         select * into r from nd_declare_section where id = id_;
--       exception when no_data_found then
--         return;
--       end;
--
--      "item_list_1_"(r.item_list_1);
--
--     end "declare_section_";/*}*/
--
--     procedure "package_"(name in varchar2) is/*{*/
--       id_declare_section number;
--     begin
--      
--        begin 
--          select declare_section into id_declare_section from nd_package where package_name = name;
--        exception when no_data_found then
--          return;
--        end;
--
--        "declare_section_"(id_declare_section);
--
--         delete from nd_package where nd_package.package_name = "package_".name;
--
--     end "package_";/*}*/

     -- "A"/*{*/

     function  "aggregate_function"             (tg in out token_getter) return number is/*{*/
           r nd_aggregate_function%rowtype;
     begin
     --   Aggregate functions can appear in 
     --     o select lists and in 
     --     o ORDER BY and 
     --     o HAVING clauses

          if not tg.type_('ID') then
             return null;
          end if;

          if not lower(tg.token_value) in ('avg', 'count', 'min', 'row_number') then
             return null; 
          end if;

          r.name := tg.token_value;

          tg.next_stored_program_token;

          if not tg.type_('SYM') then/*{*/
             raise_error(tg, 'opening paranthesis for aggregate function expected');
          end if;/*}*/

          if not tg.token_value_sym = '(' then /*{*/
             raise_error(tg, 'opening paranthesis for aggregate function expected');
          end if;/*}*/

          tg.next_stored_program_token;

          if lower(r.name) in ('avg', 'min') then/*{*/

             r.expression := "expression"(tg, check_outer_join_symbol => false, star_ => false, aggregate_function => false, prior_ => false);

             if r.expression is null then
                raise_error(tg, 'expression for avg or min is null');
             end if;
          elsif lower(r.name) in ('count') then
             r.expression := "expression"(tg, check_outer_join_symbol => false, star_ => true, aggregate_function => false, prior_ => false);

             if r.expression is null then
                raise_error(tg, 'expression for avg or min is null');
             end if;
          end if;/*}*/

          if not tg.type_('SYM') then
             raise_error(tg, 'closing paranthesis for aggregate function expected');
          end if;

          if not tg.token_value_sym = ')' then 
             raise_error(tg, 'closing paranthesis for aggregate function expected');
          end if;

          tg.next_stored_program_token;

          if tg.type_('ID') and tg.compare_i('over') then
             tg.next_stored_program_token;

             if not tg.type_('SYM') then
                raise_error(tg, 'opening paranthesis for analytic clause is missing');
             end if;

             if tg.token_value_sym != '(' then
                raise_error(tg, 'opening paranthesis for analytic clause is missing');
             end if;

             tg.next_stored_program_token;

             r.analytic_clause := "analytic_clause"(tg);

             if r.analytic_clause is null then
                raise_error(tg, 'analytic clause is missing');
             end if;

             if not tg.type_('SYM') then
                raise_error(tg, 'closing paranthesis for analytic clause is missing');
             end if;

             if tg.token_value_sym != ')' then
                raise_error(tg, 'closing paranthesis for analytic clause is missing');
             end if;

             tg.next_stored_program_token;

          end if;

          next_nd_seq(r.id);
          insert into nd_aggregate_function values r;
          return r.id;

     end "aggregate_function";/*}*/

     function  "analytic_clause"                (tg in out token_getter) return number is/*{*/
          r  nd_analytic_clause%rowtype;
     begin

          e('analytic_clause', tg);
     --   http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/functions004.htm#i97640

          p('analytic_clause: going for query_partition_clause');
          r.query_partition_clause := "query_partition_clause"(tg);

          p('analytic_clause: order by clause?');
          r.order_by_clause        := "order_by_clause"(tg);

          if r.order_by_clause is not null then
             p('analytic_clause: yes order by clause found, windowing_clause?');

             r.windowing_clause := "windowing_clause"(tg);
          end if;

          next_nd_seq(r.id);

          insert into nd_analytic_clause values r;

          p('analytic_clause: ok, returning ' || r.id);
          l;

          return r.id;

     end "analytic_clause";/*}*/

     function  "assignment_statement"           (tg in out token_getter) return number is
          r  nd_assignment_statement%rowtype;
     begin

          tg.push_state;

--        r.target := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false, index_ => true);
          r.target := "complex_plsql_ident"(tg, star_ => false);

          if r.target is null then/*{*/
             tg.pop_state;
             return null;
          end if;/*}*/

          if not tg.type_('SYM') or not tg.token_value_sym = ':=' then/*{*/
             tg.pop_state;
             return null;
          end if;/*}*/

          tg.next_stored_program_token;

          r.expression := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);
--        r.complex_plsql_ident := "complex_plsql_ident"(tg);

          if r.expression is null then
             raise_error(tg, 'expression is null');
          end if;

          eat_semicolon(tg);

          tg.remove_state;

          next_nd_seq(r.id);

          insert into nd_assignment_statement values r;
          return r.id;

     end "assignment_statement";

     function  "assoc_array_type_def"           (tg in out token_getter) return number is/*{*/
        r nd_assoc_array_type_def%rowtype;
     begin

        e('assoc_array_type_def', tg);

        tg.push_state;

        if not tg.compare_i('TABLE') then/*{*/
           p('assoc_array_type_def: expected keyword TABLE not found, returning');
           tg.pop_state;
           l;
           return null;
        end if;/*}*/
           
        tg.next_stored_program_token;
        if not tg.compare_i('OF') then/*{*/
           raise_error(tg, 'OF expected');
        end if;/*}*/

        tg.next_stored_program_token;

        r.datatype := "datatype"(tg, with_precision => true);
        if r.datatype is null then/*{*/
           raise_error(tg, 'assoc_array_type_def: datatype is null');
        end if;/*}*/

        if tg.compare_i('NOT') then/*{*/
           tg.next_stored_program_token;

           if not tg.compare_i('NULL') then
              raise_error(tg, 'NULL expected');
           end if;

           tg.next_stored_program_token;

        end if;/*}*/

        if not tg.compare_i('INDEX') then/*{*/
           -- Not a assoc_array_type_def.
           -- TODO_0008: this is most certainly a 'nested_table_type_def', so the return value
           --            could indicate this for a more optimized parsing...
           tg.pop_state;
           p('assoc_array_type_def: INDEX not found, most certainly a nested_table_type_def, returning null');
           l;
           return null;
        end if;/*}*/

        tg.next_stored_program_token;

        if not tg.compare_i('BY') then
           raise_error(tg, 'BY expected');
        end if;

        tg.next_stored_program_token;

        -- TODO_0010: Default of 0 needed? Maybe just store the datatype with which it is
        --            indexed here?
        r.index_by_pls_integer    := 0;
        r.index_by_binary_integer := 0;
        r.index_by_varcharX       := 0;
        r.index_by_string         := 0;
        r.index_by_long           := 0;

        if    tg.compare_i('PLS_INTEGER'   ) then/*{*/
              r.index_by_pls_integer := 1;
              tg.next_stored_program_token;/*}*/
        elsif tg.compare_i('BINARY_INTEGER') then/*{*/
              r.index_by_pls_integer := 1;
              tg.next_stored_program_token;/*}*/
        elsif tg.compare_i('VARCHAR') or /*{*/
              tg.compare_i('VARCHAR2')       then
              r.index_by_varcharX    := 1;
              tg.next_stored_program_token;/*}*/
        elsif tg.compare_i('STRING')         then/*{*/
              r.index_by_string      := 1;
              tg.next_stored_program_token;/*}*/
        elsif tg.compare_i('LONG')           then/*{*/
              r.index_by_long        := 1;
              tg.next_stored_program_token;/*}*/
        else/*{*/
              r.index_by_datatype := "datatype"(tg, with_precision => false/* TODO_0009 implement: ", %type_required => true" */);
              if r.index_by_datatype is null then
                 raise_error(tg, 'no valid index by found');
              end if;
        end if;/*}*/

        if r.index_by_varcharx = 1 or r.index_by_string = 1 then/*{*/

          if tg.token_value_sym != '(' then
             raise_error(tg, '( expected');
          end if;

          tg.next_stored_program_token;

          if not tg.type_('NUM') then
             raise_error(tg, 'NUM expected');
          end if;

          r.v_size := tg.token_value_num;

          tg.next_stored_program_token;

          if tg.token_value_sym != ')' then
             raise_error(tg, ') expected');
          end if;

          tg.next_stored_program_token;
       end if;/*}*/

       next_nd_seq(r.id);

       insert into nd_assoc_array_type_def values r;

       tg.remove_state;
       l;
       return r.id;

     end "assoc_array_type_def";/*}*/

     /*}*/
     -- "B"/*{*/

     function  "basic_loop_statement"           (tg in out token_getter) return number is/*{*/
           r nd_basic_loop_statement%rowtype;
     begin

           if not is_id_eaten(tg, 'loop') then
              return null;
           end if;

           r.statement_list := "statement_list"(tg);
           if r.statement_list is null then/*{*/
              raise_error(tg, 'statement_list expected');
           end if;/*}*/

           if not is_id_eaten(tg, 'end') then/*{*/
              raise_error(tg, 'end expected');
           end if;/*}*/

           if not is_id_eaten(tg, 'loop') then/*{*/
              raise_error(tg, 'loop expected');
           end if;/*}*/

           r.label := eat_id_or_return_null(tg);
           eat_semicolon(tg);

           next_nd_seq(r.id);
           insert into nd_basic_loop_statement values r;
           return r.id;


     end "basic_loop_statement";/*}*/

     function  "between_condition"              (tg in out token_getter) return number is/*{*/
         r   nd_between_condition%rowtype;
     begin
      
         tg.push_state;

         r.expr1 := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);
         if r.expr1 is null then
            tg.pop_state;
            return null;
         end if;

         if is_id_eaten(tg, 'not') then/*{*/
            r.not_ := 1;
         end if;/*}*/

         if not is_id_eaten(tg, 'between') then/*{*/
            tg.pop_state;
            return null;
         end if;/*}*/


         r.expr2 := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);
         if r.expr2 is null then/*{*/
            raise_error(tg, 'expression 2 expected');
         end if;/*}*/

         if not is_id_eaten(tg, 'and') then/*{*/
            raise_error(tg, 'and expected');
         end if;/*}*/

         r.expr3 := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);
         if r.expr3 is null then/*{*/
            raise_error(tg, 'expression 3 expected');
         end if;/*}*/

         next_nd_seq(r.id);
         insert into nd_between_condition values r;
         return r.id;

     end "between_condition";/*}*/

     function  "body"                           (tg in out token_getter, expected_name in varchar2) return number is/*{*/
           r nd_body%rowtype;
     begin
     --    http://download.oracle.com/docs/cd/E11882_01/appdev.112/e17126/block.htm#CJACHDGG
     --
     --    TODO_0050: See similarity to 'initialize_section'

           e('body', tg);

           p('body: statmt_list_exc_handler?');
           if not statmt_list_exc_handler(tg, r.statement_list, r.exception_handler_list) then/*{*/
              p('body: statmt_list_exc_handler returned false, returning null', tg);
              l;
              return null;
           end if;/*}*/

           if not is_id_eaten(tg, 'end') then/*{*/
              raise_error(tg, 'END expected');
           end if;/*}*/

           if tg.type_('ID') then/*{*/
              if nvl(tg.token_value, '?') != nvl(expected_name, '?') then
                 null; -- TODO_0051: check expected_name!
              end if;
              tg.next_stored_program_token;
           end if;/*}*/

           eat_semicolon(tg);

           next_nd_seq(r.id);
           insert into nd_body values r;
           p('body: returning ' || r.id, tg);
           l;
           return r.id;

     end "body";/*}*/

     function  "boolean_constant"               (tg in out token_getter) return varchar2 is/*{*/
          ret varchar2(30);
     begin

       e('boolean_constant', tg);

        
          if not tg.type_('ID') then
             l;
             return null;
          end if;

          if upper(tg.token_value) not in ('TRUE', 'FALSE', 'NULL') then
             l;
             return null;
          end if;

          ret :=  upper(tg.token_value);

          tg.next_stored_program_token;
        l;

          return ret;

     end "boolean_constant";/*}*/

     function   "bounds_clause"                 (tg in out token_getter) return number is/*{*/
           r  nd_bounds_clause%rowtype;
     begin


           r.lower_bound := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

           if r.lower_bound is null then
              return null;
           end if;

           if not tg.type_('SYM') or not tg.token_value_sym = '.' then/*{*/
              tg.pop_state;
              p('for_loop_statement: no .., returning null', tg);
              l;
              return null;
           end if;/*}*/
           tg.next_stored_program_token;

           if not tg.token_value_sym = '.' then
              raise_error(tg, '. expected');
           end if;
           tg.next_stored_program_token;

--         p('bounds_clause: upper_bound expression?');
           r.upper_bound := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

           if r.upper_bound is null then
              raise_error(tg, 'upper_bound expected');
           end if;

           next_nd_seq(r.id);
           insert into nd_bounds_clause values r;
           return r.id;
     
     end "bounds_clause";/*}*/


     /*}*/
     -- "C"/*{*/

     function  "case_expression"                (tg in out token_getter) return number is/*{*/
           r nd_case_expression%rowtype;
     begin
           e('case_expression', tg);
    
           if not tg.type_('ID') then
              p('case_expression: not an ID, returning null');
              l;
              return null;
           end if;

           if not tg.compare_i('case') then
              p('case_expression: not CASE, returning null');
              l;
              return null;
           end if;

           p('case_expression: CASE found');
           tg.next_stored_program_token;

           -- First: the 'searched case expression' because
           -- this starts with a 'WHEN' which should be easy
           -- to identify...

           p('case_expression: searched_case_expression?');
           r.searched_case_expression := "searched_case_expression"(tg);

           if r.searched_case_expression is null then
              p('case_expression: simple_case_expression?');
              r.simple_case_expression := "simple_case_expression"(tg);

              if r.simple_case_expression is null then
                 raise_error(tg, 'CASE expression: neither searched nor simple.');
              end if;
           end if;

           r.else_clause := "else_clause"(tg);

           if not tg.compare_i('end') then
              raise_error(tg, 'end expected');
           end if;

           tg.next_stored_program_token;

           next_nd_seq(r.id);
           insert into nd_case_expression values r;
           p('case_expression: ok');
           l;
           return r.id;

     end "case_expression";/*}*/

     function  "case_statement"                 (tg in out token_getter) return number is/*{*/
           r nd_case_statement%rowtype;
     begin
           e('case_statement', tg);
    
           if not tg.type_('ID') then
              p('case_statement: not an ID, returning null');
              l;
              return null;
           end if;

           if not tg.compare_i('case') then
              p('case_statement: not CASE, returning null');
              l;
              return null;
           end if;

           p('case_statement: CASE found');
           tg.next_stored_program_token;

           -- First: the 'searched case statement' because
           -- this starts with a 'WHEN' which should be easy
           -- to identify...

           p('case_statement: searched_case_statement?', tg);
           r.searched_case_statement := "searched_case_statement"(tg);

           if r.searched_case_statement is null then/*{*/
              p('case_statement: simple_case_statement?', tg);
              r.simple_case_statement := "simple_case_statement"(tg);

              if r.simple_case_statement is null then
                 raise_error(tg, 'CASE statement: neither searched nor simple.');
              end if;
           end if;/*}*/

           if is_id_eaten(tg, 'else') then/*{*/
              r.else_statement_list := "statement_list"(tg);
           end if;/*}*/

           if not is_id_eaten(tg, 'end') then/*{*/
              raise_error(tg, 'end expected');
           end if;/*}*/

           if not is_id_eaten(tg, 'case') then/*{*/
              raise_error(tg, 'end case expected');
           end if;/*}*/

           eat_semicolon(tg);

           next_nd_seq(r.id);
           insert into nd_case_statement values r;
           p('case_statement: returning ' || r.id);
           l;
           return r.id;

     end "case_statement";/*}*/

     function  "cast"                           (tg in out token_getter) return number is/*{*/
          r  nd_cast%rowtype;
     begin

         e('cast', tg);

         if not is_id_eaten(tg, 'cast') then/*{*/
            p('cast: no CAST, returning null');
            l;
            return null;
         end if;/*}*/

         p('cast: opening (?', tg);
         if not tg.type_('SYM') or tg.token_value_sym != '(' then
            raise_error(tg, '( expected');
         end if;
         tg.next_stored_program_token;

         p('cast: multiset?', tg);
         if is_id_eaten(tg, 'multiset') then/*{*/

            if not tg.type_('SYM') or tg.token_value_sym != '(' then/*{*/
               raise_error(tg, '( expected');
            end if;/*}*/
            tg.next_stored_program_token;

            -- TODO_0052: should this not be a 'select_statement'?
            r.multiset_subquery := "subquery"(tg, into_clause => false);
            if r.multiset_subquery is null then
               raise_error(tg, 'multiset_subquery is null');
            end if;

            if not tg.type_('SYM') or tg.token_value_sym != ')' then
               raise_error(tg, ') expected');
            end if;
            tg.next_stored_program_token;
         /*}*/
         else/*{*/
            p('cast: not multiset, expression?', tg);
            r.expression := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);
            if r.expression is null then
               raise_error(tg, 'expression is null');
            end if;
         end if;/*}*/

         p('cast: AS?', tg);
         if not is_id_eaten(tg, 'as') then/*{*/
            raise_error(tg, 'as expected');
         end if;/*}*/

         p('cast: datatype?', tg);
         r.datatype := "datatype"(tg, with_precision => true);
         if r.datatype is null then/*{*/
            raise_error(tg, 'datatype expected');
         end if;/*}*/

         if not tg.type_('SYM') or tg.token_value_sym != ')' then/*{*/
            raise_error(tg, '0 expected');
         end if;/*}*/
         tg.next_stored_program_token;
         
         next_nd_seq(r.id);
         insert into nd_cast values r;
         p('cast: returning ' || r.id);
         l;
         return r.id;

     end "cast";/*}*/

     function  "close_statement"                (tg in out token_getter) return number is/*{*/
          r  nd_close_statement%rowtype;
     begin
          e('close_statement', tg);

          if not is_id_eaten(tg, 'close') then
             p('close_statement: not CLOSE, returning null');
             l;
             return null;
          end if;

          p('close_statement: plsql_identifier?');
          -- TODO_0053: complex_plsql_ident?
          r.name := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);
          if r.name is null then
             raise_error(tg, 'name expected for cursor');
          end if;

          eat_semicolon(tg);

          next_nd_seq(r.id);
          insert into nd_close_statement values r;
          p('close_statement: returning ' || r.id);
          l;
          return r.id;

     end "close_statement";/*}*/

     function  "collection_type_definition"     (tg in out token_getter) return number is/*{*/
         r nd_collection_type_definition%rowtype;
     begin

          e('collection_type_definition', tg);

          if not tg.compare_i('type') then/*{*/
             p('collection_type_definition: keyword TYPE not found, returning null');
             l;
             return null;
          end if;/*}*/

          tg.next_stored_program_token;
          r.name := get_id(tg, 'Name of collection type expected');

          p('collection_type_definition: Name of collection type: ' || r.name);

          if not tg.compare_i('IS') then
             raise_error(tg, 'IS expected');
          end if;

          tg.next_stored_program_token;

          p('collection_type_definition: assoc_array_type_def?', tg);
          r.assoc_array_type_def := "assoc_array_type_def"(tg);
          if r.assoc_array_type_def is not null then/*{*/
             p('collection_type_definition: is an assoc_array_type_def, eat_semicolon', tg);

             eat_semicolon(tg);

             next_nd_seq(r.id);
             insert into nd_collection_type_definition values r;
             l;
             return r.id;
          end if;/*}*/

          p('collection_type_definition: nested_table_type_def?', tg);
          r.nested_table_type_def := "nested_table_type_def"(tg);
          if r.nested_table_type_def is not null then/*{*/

             p('collection_type_definition: nested_table_type_def found, eat_semicolon', tg);
             eat_semicolon(tg);

             next_nd_seq(r.id);
             insert into nd_collection_type_definition values r;
             p('collection_type_definition: returning ' || r.id, tg);
             l;
             return r.id;

          end if;/*}*/

          
          p('collection_type_definition: nothing found, returning null');
        
          l;
          return null;

     end "collection_type_definition";/*}*/

     function  "condition"                      (tg in out token_getter, check_outer_join_symbol in boolean, prior_ in boolean, boolean_factor in boolean, aggregate_function in boolean) return number is/*{*/
     --  TODO_0054: is this a 'boolean expression'?
     --             See -> exit/continue_statement, for example
          r nd_condition%rowtype;
     begin
          -- TODO_0055: precedence
          --        o SQL operators are evaluated before SQL conditions
          --        o =, !=, <, >, <=, >=,
          --        o IS [NOT] NULL, LIKE, [NOT] BETWEEN, [NOT] IN, EXISTS, IS OF type
          --        o NOT
          --        o AND
          --        o OR

          e('condition', tg);

          -- A condition is basically a chain of logical terms (that are connected
          -- by ORs). We're now gonna get the logical_term_list (that make up
          -- said logical term chain).

          p('condition: getting the logical term list that makes the condition, prior_ = ' || case when prior_ then 'true' else 'false' end);

          r.logical_term_list := "logical_term_list"(tg, check_outer_join_symbol=>check_outer_join_symbol, prior_ => prior_, boolean_factor => boolean_factor, aggregate_function => aggregate_function);

          if r.logical_term_list is null then/*{*/
             p('condition: logical_term_list is null, returning null');
             l;
             return null;
          end if;/*}*/

          next_nd_seq(r.id);
          insert into nd_condition values r;
          p('condition: returning ' || r.id, tg);
          l;
          return r.id;

     end "condition";/*}*/

     function  "connect_by_condition"           (tg in out token_getter) return number is/*{*/
          condition number;
     begin
          -- There is no 'node' associated with a connect by condition.
          -- The id of a condition is returned instead.
          -- However, the function checks for the existence of the keywords
          --'CONNECT' and 'BY'.
          -- TODO_0043: This function is quite similar to -> "start_with_condition";

          e('connect_by_condition', tg);

          if not is_id_eaten(tg, 'connect') then/*{*/
             p('connect_by_condition: no CONNECT, return null');
             l;
             return null;
          end if;/*}*/

          if not is_id_eaten(tg, 'by') then
             raise_error(tg, 'BY in connect by condition expected');
          end if;

          condition := "condition"(tg, check_outer_join_symbol=>false /* TODO_0056: or should it be true? */, prior_ => true, boolean_factor => false, aggregate_function => false);

          if condition is null then 
             raise_error(tg, 'condition expected for connect by');
          end if;

          p('connect_by_condition: ok, returning ' || condition);
          l;
          return condition;

     end "connect_by_condition";/*}*/

     function  "constant_declaration"           (tg in out token_getter) return number is /*{*/

         r nd_constant_declaration%rowtype;

     begin
     -- TODO_0048
     --   Note the similarity to a 
     --  "variable_declaration".

         e('constant_declaration', tg);

         if tg.type_('ID') then/*{*/
            r.name := upper(tg.current_token_.token_);
            if is_keyword(r.name) then/*{*/
               p('constant_declaration: name would be a keyword, returning null');
               l;
               return null;
            end if;/*}*/
         else
            p('constant_declaration: Not an ID, therefore not a constant declaration, returning');
            l;
            return null;
         end if;/*}*/

         tg.next_stored_program_token;

         if not tg.compare_i('constant') then
            p(r.name || ' is no constant declaration, returning');
            l;
            return null;
         end if;

         tg.next_stored_program_token;

         r.datatype   := "datatype"(tg, with_precision => true);

         if r.datatype is null then
            raise_error(tg, 'constant_declaration: datatype is null');
         end if;

         if tg.compare_i('not') then/*{*/
            tg.next_stored_program_token;

            if not tg.compare_i('null') then
               raise_application_error('-20800', 'not null expected');
            end if;

            tg.next_stored_program_token;
         end if;/*}*/

         if tg.token_value_sym != ':=' then
            raise_error(tg, ':= expected');
         end if;

         tg.next_stored_program_token;

         r.expression := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

         if r.expression is null then 
            raise_error(tg, 'expression expected');
         end if;

         tg.next_stored_program_token;

         next_nd_seq(r.id);

         -- TODO_0057: shouldn't be checked for a ';' here?

         p('valid constant declaration');
         insert into nd_constant_declaration values r;
         l;
         return r.id;

     end "constant_declaration";/*}*/

     function  "complex_plsql_ident"            (tg in out token_getter, star_ in boolean) return number is/*{*/
           r nd_complex_plsql_ident%rowtype;
     begin

           e('complex_plsql_ident', tg);
         
           next_nd_seq(r.id);
           insert into nd_complex_plsql_ident values r;

           if not "complex_plsql_ident_elem"(tg, r.id, first => true, star_ => star_) then/*{*/
              delete from nd_complex_plsql_ident where id = r.id;
              p('complex_plsql_ident: returning null', tg);
              l;
              return null;
           end if;/*}*/
           
           while "complex_plsql_ident_elem"(tg, r.id, first => false, star_ => star_) loop/*{*/
                  null; --p('complex_plsql_ident: ', tg);
           end loop;/*}*/

           if tg.type_('SYM') and tg.token_value_sym = '%' then
              tg.next_stored_program_token;

              if is_id_eaten(tg, 'found') then
                 r.found := 1;
              end if;

           end if;

           p('complex_plsql_ident: returning ' || r.id, tg);
           l;
           return r.id;

     end "complex_plsql_ident";/*}*/

     function  "complex_plsql_ident_elem"       (tg in out token_getter, complex_plsql_ident in number, first in boolean, star_ in boolean) return boolean is/*{*/
          r  nd_complex_plsql_ident_elem%rowtype;
     begin

          e('complex_plsql_ident_elem', tg);

          r.complex_plsql_ident := complex_plsql_ident;

          if first then /*{*/
             p('complex_plsql_ident: first, plsql_identifier?');
             r.plsql_identifier := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => star_);

             if r.plsql_identifier is null then
                p('complex_plsql_ident: no first plsql_identifier, returning false', tg);
                l;
                return false;
             end if;

             insert into nd_complex_plsql_ident_elem values r;
             p('complex_plsql_ident: no first plsql_identifier, returning true', tg);
             l;
             return true;
          end if;/*}*/

          if not tg.type_('SYM') then/*{*/
             p('complex_plsql_ident: no SYM, returning false', tg);
             l;
             return false;
          end if;/*}*/

          p('complex_plsql_ident_elem: parameter_list?', tg);
          r.paran_parameter_list := "parameter_list"(tg, check_outer_join_symbol => false);

          if r.paran_parameter_list is not null then/*{*/
             insert into nd_complex_plsql_ident_elem values r;
             p('complex_plsql_ident_elem: returning true', tg);
             l;
             return true;
          end if;/*}*/

          if tg.token_value_sym = '.' then/*{*/

             tg.next_stored_program_token;
             -- TODO_0030: something like *.* should not be accepted.
             r.plsql_identifier := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => star_);
             
             if r.plsql_identifier is null then/*{*/
                raise_error(tg, 'plsql_identifier expected');
             end if;/*}*/

             insert into nd_complex_plsql_ident_elem values r;
             p('complex_plsql_ident_elem: returning true (.)', tg);
             l;
             return true;
          end if;/*}*/

          p('complex_plsql_ident_elem: returning false', tg);
          l;
          return false;

     end "complex_plsql_ident_elem";/*}*/

     function  "cursor_definition"              (tg in out token_getter) return number is/*{*/
           r nd_cursor_definition%rowtype;
     begin

           e('cursor_definition', tg);

           if not tg.type_('ID') then
              l;
              return null;
           end if;

           if not tg.compare_i('cursor') then
              l;
              return null;
           end if;

           tg.next_stored_program_token;

           r.name := get_id(tg, 'Name of cursor expected');

           p('cursor_definition: Name is ' || r.name || ', parameter_declaration_list?');

           r.parameter_declaration_list := "parameter_declaration_list"(tg, false);

           if tg.compare_i('return') then/*{*/
              raise_error(tg, 'Return for Cursor Definition');
           end if;/*}*/

           if not tg.compare_i('IS') then/*{*/
              raise_error(tg, 'Cursor defintion requires IS');
           end if;/*}*/

           tg.next_stored_program_token;

           p('cursor_definition: select_statement?');
           r.select_statement := "select_statement"(tg, plsql => false);

           if r.select_statement is null then/*{*/
              raise_error(tg, 'Select statement missing for Cursor ' || r.name);
           end if;/*}*/

           p('cursor_definition: ending ; ?', tg);
           if not tg.type_('SYM') then/*{*/
              raise_error(tg, '; expected for Cursor ' || r.name);
           end if;/*}*/

           if tg.token_value_sym != ';' then/*{*/
              raise_error(tg, '; expected for Cursor ' || r.name);
           end if;/*}*/

           tg.next_stored_program_token;

           next_nd_seq(r.id);

           insert into nd_cursor_definition values r;

           p('cursor_definition: id ' || r.id || ' inserted');

           l;
           return r.id;

     end "cursor_definition";/*}*/

     function  "cursor_for_loop_statement"      (tg in out token_getter) return number is/*{*/
           r nd_cursor_for_loop_statement%rowtype;
     begin

           e('cursor_for_loop_statement', tg);

           if not is_id_eaten(tg, 'for') then
              p('cursor_for_loop_statement: no FOR, returning null');
              l;
              return null;
           end if;

--         r.record_ := get_id(tg, 'cursor name expected');
           if not tg.type_('ID') then
              raise_error(tg, 'record_ expected');
           end if;

           r.record_ := tg.token_value;
           tg.next_stored_program_token;
           

           if not is_id_eaten(tg, 'in') then
              raise_error(tg, 'IN expected in cursor_for_loop_statement');
           end if;

           if tg.type_ = 'SYM' and tg.token_value_sym = '(' then
              tg.next_stored_program_token;

              r.select_statement := "select_statement"(tg, plsql => false);

              if not tg.token_value_sym = ')' then
                 raise_error(tg, 'closing ) expected after select statement');
              end if;
              tg.next_stored_program_token;

           else 

              r.cursor_ := get_id(tg, 'cursor name expected');
              r.actual_cursor_parameter := "parameter_list"(tg, check_outer_join_symbol => false);

           end if;


           if not is_id_eaten(tg, 'loop') then/*{*/
              raise_error(tg, 'loop expected');
           end if;/*}*/

           r.statement_list := "statement_list"(tg);

           if not is_id_eaten(tg, 'end') then
              raise_error(tg, 'end expected');
           end if;

           if not is_id_eaten(tg, 'loop') then
              raise_error(tg, 'loop expected');
           end if;

           p('for_loop_statement: label?');
           r.label_ := eat_id_or_return_null(tg);

           eat_semicolon(tg);

           next_nd_seq(r.id);
           insert into nd_cursor_for_loop_statement values r;
           p('cursor_for_loop_statement: returning ' || r.id);

           l;
           return r.id;

     end "cursor_for_loop_statement";/*}*/

     /*}*/
     -- "D"/*{*/

     function  "datatype"                       (tg in out token_getter, with_precision in boolean) return number is/*{*/
          r nd_datatype%rowtype;
     begin

          e('datatype', tg);

          r.scalar_datatype                  := "scalar_datatype" (tg, with_precision);/*{*/
          if r.scalar_datatype is not null then
             next_nd_seq(r.id);
             insert into nd_datatype values r;
             l;
             return r.id;
          end if;/*}*/
--        r.type_attribute                   := "type_attribute"  (tg);/*{*/
--        if r.type_attribute is not null then
--           next_nd_seq(r.id);
--           insert into nd_datatype values r;
--           l;
--           return r.id;
--        end if;/*}*/
          
          r.typename_plsql_identifier        := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);/*{*/
          if r.typename_plsql_identifier is not null then
             next_nd_seq(r.id);
             
             if tg.type_('SYM') and tg.token_value_sym = '%' then -- Check for '%rowtype /*{*/
                tg.next_stored_program_token;

                if    tg.compare_i('rowtype') then/*{*/
                      tg.next_stored_program_token;
                      r.rowtype_ := 1;
                /*}*/
                elsif tg.compare_i('type') then/*{*/
                      tg.next_stored_program_token;
                      r.type_    := 1;
                /*}*/
                else/*{*/
                   raise_error(tg, 'ROWTYPE or TYPE after % in datatype expected');

                end if;/*}*/

             end if;/*}*/

             insert into nd_datatype values r;
             l;
             return r.id;
          end if;/*}*/

          l;
          return null;

     end "datatype";/*}*/
    
     function  "declare_section"                (tg in out token_getter, autonomous_transaction_allowed in boolean) return number is/*{*/

         r nd_declare_section%rowtype;
         id_item_list_1    number(8);

     begin

         e('declare_section', tg);

         if tg.type_('ID') and tg.compare_i('begin') then/*{*/
            p('declare_section: BEGIN found, returning null');
            l;
            return null;
         end if;/*}*/

         p('declare_section: item_list_1?', tg);
         r.item_list_1 := "item_list_1"(tg, autonomous_transaction_allowed => autonomous_transaction_allowed);
 
         p('declare_section: item_list_2?', tg);
         r.item_list_2 := "item_list_2"(tg);
 
         if r.item_list_1 is null  and r.item_list_2 is null  then/*{*/
            p('declare_section: no item list at all, returning null');
            l;
            return null;
         end if;/*}*/
 
         next_nd_seq(r.id);
         
         insert into nd_declare_section values r;
         p('declare_section: returning ' || r.id, tg); 
         l;
         return r.id;

     end "declare_section";/*}*/

     function  "delete_statement"               (tg in out token_getter) return number is/*{*/
           r nd_delete_statement%rowtype;
     begin
       
           e('delete_statement', tg);

           if not is_id_eaten(tg, 'delete') then/*{*/
              p('delete_statement: not DELETE, returning null');
              l;
              return null;
           end if;/*}*/

           p('delete_statement: hint?',tg);
           r.hint := "hint"(tg);

           p('delete_statement: from?', tg);
           if is_id_eaten(tg, 'from') then/*{*/
              r.from_ := 1;
           end if;/*}*/

           p('delete_statement: dml_table_expression_clause?', tg);
           r.dml_table_expression_clause := "dml_table_expression_clause"(tg);
           -- TODO_0047 or "ONLY (dml_table_expression_clause)"

           p('delete_statement: alias?', tg);
           if tg.type_('ID') and not is_keyword(tg.token_value) then/*{*/
              r.alias_ := get_id(tg, null);
           end if;/*}*/

           p('delete_statement: where_clause?', tg);
           r.where_clause     := "where_clause"(tg);

           p('delete_statement: returning_clause?', tg);
           r.returning_clause := "returning_clause"(tg);

           p('delete_statement: error_logging_clause?', tg);
           r.error_logging_clause := "error_logging_clause"(tg);

           p('delete_statement: semicolon?', tg);
           eat_semicolon(tg);

           next_nd_seq(r.id);

           insert into nd_delete_statement values r;
           p('delete_statement: returning ' || r.id);
           l;
           return r.id;


     end "delete_statement";/*}*/

     function  "dml_statement"                  (tg in out token_getter) return number is/*{*/
          r  nd_dml_statement%rowtype;
     begin

          e('dml_statement', tg);

          p('dml_statement: insert_statement?', tg);
          r.insert_statement := "insert_statement"(tg);
          if r.insert_statement is not null then/*{*/
             next_nd_seq(r.id);
             insert into nd_dml_statement values r;
             p('dml_statement: returning ' || r.id);
             l;
             return r.id;
          end if;/*}*/

          p('dml_statement: delete_statement?', tg);
          r.delete_statement := "delete_statement"(tg);
          if r.delete_statement is not null then/*{*/
             next_nd_seq(r.id);
             insert into nd_dml_statement values r;
             p('dml_statement: returning ' || r.id);
             l;
             return r.id;
          end if;/*}*/

          p('dml_statement: update_statement?', tg);
          r.update_statement := "update_statement"(tg);
          if r.update_statement is not null then/*{*/
             next_nd_seq(r.id);
             insert into nd_dml_statement values r;
             p('dml_statement: returning ' || r.id);
             l;
             return r.id;
          end if;/*}*/

          p('dml_statement: returning null', tg);
          l;
          return null;

     end "dml_statement";/*}*/

     function  "dml_table_expression_clause"    (tg in out token_getter) return number is/*{*/
         r   nd_dml_table_expression_clause%rowtype;
     begin
         
         e('dml_table_expression_clause', tg);

         p('dml_table_expression_clause: plsql_identifier?');
         r.plsql_identifier := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);
         if r.plsql_identifier is null then
            p('dml_table_expression_clause: no plsql_identifier, returning null');
            l;
            return null;
         end if;

         next_nd_seq(r.id);
         insert into nd_dml_table_expression_clause values r;

         p('dml_table_expression_clause: returning ' || r.id, tg);
         l;
         return r.id;
           
      
     end "dml_table_expression_clause";/*}*/

     /*}*/
     -- "E"/*{*/

     function  "else_clause"                    (tg in out token_getter) return number is/*{*/
          r  nd_else_clause%rowtype;
     begin

       e('else_clause', tg);

       if not tg.type_('ID') then
          p('else_clause: not ELSE ID, returning null');
          l;
          return null;
       end if;

       if not tg.compare_i('else') then
          p('else_clause: not ELSE, returning null');
          l;
          return null;
       end if;

       tg.next_stored_program_token;
       r.expression := "expression"(tg, check_outer_join_symbol => false, star_ => false, aggregate_function => false, prior_ => false);

       next_nd_seq(r.id);
       p('else_clause: ok');
       l;
       insert into nd_else_clause values r;

       return r.id;

     end "else_clause";/*}*/

     function  "elsif_elem"                     (tg in out token_getter, elsif_list in number) return boolean is/*{*/
           r nd_elsif_elem%rowtype;
     begin

           e('elsif_elem', tg);

           if not is_id_eaten(tg, 'elsif') then/*{*/
              p('elsif_elem: no ELSIF, returning false');
              l;
              return false;
           end if;/*}*/

           p('elsif_elem: condition?');
           r.boolean_expression := "condition"(tg, check_outer_join_symbol => false, prior_ => false, boolean_factor => true, aggregate_function => false);
           if r.boolean_expression is null then/*{*/
              p('elsif_elem: no condition found, returning false');
              raise_error(tg, 'condtion expected in elsif');
           end if;/*}*/

           if not is_id_eaten(tg, 'then') then/*{*/
              raise_error(tg, 'THEN expected');
           end if;/*}*/

           p('elsif_elem: statement_list?');
           r.statement_list := "statement_list"(tg);
           if r.statement_list is null then/*{*/
              raise_error(tg, 'statement_list expected in elsif');
           end if;/*}*/

           r.elsif_list := elsif_list;
           insert into nd_elsif_elem values r;
           p('elsif_elem: returning true');
           return true;

     end "elsif_elem";/*}*/

     function  "elsif_list"                     (tg in out token_getter) return number is/*{*/
           r nd_elsif_list%rowtype;
     begin

          e('elsif_list', tg);

          next_nd_seq(r.id);
          insert into nd_elsif_list values r;
          p('elsif_list: first elsif_elem?');
          if not "elsif_elem"(tg, r.id) then/*{*/
             delete from nd_elsif_list where id = r.id;
             p('elsif_list: no first elsif_elem, returning null');
             l;
             return null;
          end if;/*}*/

          while "elsif_elem"(tg,r.id) loop/*{*/
             p('elsif_list: elsif_elem found');
          end loop;/*}*/

          p('elsif_list: returning ' || r.id);
          l;
          return r.id;
     
     end "elsif_list";/*}*/

     function  "error_logging_clause"           (tg in out token_getter) return number is/*{*/
          r  nd_error_logging_clause%rowtype;
     begin

         -- TODO_0058
         return null;

     end "error_logging_clause";/*}*/

     function  "execute_immediate_statement"    (tg in out token_getter) return number is/*{*/
           r nd_execute_immediate_statement%rowtype;
     begin

         e('execute_immediate_statement', tg);

         if not is_id_eaten(tg, 'execute') then/*{*/
            p('execute_immediate_statement: no EXECUTE, returning null');
            l;
            return null;
         end if;/*}*/

         if not is_id_eaten(tg, 'immediate') then/*{*/
            raise_error(tg, 'IMMEDIATE expected');
         end if;/*}*/

         p('execute_immediate_statement: dynamic_sql_statement_expr?');
         -- TOOD: name it dynamic_sql_statement_expr
         r.dynamic_sql_statment_expr := "expression"(tg, check_outer_join_symbol => false, star_ => false, aggregate_function => false, prior_ => false);
         if r.dynamic_sql_statment_expr is null then/*{*/
            raise_error(tg, 'dynamic_sql_statment_expr expected');
         end if;/*}*/

         p('execute_immediate_statement: into_clause?');
         r.into_clause := "into_clause"(tg);

         p('execute_immediate_statement: using_clause?');
         r.using_clause := "using_clause"(tg);

         p('execute_immediate_statement: eat_semicolon', tg);
         eat_semicolon(tg);

         next_nd_seq(r.id);
         insert into nd_execute_immediate_statement values r;
         p('execute_immediate_statement: returning ' || r.id);
         l;
         return r.id;

     end "execute_immediate_statement";/*}*/

     function  "exception_declaration"          (tg in out token_getter) return number is /*{*/

         r nd_exception_declaration%rowtype;

     begin

        e('exception_declaration', tg);

         if tg.type_('ID') then
            r.name := get_id(tg);
         else
            p('exception_declaration: Not an ID, therefore not an exception_declaration , returning');
            l;
            return null;
         end if;

--       tg.next_stored_program_token;

         if not tg.compare_i('EXCEPTION') then/*{*/
            p('exception_declaration: keyword EXCEPTION not found, is not an exception declaration.');
            l;
            return null;
         end if;/*}*/

         tg.next_stored_program_token;

         if not tg.type_('SYM') then
            p('exception_declaration: doesn''t end with ;');
            l;
            return null;
         end if;

         if tg.token_value_sym != ';' then
            p('exception_declaration: doesn''t end with ;');
            l;
            return null;
         end if;

         tg.next_stored_program_token;

         next_nd_seq(r.id);

         p('exception_declaration: valid excpetion declaration');
         insert into nd_exception_declaration values r;
         l;
         return r.id;

     end "exception_declaration";/*}*/

     function  "exception"                      (tg in out token_getter, exception_list in number) return boolean is/*{*/
         r   nd_exception%rowtype;
     begin

          e('exception', tg);

          if tg.type_('ID') then/*{*/

             r.exception_list         := exception_list;

             case lower(tg.token_value) 
                  when 'access_into_null'        then r.access_into_null_         := 1;
                  when 'case_not_found'          then r.case_not_found_           := 1;
                  when 'collection_is_null'      then r.collection_is_null_       := 1;
                  when 'cursor_already_open'     then r.cursor_already_open_      := 1;
                  when 'dup_val_on_index'        then r.dup_val_on_index_         := 1;
                  when 'invalid_cursor'          then r.invalid_cursor_           := 1;
                  when 'invalid_number'          then r.invalid_number_           := 1;
                  when 'login_denied'            then r.login_denied_             := 1;
                  when 'no_data_found'           then r.no_data_found_            := 1;
                  when 'no_data_needed'          then r.no_data_needed_           := 1;
                  when 'not_logged_on'           then r.not_logged_on_            := 1;
                  when 'program_error'           then r.program_error_            := 1;
                  when 'rowtype_mismatch'        then r.rowtype_mismatch_         := 1;
                  when 'self_is_null'            then r.self_is_null_             := 1;
                  when 'storage_error'           then r.storage_error_            := 1;
                  when 'subscript_beyond_count'  then r.subscript_beyond_count_   := 1;
                  when 'subscript_outside_limit' then r.subscript_outside_limit_  := 1;
                  when 'sys_invalid_rowid'       then r.sys_invalid_rowid_        := 1;
                  when 'timeout_on_resource'     then r.timeout_on_resource_      := 1;
                  when 'too_many_rows'           then r.too_many_rows_            := 1;
                  when 'value_error'             then r.value_error_              := 1;
                  when 'zero_divide'             then r.zero_divide_              := 1;
                  else r.user_defined_exception := tg.token_value;
                  end case;

             tg.next_stored_program_token;

             insert into nd_exception values r;

             l;
             return true;
             
          end if;/*}*/

          l;
          return null;

     end "exception";/*}*/

     function  "exception_list"                 (tg in out token_getter) return number is/*{*/
           r nd_exception_list%rowtype;
     begin

     --  an exception list consists of "exceptions" that are connected by 'OR'.
     --  Used as Part of the exception handler

          next_nd_seq(r.id); 
          insert into nd_exception_list values r;

          if not "exception"(tg, r.id) then/*{*/
             delete from nd_exception_list where id = r.id;
             return null;
          end if;/*}*/

          while is_id_eaten(tg, 'or') loop /*{*/

                if not "exception"(tg, r.id) then
                   raise_error(tg, 'exception expected');
                end if;

          end loop;/*}*/

          return r.id;

     end "exception_list";/*}*/

     function  "exception_handler"              (tg in out token_getter, exception_handler_list in number) return boolean is/*{*/
           r nd_exception_handler%rowtype;
     begin
     --
     --    http://download.oracle.com/docs/cd/E11882_01/appdev.112/e17126/exception_handler.htm#i33826
     --
     --    WHEN excpetion_1 [ OR excpetion_2 ...] THEN statement
     --
           e('exception_handler', tg);

           if not is_id_eaten(tg, 'when') then/*{*/
              p('exception_handler: no WHEN, returning false');
              l;
              return false;
           end if;/*}*/

--           p('exception_handler: exception_handler_list?', tg);

           r.exception_handler_list := exception_handler_list;
--
--           if r.exception_handler_list is null then/*{*/
--              raise_error(tg, 'exception_handler_list expected');
--           end if;/*}*/
--
--           r.exception_handler_list := exception_handler_list;

           if   is_id_eaten(tg, 'others') then 
                r.others_ := 1;
           
           else  
                r.exception_list := "exception_list"(tg);
                if r.exception_list is null then/*{*/
                   p('exception_handler: neither others nor exception list, returning false', tg);
                   l;
                   return false;
                end if;/*}*/
           end if;

           p('exception_handler: then?', tg);
           if not is_id_eaten(tg, 'then') then
              raise_error(tg, 'then expected');
           end if;


           p('exception_handler: statement_list?', tg);
           r.statement_list := "statement_list"(tg);

           if r.statement_list is null then
              raise_error(tg, 'statement_list expected');
           end if;

           insert into nd_exception_handler values r;
           p('exception_handler_list: returning true');
           l;
           return true;

     end "exception_handler";/*}*/

     function  "exception_handler_list"         (tg in out token_getter) return number is/*{*/
          r  nd_exception_handler_list%rowtype;
     begin

           e('exception_handler_list', tg);

           if not is_id_eaten(tg, 'exception') then/*{*/
              p('exception_handler_list: not EXCEPTION, returning null');
              l;
              return null;
           end if;/*}*/

           next_nd_seq(r.id);
           insert into nd_exception_handler_list values r;

           if not "exception_handler"(tg, r.id) then
              raise_error(tg, 'at least on exception handler expected');
--            delete from nd_exception_handler_list where id = r.id; 
           end if;

           while "exception_handler"(tg, r.id) loop
                  null;
           end loop;

           p('exception_handler: returning ' || r.id);
           l;
           return r.id;

     end "exception_handler_list";/*}*/

     function  "exception_init_pragma"          (tg in out token_getter) return number is/*{*/
          r  nd_exception_init_pragma%rowtype;
     begin

          if not tg.type_('ID') then
             return null;
          end if;

          if not tg.compare_i('exception_init') then
             return null;
          end if;

          tg.next_stored_program_token;

          if not tg.type_('SYM') then
             raise_error(tg, 'exception_init pragma requires (');
          end if;

          if not tg.token_value_sym = '(' then
             raise_error(tg, 'exception_init pragma requires (');
          end if;

          tg.next_stored_program_token;

          r.exception_ := get_id(tg, 'exception id expected for exception_init_pragma');

          if not tg.type_('SYM') then
             raise_error(tg, 'exception_init pragma requires (');
          end if;

          if not tg.token_value_sym = ',' then
             raise_error(tg, 'exception_init pragma requires , after exception');
          end if;

          tg.next_stored_program_token;

          r.error_code := numeric_literal(tg); -- TODO_0059: Range Check?

          if not tg.type_('SYM') then
             raise_error(tg, 'exception_init pragma requires )');
          end if;

          if not tg.token_value_sym = ')' then
             raise_error(tg, 'exception_init pragma requires )');
          end if;

          tg.next_stored_program_token;

          if not tg.type_('SYM') then
             raise_error(tg, 'exception_init pragma requires ;');
          end if;

          if not tg.token_value_sym = ';' then
             raise_error(tg, 'exception_init pragma requires ;');
          end if;

          tg.next_stored_program_token;

          next_nd_seq(r.id);

          insert into nd_exception_init_pragma values r;
          return r.id;


     end "exception_init_pragma";/*}*/

     function  "exists_condition"               (tg in out token_getter) return number is/*{*/
          r  nd_exists_condition%rowtype;
     begin
         e('exists_condition', tg);

         if not tg.type_('ID') or not tg.compare_i('exists') then/*{*/
            p('exists_condition: keyword EXISTS not found, returning null');
            l;
            return null;
         end if;/*}*/

         tg.next_stored_program_token;

         if not tg.type_('SYM') or not tg.token_value_sym = '(' then/*{*/
            raise_error(tg, '( expected after EXISTS');
         end if;/*}*/
         tg.next_stored_program_token;

         r.subquery := "subquery"(tg, into_clause => false);
         if not tg.type_('SYM') or not tg.token_value_sym = ')' then/*{*/
            raise_error(tg, ') expected after EXISTS');
         end if;/*}*/
         tg.next_stored_program_token;

         next_nd_seq(r.id);
         insert into nd_exists_condition values r;
         p('exists_condition: returning ' || r.id, tg);
         l;
         return r.id;

     end "exists_condition";/*}*/

     procedure "exit/continue_statement"        (tg in out token_getter, exit_statement in out number, continue_statement in out number) /*{*/
     is
           r nd_exit_statement%rowtype;

           is_exit      boolean := false;
           is_continue  boolean := false;
     begin

           if    is_id_eaten(tg, 'exit') then/*{*/
                 is_exit := true;
           elsif is_id_eaten(tg, 'continue') then
                 is_continue := true;
           else
                 return;
           end if;/*}*/

           if tg.type_('ID') and not tg.compare_i('when') then/*{*/
              r.label := tg.token_value;
              tg.next_stored_program_token;
           end if;/*}*/

           if is_id_eaten(tg, 'when') then/*{*/
              r.condition := "condition"(tg, check_outer_join_symbol => false, prior_ => false, boolean_factor => true, aggregate_function => false);
              if r.condition is null then
                 raise_error(tg, 'condition expected');
              end if;
           end if;/*}*/

           eat_semicolon(tg);

           next_nd_seq(r.id);

           if is_exit then/*{*/
              insert into nd_exit_statement values r;
              exit_statement := r.id;
           else
              insert into nd_continue_statement values r;
              continue_statement := r.id;
           end if;/*}*/

     end "exit/continue_statement";/*}*/

     function  "expression"                     (tg in out token_getter, check_outer_join_symbol in boolean, star_ in boolean, aggregate_function in boolean, prior_ in boolean) return number is/*{*/
       r     nd_expression%rowtype;
          addop varchar2(2);
     begin

       e('expression', tg);

       -- An expression consists of terms that are connected with + or -.
       
       next_nd_seq(r.id);
       insert into nd_expression values r;

       if prior_ then
          -- Check for the 'prior' operator. TODO_0060: is this the correct location to do so?
          p('expression: check for prior');
          if tg.type_('ID') and tg.compare_i('prior') then
             tg.next_stored_program_token;
             r.prior_ := 1;
          end if;
       else 
          p('expression: no check for prior');
       end if;

       -- The first term in an expression can be a 'star-term' if the expression can be a star-expression
       -- A 'star-term' is (as far as I can see) only used as a select_list item ("select * from table").
       if not "term"(tg, expression=>r.id, addop=>null, check_outer_join_symbol=>check_outer_join_symbol, star_ => star_, aggregate_function => aggregate_function) then
          p('expression: "term" returned false, returning null');
          delete from nd_expression where id = r.id;
          l;
          return null;
       end if;

       p('expression: first term found, searching for further terms (that are connected by + or -)', tg);

       loop

           if not tg.type_('SYM') then/*{*/
              p('expression: not an addop I');
              exit;
           end if;/*}*/

           if not tg.token_value_sym in ('+', '-', '||') then/*{*/
              p('expression: neither +, nor - nor ||', tg);
              exit;
           end if;/*}*/

           addop := tg.token_value_sym;

           p('expression: addop found: ' || addop);

           tg.next_stored_program_token;

           -- The n-th term (for n > 1) cannot be a star-term. Hence, star_ => false.
           if not "term"(tg, expression=>r.id, addop=>addop, check_outer_join_symbol=>check_outer_join_symbol, star_ => false, aggregate_function => aggregate_function) then
              raise_error(tg, 'term expected');
           end if;

       end loop;


       p('expression: found and finished, returning true');

       l;
       return r.id;

     end "expression";/*}*/

     function  "expression_list"                (tg in out token_getter) return number is/*{*/
           r nd_expression_list%rowtype;
     begin
     -- TODO_0061: Flag if it should check for paranthesis, too. See -> values_clause

          e('epxression_list', tg);

          next_nd_seq(r.id);

          insert into nd_expression_list values r;

          p('expression_list: checking if there''s at least on expression_list_elem');
          if not "expression_list_elem"(tg, r.id) then/*{*/
             delete from nd_expression_list where id = r.id;
             p('expression_list: no expression_list_elem, returning null');
             l;
             return null;
          end if;/*}*/

          p('expression_list: 1st expression_list_elem found, current token ' || tg.current_token_.token_);

          while tg.type_('SYM') and tg.token_value_sym = ',' loop
                tg.next_stored_program_token;
                if not "expression_list_elem"(tg, r.id) then
                        raise_error(tg, 'parameter elem expected');
                end if;
                p('expression_list: another expression_list_elem found');
          end loop;

          p('parameter_list: valid, id = ' || r.id);
          l;
          return r.id;

     end "expression_list";/*}*/

     function  "expression_list_elem"           (tg in out token_getter, expression_list in number) return boolean/*{*/
     is
           r nd_expression_list_elem%rowtype;
     begin

           r.expression_list := expression_list;

           r.expression := "expression"(tg, check_outer_join_symbol => false, star_ => false, aggregate_function => false, prior_ => false);

           if r.expression is null then
              return false;
           end if;

           insert into nd_expression_list_elem values r;
           return true;

     end "expression_list_elem";/*}*/

      /*}*/
     -- "F"/*{*/

     function  "factor"                         (tg in out token_getter, term in number, mulop in varchar2, check_outer_join_symbol in boolean /*TODO_0062: check_outer_join_symbol still used? */, star_ in boolean, aggregate_function in boolean) return boolean is/*{*/
          r  nd_factor%rowtype;
     begin

       e('factor', tg);
       r.term  := term;
       r.mulop := mulop;

       tg.push_state;

       -- checking for the special factor 'NULL';
       --(TODO_0063: null can be prefixed with a sign (select -null, +null from dual).
       if tg.type_('ID') then/*{*/
          if tg.compare_i('NULL') then
             p('factor: NULL');
             r.null_ := 1;
             next_nd_seq(r.id);
             insert into nd_factor values r;
             tg.next_stored_program_token;
             tg.remove_state;
             l;
             return true;
          end if;
       end if;/*}*/

       -- Checking for SIGN
       p('factor: checking for a sign');
       if tg.type_('SYM') then/*{*/
          if tg.token_value_sym in ('+', '-') then
             p('factor: Yes, it''s a sign: ' || tg.token_value_sym);
             r.sign_ := tg.token_value_sym;
             tg.next_stored_program_token;
          else
             p('factor: No, not a sign');
          end if;
       end if;/*}*/

       if aggregate_function then/*{*/
          p('factor: checking for an aggregate function');
          r.aggregate_function  := "aggregate_function"(tg);

          if r.aggregate_function is not null then
             p('factor: yes, is an aggregate_function');
             next_nd_seq(r.id);
             insert into nd_factor values r;
             tg.remove_state;
             l;
             return true;
          end if;
       end if;/*}*/

       p('factor: cast?', tg);
       r.cast_ := "cast"(tg);
       if r.cast_ is not null then/*{*/
          next_nd_seq(r.id);
          insert into nd_factor values r;
          tg.remove_state;
          p('factor: a cast expression, returning ' || r.id);
          l;
          return true;
       end if;/*}*/

       p('factor: case_expression?', tg);
       r.case_expression     := "case_expression"(tg);
       if r.case_expression is not null then/*{*/
         
          p('factor: a case expression');
          next_nd_seq(r.id);
          insert into nd_factor values r;
          tg.remove_state;
          l;
          return true;
       end if;/*}*/

       p('factor: complex_plsql_ident?');
       r.complex_plsql_ident := "complex_plsql_ident"(tg, star_ => star_);
       if r.complex_plsql_ident is not null then/*{*/
          tg.remove_state;
          next_nd_seq(r.id);
          insert into nd_factor values r;
          p('factor: yes, it''s a complex_plsql_ident, returning ' || r.id);
          l;
          return true;
       end if;/*}*/

       p('factor: function_expression?', tg);
       r.function_expression := "function_expression"(tg, check_outer_join_symbol=>check_outer_join_symbol);
       if r.function_expression is not null then/*{*/
          p('factor: yes, it''s a function expression');
          next_nd_seq(r.id);
          insert into nd_factor values r;
          tg.remove_state;
          l;
          return true;
       end if;/*}*/

       p('factor: scalar_subquery_expression?', tg);
       r.scalar_subquery_expression := "scalar_subquery_expression"(tg);
       if r.scalar_subquery_expression is not null then/*{*/
          p('factor: yes, scalar_subquery_expression', tg);
          next_nd_seq(r.id);
          insert into nd_factor values r;
          tg.remove_state;
          l;
          return true;
       end if;/*}*/

       p('factor: checking for opening parenthesis', tg);
       if tg.type_('SYM') then/*{*/
          if tg.token_value_sym = '(' then/*{*/

             tg.next_stored_program_token;

             p('factor: opening ( found, checking for an expression', tg);

             r.expression := "expression"(tg, check_outer_join_symbol=>check_outer_join_symbol, star_ => false, aggregate_function => aggregate_function, prior_ => false);

             if r.expression is not null then/*{*/

               if not tg.type_('SYM') or tg.token_value_sym != ')' then/*{*/
                  p('factor: closing paranthesis for factor-condition not found, not a factor', tg);
                  raise_error(tg, 'factor: closing paranthesis missing');
                  tg.pop_state;
                  l;
                  return false;
               end if;/*}*/
  
               tg.next_stored_program_token;
  
               tg.remove_state;
               next_nd_seq(r.id);
               insert into nd_factor values r;
               l;
               return true;

             end if;/*}*/

             
          end if;/*}*/
       end if;/*}*/

       if tg.type_('STR') then/*{*/
          p('factor: type is STR, so we have a string');
          r.string_ := tg.token_value_str;
          tg.next_stored_program_token;
          next_nd_seq(r.id);
          insert into nd_factor values r;
          tg.remove_state;
          l;
          return true;
       end if;/*}*/

       if tg.type_ in ('NUM', 'FLT') then/*{*/
          p('factor: type is NUM or FLT, so we have a num');
          r.num_flt := tg.current_token_.token_;
          tg.next_stored_program_token;
          next_nd_seq(r.id);
          insert into nd_factor values r;
          tg.remove_state;
          l;
          return true;
       end if;/*}*/

       p('factor: nothing found, returning null');
       tg.pop_state;
       l;
       return false;

     end "factor";/*}*/

     function  "fetch_statement"                (tg in out token_getter) return number is /*{*/
           r nd_fetch_statement%rowtype;
     begin
          
           e('fetch_statement', tg);

           if not is_id_eaten(tg, 'fetch') then
              p('fetch_statement: no keyword FETCH, returning null');
              l;
              return null;
           end if;

           -- TOOD: "plsql_identifier" should return at most one element. (?) // Or, alternatively, is it a complex_plsql_identifier_ident?
           p('fetch_statement: name?');
           r.name := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);
           if r.name is null then/*{*/
              raise_error(tg, 'name of cursor expected');
           end if;/*}*/

           r.into_clause := "into_clause"(tg);
           if r.into_clause is null then/*{*/
              raise_error(tg, 'into clause is null');
           end if;/*}*/

           p('fetch_statement: limit?');
           if is_id_eaten(tg, 'limit') then/*{*/
              r.limit := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);
           end if;/*}*/

           eat_semicolon(tg);

           next_nd_seq(r.id);
           insert into nd_fetch_statement values r;
           p('fetch_statement: returning ' || r.id);
           l;
           return r.id;

     end "fetch_statement";/*}*/

     function  "field_definition"               (tg in out token_getter, field_definition_list in number) return boolean is/*{*/
         r  nd_field_definition%rowtype;
     begin
         e('field_definition', tg);

         r.name := get_id(tg);

--       tg.next_stored_program_token;

         r.datatype := "datatype"(tg, with_precision => true);

--       tg.next_stored_program_token;

         r.field_definition_list := field_definition_list;

         insert into nd_field_definition values r;
         l;
         return true;


     end "field_definition";/*}*/

     function  "field_definition_list"          (tg in out token_getter) return number is/*{*/
          r nd_field_definition_list%rowtype;
     begin

       e('field_definition_list', tg);

          
       if not tg.type_('SYM') then
          l;
          return null;
       end if;

       if tg.token_value_sym != '(' then
          l;
          return null;
       end if;

       tg.next_stored_program_token;

       next_nd_seq(r.id);
       insert into nd_field_definition_list values r;

       if not "field_definition"(tg, r.id) then

          delete from nd_field_definition_list where id = r.id;
          l;
          return null;

       end if;

       while tg.type_('SYM') and tg.token_value_sym = ',' loop

             tg.next_stored_program_token;

             if not "field_definition"(tg, r.id) then
                raise_error(tg, 'Field definition expected');

             end if;

       end loop;

       if not tg.type_('SYM') then
          raise_error(tg, ') expected for FIELD DEFINITION LIST');
       end if;

       if tg.token_value_sym != ')' then
          raise_error(tg, ') expected for FIELD DEFINITION LIST');
       end if;

       tg.next_stored_program_token;

       l;
       return r.id;

     end "field_definition_list";/*}*/

     function  "for_loop_statement"             (tg in out token_getter) return number is/*{*/
           r nd_for_loop_statement%rowtype;
     begin
           
           e('for_loop_statement', tg);
           tg.push_state;

           if not is_id_eaten(tg, 'for') then/*{*/
              tg.pop_state;
              p('for_loop_statement: not FOR, returning null');
              l;
              return null;
           end if;/*}*/

           p('for_loop_statement: index?', tg);
           r.index_ := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);

           p('for_loop_statement: in?', tg);
           if not is_id_eaten(tg, 'in') then/*{*/
              raise_error(tg, 'IN expected in for_loop_statement');
           end if;/*}*/

           p('for_loop_statement: reverse?', tg);
           if is_id_eaten(tg, 'reverse') then
              r.reverse_ := 1;
           end if;

           -- TODO_0064: bounds_clause instead block {

           p('for_loop_statement: lower_bound expression?', tg);
           r.lower_bound := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

           if not tg.type_('SYM') or not tg.token_value_sym = '.' then/*{*/
              tg.pop_state;
              p('for_loop_statement: no .., returning null', tg);
              l;
              return null;
           end if;/*}*/
           tg.next_stored_program_token;

           if not tg.token_value_sym = '.' then
              raise_error(tg, '. expected');
           end if;
           tg.next_stored_program_token;

           p('for_loop_statement: upper_bound expression?');
           r.upper_bound := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

           -- TODO_0064: bounds_clause finish }

           p('for_loop_statement: loop?', tg);
           if not is_id_eaten(tg, 'loop') then
              raise_error(tg, 'loop expected');
           end if;

           p('for_loop_statement: statement_list?', tg);
           r.statement_list := "statement_list"(tg);
           if r.statement_list is null then 
              raise_error(tg, 'statement list expected');
           end if;

           p('for_loop_statement: end?', tg);
           if not is_id_eaten(tg, 'end') then/*{*/
              raise_error(tg, 'end expected');
           end if;/*}*/

           p('for_loop_statement: loop?', tg);
           if not is_id_eaten(tg, 'loop') then/*{*/
              raise_error(tg, 'loop expected');
           end if;/*}*/

           p('for_loop_statement: label?');
           r.label_ := eat_id_or_return_null(tg);
           
           p('for_loop_statement: semicolon?', tg);
           eat_semicolon(tg);

           next_nd_seq(r.id);
           insert into nd_for_loop_statement values r;
           tg.remove_state;
           p('for_loop_statement: returning ' || r.id);
           l;
           
           return r.id;

     end "for_loop_statement";/*}*/

     function  "forall_statement"               (tg in out token_getter) return number is/*{*/
          r  nd_forall_statement%rowtype;
     begin

          if not is_id_eaten(tg, 'forall') then/*{*/
             return null;
          end if;/*}*/

          r.index_ := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);

          if r.index_ is null then/*{*/
             raise_error(tg, 'index_ expected');
          end if;/*}*/

          if not is_id_eaten(tg, 'in') then/*{*/
             raise_error(tg, 'in expected');
          end if;/*}*/

          r.bounds_clause := "bounds_clause"(tg);
          if r.bounds_clause is null then
             raise_error(tg, 'bounds_clause expected');
          end if;

          -- TODO_0065 "SAVE EXCEPTIONS"

          r.dml_statement := "dml_statement"(tg);
          if r.dml_statement is null then/*{*/
             raise_error(tg, 'dml_statement is null');
          end if;/*}*/

          next_nd_seq(r.id);
          insert into nd_forall_statement values r;
          return r.id;


     end "forall_statement";/*}*/

     function  "for_update_clause"              (tg in out token_getter) return number is/*{*/
          r  nd_for_update_clause%rowtype;
     begin

          if not tg.type_('ID') then
             return null;
          end if;

          if not tg.compare_i('for') then
             return null;
          end if;

          tg.next_stored_program_token;

          if not tg.type_('ID') then
             raise_error(tg, 'UPDATE missing in for update clause');
          end if;

          if not tg.compare_i('update') then
             raise_error(tg, 'UPDATE missing in for update clause');
          end if;

          tg.next_stored_program_token;

          if tg.type_('ID') and tg.compare_i('of') then

             tg.next_stored_program_token;

             r.plsql_identifier_list := "plsql_identifier_list"(tg);
          end if;

          next_nd_seq(r.id);

          insert into nd_for_update_clause values r;
          return r.id;

     end "for_update_clause";/*}*/

     function  "from_elem"                      (tg in out token_getter, from_list in number) return boolean is/*{*/
          r  nd_from_elem%rowtype;
     begin

          e('from_elem', tg);
          r.from_list := from_list;

          p('from_elem: join_clause?', tg);
          r.join_clause := "join_clause"(tg);
          if r.join_clause is not null then/*{*/
             insert into nd_from_elem values r;
             p('from_elem: yes, join_clause, returning true', tg);
             l;
             return true;
          end if;/*}*/
          
          p('from_elem: not join_clause, table_reference?', tg);
          r.table_reference := "table_reference"(tg);
          if r.table_reference is not null then/*{*/
             insert into nd_from_elem values r;
             p('from_elem: yes, table_reference, returning true');
             l;
             return true;
          end if;/*}*/

          -- TODO_0066: 'join clause' within parantheis

          p('from_elem: returning false?');
          l;
          return false;

     end "from_elem";/*}*/

     function  "from_list"                      (tg in out token_getter) return number is/*{*/
       r     nd_from_list%rowtype;
     begin

          e('from_list', tg);

          next_nd_seq(r.id);
   
          insert into nd_from_list values r;
   
          if not "from_elem"(tg, r.id) then
             p('not from_elem, deleting entry, returning null');
             delete from nd_from_list where id = r.id;
             l;
             return null;
          end if;

          p('from_list: checking for 2nd from_elem, token: ' || tg.current_token_.token_);
   
          while tg.type_('SYM') and tg.token_value_sym = ',' loop
   
              tg.next_stored_program_token;
   
              if not "from_elem"(tg, r.id) then
                 raise_error(tg, 'From Elem expected');
              end if;
   
          end loop;
   
          l;
          return r.id;

     end "from_list";/*}*/

     function  "function_declaration"           (tg in out token_getter) return number is/*{*/
           r nd_function_declaration%rowtype;
     begin

           e('function_declaration', tg);
           tg.push_state;
      
           r.function_heading := "function_heading"(tg);

           if r.function_heading is null then/*{*/
              tg.pop_state;
              p('function heading is null, returning');
              l;
              return null;
           end if;/*}*/

           p('function_declaration: function heading found');

           while tg.type_('ID') loop


             if  not det_pip_par_res(tg,
                                     deterministic_   => r.deterministic_,
                                     pipelined_       => r.pipelined_,
                                     parallel_enable_ => r.parallel_enable_,
                                     result_cache_    => r.result_cache_
                             ) 

             then
               exit;
             end if; 

           end loop;

           if not tg.type_('SYM') then/*{*/
              tg.pop_state;
              p('function_declaration, ; missing, returning null');
              l;
              return null;
           end if;/*}*/

           if tg.token_value_sym != ';' then/*{*/
              tg.pop_state;
              p('function_declaration, ; missing, returning null');
              l;
              return null;
           end if;/*}*/

           tg.next_stored_program_token;

           next_nd_seq(r.id);

           insert into nd_function_declaration values r;

           tg.remove_state;
           p('function_declaration: returning ' || r.id);

           l;
           return r.id;

     end "function_declaration";/*}*/

     function  "function_definition"            (tg in out token_getter) return number is/*{*/
         r   nd_function_definition%rowtype;
     begin
         e('function_definition', tg);
         tg.push_state;
         
         p('function_definition: function_heading?');
         r.function_heading := "function_heading"(tg);

         if r.function_heading is null then/*{*/
            tg.pop_state;
            p('function_definition: no function_heading, returning null', tg);
            l;
            return null;
         end if;/*}*/

         loop /*{*/

             if  not det_pip_par_res(tg,
                                     deterministic_   => r.deterministic_,
                                     pipelined_       => r.pipelined_,
                                     parallel_enable_ => r.parallel_enable_,
                                     result_cache_    => r.result_cache_
                             ) 

             then
               exit;
             end if; 

         end loop;/*}*/

         p('function_definition: is or as required');
         if not eat_is_or_as(tg) then/*{*/
            tg.pop_state;
            p('function_definition: not a function definition, returning null', tg);
            l;
            return null;
         end if;/*}*/

         p('function_definition: declare_section?', tg);
         r.declare_section := "declare_section"(tg, autonomous_transaction_allowed => false);
         p('function_definition: body', tg);
         r.body_           := "body"           (tg, expected_name => 'TODO_0036');

         if r.body_ is null then/*{*/
            tg.pop_state;
            p('function_definition: no body, returning null', tg);
            l;
            return null;
         end if;/*}*/

         next_nd_seq(r.id);
         insert into nd_function_definition values r;
         tg.remove_state;

         p('function_definition: returning ' || r.id);
         l;
         return r.id;

     end "function_definition";/*}*/

     function  "function_expression"            (tg in out token_getter, check_outer_join_symbol in boolean) return number is/*{*/
          r  nd_function_expression%rowtype;
     begin
     --   TODO_0067: might perhaps better be named 'function call'.
     --
     --   TODO_0068: Is this 'function_expression' really used? After all, a 'complex_plsql_ident' does it, too, or not?
          
          e('function_expression', tg);

          if not func_or_proc_call(tg, r.name, r.parameter_list, check_outer_join_symbol => check_outer_join_symbol, parameter_list_required => true /*TODO_0069 is the parameter_list rreally required here*/ ) then/*{*/
             p('function_expression: func_or_proc_call false, returning null');
             l;
             return null;
          end if;/*}*/
 
          next_nd_seq(r.id);
          insert into nd_function_expression values r;
          p('function_expression: valid, returning ' || r.id, tg);
          l;
          return r.id;

     end "function_expression";/*}*/

     function  "function_heading"               (tg in out token_getter) return number is/*{*/
          r  nd_function_heading%rowtype;
     begin

          e('function_heading', tg);

          if not tg.compare_i('function') then/*{*/
             p('function_heading: keyword FUNCTION not found, returning null');
             l;
             return null;
          end if;/*}*/

          tg.next_stored_program_token;

          --     TODO_0037: Similar construct for 'procedure heading'.
          if     tg.type_('ID') then
                 r.name := upper(tg.token_value);   -- TODO_0038: Name needed?
          elsif  tg.type_('Id') then
                 r.name := tg.token_value_id;
          else
                 raise_error(tg, 'Name of function expected');
          end if;

          p('function_heading: name is ' || r.name);

          tg.next_stored_program_token;

          p('function_heading: parameter_declaration_list?');
          r.parameter_declaration_list := "parameter_declaration_list"(tg, out_parameters_allowed => true);

          if not upper(tg.token_value) = 'RETURN' then
             raise_error(tg, 'return expected');
          end if;

          tg.next_stored_program_token;

          p('function_heading: datatype?');
          r.datatype_returned := "datatype"(tg, with_precision => false);

          if r.datatype_returned is null then
             raise_error(tg, 'returned datatype expected');
          end if;

          next_nd_seq(r.id);

          insert into nd_function_heading values r;
          p('function_heading: returning ' || r.id);

          l;
          return r.id;

     end "function_heading";/*}*/

     /*}*/
     -- "G"/*{*/

     function  "group_by_elem"                  (tg in out token_getter, group_by_clause in number) return boolean is/*{*/
        r    nd_group_by_elem%rowtype;
     begin

           r.group_by_clause := group_by_clause;

           r.expression := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

           if r.expression is null then
              raise_error(tg, 'expression expected in group_by_elem');
           end if;

           insert into nd_group_by_elem values r;

           return true;

     end "group_by_elem";/*}*/

     function  "group_by_clause"                (tg in out token_getter) return number is/*{*/
         r   nd_group_by_clause%rowtype;
     begin
      
         if not tg.type_('ID') or not tg.compare_i('group') then/*{*/
            return null;
         end if;/*}*/

         tg.next_stored_program_token;

         if not tg.type_('ID') or not tg.compare_i('by') then/*{*/
            raise_error(tg, 'by expected');
         end if;/*}*/

         tg.next_stored_program_token;

         next_nd_seq(r.id);
         insert into nd_group_by_clause values r;
        
         if not "group_by_elem"(tg, r.id) then/*{*/
            raise_error(tg, 'group by elem expected');
         end if;/*}*/

         while tg.type_('SYM') and tg.token_value_sym() = ',' loop/*{*/

               tg.next_stored_program_token;

               if not "group_by_elem"(tg, r.id) then
                  raise_error(tg, 'group by elem after , expected');
               end if;

         end loop;/*}*/


         return r.id;

     end "group_by_clause";/*}*/

     /*}*/
     -- "H"/*{*/

     function  "hierarchical_query_clause"      (tg in out token_getter) return number is/*{*/
          r  nd_hierarchical_query_clause%rowtype;
     begin


          r.connect_by_condition := "connect_by_condition"(tg);

          if r.connect_by_condition is not null then
             r.start_with_condition := "start_with_condition"(tg);

             next_nd_seq(r.id);
             insert into nd_hierarchical_query_clause values r;
             return r.id;
          end if;

          r.start_with_condition := "start_with_condition"(tg);

          if r.start_with_condition is not null then
             r.connect_by_condition := "connect_by_condition"(tg);

             -- The syntax diagram implies that a connect_by_condition is
             -- required if the hierarchical_query_clause start with a 
             --'START WITH'.
             -- So, raise an error, if this is not the case here.
             if r.connect_by_condition is null then
                raise_error(tg, 'connect by condition expected');
             end if;

             next_nd_seq(r.id);
             insert into nd_hierarchical_query_clause values r;
             return r.id;
          end if;

          return null;

     end "hierarchical_query_clause";/*}*/

     function  "hint"                           (tg in out token_getter) return varchar2 is/*{*/
     begin

          return null;

     end "hint";/*}*/

     /*}*/
     -- "I"/*{*/

     function  "in_condition"                   (tg in out token_getter) return number is/*{*/
           r nd_in_condition%rowtype;
     begin

           e('in_condition', tg);

           tg.push_state;

           p('in_condition: expression?');
           r.expression := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

           if r.expression is null then/*{*/
              p('in_condition: exp is null, expression_list_1?');
              r.expression_list_1 := "expression_list"(tg);

              if r.expression_list_1 is null then/*{*/
                 p('in_condition: neither expression nor expression_list_1, returning null');
                 tg.pop_state;
                 l;
                 return null;
              end if;/*}*/

           end if;/*}*/

           -- NOT optional
           p('in_condition: checking for optional NOT', tg);
           if tg.type_('ID') and tg.compare_i('NOT') then/*{*/
              r.not_ := 1;
              tg.next_stored_program_token;
           end if;/*}*/

           -- IN expected:
           if tg.type_ != 'ID' then/*{*/
              p('in_condition: no IN, returning null');
              tg.pop_state;
              l;
              return null;
           end if;/*}*/

           if not tg.compare_i('in') then /*{*/
              p('in_condition: no IN (but: ' || tg.token_value || '), returning null');
              tg.pop_state;
              l;
              return null;
           end if;/*}*/

           tg.next_stored_program_token;

           -- Second part always (?) within paranthesis.
           -- So, check for opening paranthesis.

           if tg.type_ != 'SYM' or tg.token_value_sym != '(' then/*{*/
              p('in_condition: no opening parans for 2nd part, returning null');
              tg.pop_state;
              l;
              return null;
           end if;/*}*/

           -- eat opening paran
           tg.next_stored_program_token;

           p('in_condition: 1st part found, now checking for expression_list_2');
           r.expression_list_2 := "expression_list"(tg);

           if r.expression_list_2 is null then/*{*/
              p('in_condition: expression_list_2 is null, subquery?', tg);
              r.subquery := "subquery"(tg, into_clause => false);

              if r.subquery is null then/*{*/
                 p('in_condition: expression_list_2 and subquery both null, returning null');
                 tg.pop_state;
                 l;
                 return null;
              end if;/*}*/

           end if;/*}*/

           -- eat closing paran of second part
           if tg.type_ != 'SYM' or tg.token_value_sym != ')' then/*{*/
              raise_error(tg, 'closing paranthesis missing for 2nd part in in_condition');
           end if;/*}*/
           tg.next_stored_program_token;

           next_nd_seq(r.id);
           insert into nd_in_condition values r;
           p('in_condition: returnig ' || r.id);
           tg.remove_state;
           l;
           return r.id;

     end "in_condition";/*}*/

     function  "initialize_section"             (tg in out token_getter) return number is/*{*/
          r  nd_initialize_section%rowtype;

          TODO_0011_is_return_value_used boolean;
     begin
           -- Because nd_body and nd_initialize_section are similar:
           TODO_0011_is_return_value_used := statmt_list_exc_handler(tg, r.statement_list, r.exception_handler_list);

           next_nd_seq(r.id);
           insert into nd_initialize_section values r;
           return r.id;

     end "initialize_section";/*}*/

     function  "inner_join_clause"              (tg in out token_getter) return number is/*{*/
           r nd_inner_join_clause%rowtype;
     begin

          e('inner_join_clause', tg);
          tg.push_state;

          if     tg.type_('ID') and tg.compare_i('cross') then/*{*/
                 r.cross_ := 1;
                 tg.next_stored_program_token;
          /*}*/
          elsif  tg.type_('ID') and tg.compare_i('natural') then/*{*/
                 r.natural_ := 1;
                 tg.next_stored_program_token;

          end if;/*}*/

          if  tg.type_('ID') and tg.compare_i('inner') then/*{*/
              r.inner_ := 1;
              tg.next_stored_program_token;
          end if;/*}*/

          if  not tg.type_('ID') or not tg.compare_i('join') then/*{*/
              tg.pop_state;
              p('inner_join_clause: keyword JOIN missing, returning null', tg);
              l;
              return null;
          end if;/*}*/
          tg.next_stored_program_token;
          
          p('inner_join_clause: table_reference?', tg);
          r.table_reference := "table_reference"(tg);
          if r.table_reference is null then/*{*/
             raise_error(tg, 'table_reference is null');
          end if;/*}*/

          r.join_on_using := "join_on_using"(tg);

          next_nd_seq(r.id);
          insert into nd_inner_join_clause values r;
          tg.remove_state;
          p('inner_join_clause: returning ' || r.id);

          return r.id;
     end "inner_join_clause";/*}*/

     function  "insert_into_clause"             (tg in out token_getter) return number is/*{*/
         r   nd_insert_into_clause%rowtype;
     begin

         e('insert_into_clause', tg);

         p('insert_into_clause: into?');
         if not is_id_eaten(tg, 'into') then
            p('insert_into_clause: not INTO, returning null');
            l;
            return null;
         end if;

         p('insert_into_clause: dml_table_expression_clause?');
         r.dml_table_expression_clause := "dml_table_expression_clause"(tg);
         if r.dml_table_expression_clause is null then
            raise_error(tg, 'dml_table_expression_clause is null');
         end if;

         if not tg.type_('ID') and not tg.compare_i('values') then/*{*/
            p('insert_into_clause: alias?', tg);
            if not tg.type_('SYM') then
               r.alias_ := get_id(tg, 'alias expected');
            end if;

            if tg.type_('SYM') and tg.token_value_sym = '(' then/*{*/

               tg.next_stored_program_token;
               p('insert_into_clause: column_list?', tg);
               r.column_list := "plsql_identifier_list"(tg);
               if r.column_list is null then
                  raise_error(tg, 'column_list is null');
               end if;

               if not tg.type_('SYM') or tg.token_value_sym != ')' then
                  raise_error(tg, ') expected');
               end if;
               tg.next_stored_program_token;

            end if;/*}*/

         end if;/*}*/

         next_nd_seq(r.id);
         insert into nd_insert_into_clause values r;
         p('insert_into_clause: returning ' || r.id, tg);
         l;
         return r.id;

     end "insert_into_clause";/*}*/

     function  "insert_statement"               (tg in out token_getter) return number is/*{*/
         r   nd_insert_statement%rowtype;
     begin

         if not is_id_eaten(tg, 'insert') then
            return null;
         end if;

         r.hint := "hint"(tg);

         r.single_table_insert := "single_table_insert"(tg);
         if r.single_table_insert is null then
            -- TODO_0012: r.multi_table_insert := "multi_table_insert(tg);
            if r.multi_table_insert is null then
               raise_error(tg, 'neither single_table_insert nor multi_table_insert');
            end if;
         end if;

         next_nd_seq(r.id);
         insert into nd_insert_statement values r;
         eat_semicolon(tg);
         return r.id;

     end "insert_statement";/*}*/

     function  "into_clause"                    (tg in out token_getter) return number is/*{*/
         r   nd_into_clause%rowtype;
     begin
        e('into_clause', tg);

        if not tg.type_('ID') then/*{*/
           p('into_clause: returning NULL');
           l;
           return null;
        end if;/*}*/

        p('into_clause: bulk?', tg);
        if is_id_eaten(tg, 'bulk') then/*{*/

           p('into_clause: collect?', tg);
           if not is_id_eaten(tg, 'collect') then
              raise_error(tg, 'collect expected');
           end if;

           r.bulk_collect_ := 1;

           if not is_id_eaten(tg, 'into') then
              raise_error(tg, 'into expected');
           end if;

        else
           
           p('into_clause: into?', tg);
           if not is_id_eaten(tg, 'into') then/*{*/
              p('into_clause: keyword INTO not found, returning null');
              l;
              return null;
           end if;/*}*/

        end if;/*}*/


        p('into_clause: plsql_identifier_list?');
        r.variables := "plsql_identifier_list"(tg);
        if r.variables is null then
           raise_error(tg, 'into list expected');
        end if;

        next_nd_seq(r.id);
        insert into nd_into_clause values r;
        p('into_clause: returning ' || r.id);
        l;
        return r.id;

     end "into_clause";/*}*/

     function  "invoker_rights_clause"          (tg in out token_getter) return varchar2 is/*{*/
       invoker_right varchar2(12);
     begin

          e('invoker_rights_clause', tg);

          if tg.compare_i('authid') then/*{*/

             tg.next_stored_program_token;

             if not tg.type_('ID') then
                raise_application_error(-20800, 'ID expected');
             end if;

             invoker_right := upper(tg.token_value);

             tg.next_stored_program_token;
             p('invoker_rights_clause: returning ' || invoker_right);
             l;
             return invoker_right;

          end if;/*}*/

          p('invoker_rights_clause: returning null');
          l;
          return null;
     end "invoker_rights_clause";/*}*/

     function  "if_statement"                   (tg in out token_getter) return number is/*{*/
           r nd_if_statement%rowtype;
     begin

           e('if_statement', tg);
           if not is_id_eaten(tg, 'if') then/*{*/
              p('if_statement: no IF, returning null');
              l;
              return null;
           end if;/*}*/

           p('if_statement: condition?');
           r.boolean_expression := "condition"(tg, check_outer_join_symbol => false, prior_ => false, boolean_factor => true, aggregate_function => false);
           if r.boolean_expression is null then/*{*/
              raise_error(tg, 'condition expected');
           end if;/*}*/

           p('if_statement: then?');
           if not is_id_eaten(tg, 'then') then/*{*/
              raise_error(tg, 'then expected');
           end if;/*}*/

           p('if_statement: statement_list?');
           r.statement_list := "statement_list"(tg);
           if r.statement_list is null then/*{*/
              raise_error(tg, 'statement_list expected');
           end if;/*}*/

           p('if_statement: elsif_list?');
           r.elsif_list := "elsif_list"(tg);

           p('if_statement: else?');
           if is_id_eaten(tg, 'else') then/*{*/
              p('if_statement: else_statement_list?');
              r.else_statement_list := "statement_list"(tg);
              if r.else_statement_list is null then/*{*/
                 raise_error(tg, 'else_statement_list expected');
              end if;/*}*/
           end if;/*}*/

           p('if_statement: end?');
           if not is_id_eaten(tg, 'end') then/*{*/
              raise_error(tg, 'end expected');
           end if;/*}*/

           p('if_statement: if?');
           if not is_id_eaten(tg, 'if') then/*{*/
              raise_error(tg, 'if expected');
           end if;/*}*/

           eat_semicolon(tg);
           next_nd_seq(r.id);
           insert into nd_if_statement values r;

           p('if_statement: returning ' || r.id);
           l;
           return r.id;

     end "if_statement";/*}*/

     function  "item_declaration"               (tg in out token_getter) return number is /*{*/

         r nd_item_declaration%rowtype;
     begin

         e('item_declaration', tg);

         if tg.type_('ID') and tg.compare_i('end') then
            p('Keyword END found, most certainly (?) not an item declaration');
            l;
            return null;
         end if;

         tg.push_state;
         r.constant_declaration := "constant_declaration"(tg);
         if r.constant_declaration is not null then
            next_nd_seq(r.id);
            insert into nd_item_declaration values r;
            tg.remove_state;
            l;
            return r.id;
         end if;
         tg.pop_state;

         p('item_declaration: not a constant_declaration, maybe an exception_declaration?');

         tg.push_state;
         r.exception_declaration := "exception_declaration"(tg);
         if r.exception_declaration is not null then
            next_nd_seq(r.id);
            insert into nd_item_declaration values r;
            tg.remove_state;
            l;
            return r.id;
         end if;
         tg.pop_state;

         p('item_declaration: not an exception_declaration, maybe a variable_declaration?');

         tg.push_state;
         r.variable_declaration := "variable_declaration"(tg);
         if r.variable_declaration is not null then
            next_nd_seq(r.id);
            insert into nd_item_declaration values r;
            tg.remove_state;
            l;
            return r.id;
         end if;
         tg.pop_state;

         l;
         return null;

     end "item_declaration";/*}*/

     function  "item_elem_1"                    (tg in out token_getter, id_item_list_1 in number, autonomous_transaction_allowed in boolean) return boolean is/*{*/
       r nd_item_elem_1%rowtype;
     begin

       e('item_elem_1', tg);

       r.item_list_1 := id_item_list_1;

       p('item_elem_1: function_declaration?');
       r.function_declaration  := "function_declaration" (tg);/*{*/
       if r.function_declaration is not null then
          p('item 1 is a function declaration, returning true');
          insert into nd_item_elem_1 values r;
          l;
          return true;
       end if;/*}*/

       p('item_elem_1: procedure_declaration?');
       r.procedure_declaration := "procedure_declaration"(tg);
       if r.procedure_declaration is not null then/*{*/
          p('item 1 is a procedure declaration, returning true');
          insert into nd_item_elem_1 values r;
          l;
          return true;
       end if;/*}*/

       p('item_elem_1: type_definition?');
       r.type_definition       := "type_definition"      (tg);
       if r.type_definition is not null then/*{*/
          p('item 1 is a type definition, returning true');
          insert into nd_item_elem_1 values r;
          l;
          return true;
       end if;/*}*/
--     r.curser_declaration    := "cursor_declaration"   (tg);/*{*/
--     if r.item_declaration is not null then
--        insert into nd_item_elem_2 values r;
--        return true;
--     end if;/*}*/

       p('item_elem_1: cursor_definition?');
       r.cursor_definition     := "cursor_definition"    (tg);
       if r.cursor_definition is not null then/*{*/
          insert into nd_item_elem_1 values r;
          l;
          return true;
       end if;/*}*/

       p('item_elem_1: pragma_?');
       r.pragma_               := "pragma_"              (tg, autonomous_transaction_allowed => autonomous_transaction_allowed);
       if r.pragma_ is not null then/*{*/
          p('item 1 is a pragma, returning true');
          insert into nd_item_elem_1 values r;
          l;
          return true;
       end if;/*}*/

       p('item_elem_1: item_declaration?');
       r.item_declaration      := "item_declaration"     (tg);/*{*/
       if r.item_declaration is not null then
          p('item 1 is an item declaration, returning true');
          insert into nd_item_elem_1 values r;
          l;
          return true;
       end if;/*}*/

       p('item_elem_1: nothing found, returning false');
       l;
       return false;

     end "item_elem_1";/*}*/

     function  "item_elem_2"                    (tg in out token_getter, id_item_list_2 in number) return boolean is/*{*/
       r nd_item_elem_2%rowtype;
     begin
       
       e('item_elem_2', tg);

       r.item_list_2 := id_item_list_2;

--     r.item_declaration      := "cursor_declaration"   (tg);/*{*/
--     if r.item_declaration is not null then
--        insert into nd_item_elem_2 values r;
--        return true;
--     end if;/*}*/
--     r.item_declaration      := "item_declaration"     (tg);/*{*/
--     if r.item_declaration is not null then
--        insert into nd_item_elem_1 values r;
--        return true;
--     end if;/*}*/
 
--        r.cursor_definition     := "cursor_definition"    (tg);/*{*/
--        if r.cursor_definition is not null then
--           insert into nd_item_elem_2 values r;
--           l;
--           return true;
--        end if;/*}*/
 
          p('item_elem_2: function_declaration?');
          r.function_declaration  := "function_declaration" (tg);/*{*/
          if r.function_declaration is not null then
             insert into nd_item_elem_2 values r;
             p('item_elem_2: is function_declaration, returning true');
             l;
             return true;
          end if;/*}*/
          
          p('item_elem_2: procedure_declaration?');
          r.procedure_declaration := "procedure_declaration"(tg);/*{*/
          if r.procedure_declaration is not null then
             insert into nd_item_elem_2 values r;
             p('item_elem_2: returning true');
             l;
             return true;
          end if;/*}*/

          p('item_elem_2: function_definition?');
          r.function_definition := "function_definition"(tg);/*{*/
          if r.function_definition is not null then
             insert into nd_item_elem_2 values r;
             p('item_elem_2: is function_definition, returning true');
             l;
             return true;
          end if;/*}*/

          p('item_elem_2: procedure_definition?');
          r.procedure_definition := "procedure_definition"(tg);/*{*/
          if r.procedure_definition is not null then
             insert into nd_item_elem_2 values r;
             p('item_elem_2: is procedure_definition, returning true');
             l;
             return true;
          end if;/*}*/
          
--        r.type_definition := "type_definition"(tg);/*{*/
--        if r.type_definition is not null then
--           insert into nd_item_elem_2 values r;
--           l;
--           return true;
--        end if;/*}*/

          p('item_elem_2: returning false'); 
          l;
          return false;

     end "item_elem_2";/*}*/

     function  "item_list_1"                    (tg in out token_getter, autonomous_transaction_allowed in boolean) return number is /*{*/

       r    nd_item_list_1%rowtype;

     begin
       
       e('item_list_1', tg);

       next_nd_seq(r.id);

       insert into nd_item_list_1 values r;

       p('item_list_1: item_elem_1?');
       if not "item_elem_1"(tg, r.id, autonomous_transaction_allowed => autonomous_transaction_allowed) then
          delete from nd_item_list_1 where id = r.id;
          p('item_list_1, returning null', tg);
          l;
          return null;
       end if;

       -- Fetch all other items...
       while "item_elem_1"(tg, r.id, autonomous_transaction_allowed => autonomous_transaction_allowed) loop/*{*/
             p('item_list_1: item_elem_1 fetched');
             null;
       end loop;/*}*/

       p('item_elem_1, returning ' || r.id);

       l;
       return r.id;

     end "item_list_1";/*}*/

     function  "item_list_2"                    (tg in out token_getter) return number is /*{*/
       r    nd_item_list_2%rowtype;
     begin

       e('item_list_2', tg);

       select nd_sequence.nextval into r.id from dual;

       insert into nd_item_list_2 values r;

       p('item_list_2: item_elem_2?');
       if not "item_elem_2"(tg, r.id) then
          delete from nd_item_list_2 where id = r.id;
          p('item_list_2: returning null');
          l;
          return null;
       end if;
       p('item_list_2: first item_list_2 found');

       -- Fetch all other items...
       while "item_elem_2"(tg,r.id) loop
           p('item_list_2: item_elem_2 fetched');
           null;
       end loop;

       p('item_list_2: returning ' || r.id);
       l;
       return r.id;

     end "item_list_2";/*}*/

     /*}*/
     -- "J"/*{*/

     function  "join_clause"                    (tg in out token_getter) return number is/*{*/
          r  nd_join_clause%rowtype;
     begin

          e('join_clause', tg);
          tg.push_state;

          p('join_clause: table_reference?', tg);
          r.table_reference := "table_reference"(tg); 
          if r.table_reference is null then /*{*/
             tg.pop_state;
             p('join_clause: no table_reference, returning null', tg);
             l;
             return null;
          end if;/*}*/

          next_nd_seq(r.id);
          insert into nd_join_clause values r;

          p('join_clause: table_reference ok, 1st join_clause_elem?', tg);
          if not "join_clause_elem"(tg, r.id) then/*{*/
             delete from nd_join_clause where id = r.id;
             tg.pop_state;
             p('join_clause: no join_clause_elem found, not a join_clause, returning null', tg);
             l;
             return null;
          end if;/*}*/

          while "join_clause_elem"(tg, r.id) loop /*{*/
                null;
          end loop;/*}*/

          p('join_clause: returning ' || r.id);
          l;
          tg.remove_state;
          return r.id;

     end "join_clause";/*}*/

     function  "join_clause_elem"               (tg in out token_getter, join_clause in number) return boolean is/*{*/
          r nd_join_clause_elem%rowtype;
     begin
          
          e('join_clause_elem', tg);

          p('join_clause_elem: outer_join_clause ?', tg);
          r.outer_join_clause := "outer_join_clause"(tg);
          if r.outer_join_clause is null then/*{*/
             p('join_clause_elem: not outer join clause, inner_join_clause?', tg);
             r.inner_join_clause := "inner_join_clause"(tg);
             if r.inner_join_clause is null then
                p('join_clause_elem: not inner_join_clause, returning false', tg);
                l;
                return false;
             end if;
          end if;/*}*/

          r.join_clause := join_clause;
          insert into nd_join_clause_elem values r;
          p('join_clause_elem: returning true', tg);
          l;
          return true;
     end "join_clause_elem";/*}*/

     function  "join_on_using"                  (tg in out token_getter) return number is/*{*/
           r nd_join_on_using%rowtype;
     begin

           e('join_on_using', tg);
       

           if     tg.type_('ID') and tg.compare_i('on') then/*{*/
                  p('join_on_using: on condition');
                  tg.next_stored_program_token;
                  r.on_condition:= "condition"(tg, check_outer_join_symbol => false, prior_ => false, boolean_factor => false, aggregate_function => false);

                  if r.on_condition is null then
                     raise_error(tg, 'ON conditition expected');
                  end if;

           /*}*/
           elsif  tg.type_('ID') and tg.compare_i('using') then/*{*/
                  tg.next_stored_program_token;
                  p('join_on_using: USING');
                  if not tg.type_('SYM') or not tg.token_value_sym = '(' then/*{*/
                     raise_error(tg, 'opening paranthesis expected');
                  end if;/*}*/
                  tg.next_stored_program_token;

                  r.using_ := "plsql_identifier_list"(tg);
                  if r.using_ is null then/*{*/
                     raise_error(tg, 'using_ is null');
                  end if;/*}*/

                  if not tg.type_('SYM') or not tg.token_value_sym = ')' then/*{*/
                     raise_error(tg, 'closing paranthesis expected');
                  end if;/*}*/
                  tg.next_stored_program_token;
           /*}*/
           else/*{*/
                  p('join_on_using: nothing found, returning null');
                  l;
                  return null;
           end if;/*}*/

           next_nd_seq(r.id);
           insert into nd_join_on_using values r;
           p('join_on_using: returning ' || r.id);
           l;
           return r.id;

     end "join_on_using";/*}*/

     /*}*/
     -- "L"/*{*/

     function  "like_condition"                 (tg in out token_getter) return number is/*{*/
     -- TODO_0013: like_condition probably needs parameters
     --                 check_outer_join_symbol
     --                 aggregate_function
     --                 star_
     --
           r nd_like_condition%rowtype;
     begin
          e('like_condition', tg);
        
          tg.push_state;

          p('like_condition: char1 = expression?');
          r.char1 := "expression"(tg, check_outer_join_symbol => false, star_ => false, aggregate_function => false, prior_ => false);

          if r.char1 is null then
             tg.pop_state;
             p('like_condition: no char1');
             l;
             return null;
          end if;

          -- Maybe 'NOT LIKE' so, check for the keyword NOT
          p('like_condition: NOT?');
          if tg.type_ = 'ID' then
             if tg.compare_i('not') then
                r.not_ := 1;
                tg.next_stored_program_token;
             end if;
          end if;

          p('like_condition: LIKE(C|2|4)?');
          -- LIKE, LIKEC, LIKE2 or LIKE4 should now follow:
          if tg.type_ != 'ID' then
             p('like_condition: no ID, there for no LIKE(C|2|4) found, returning null');
             l;
             tg.pop_state;
             return null;
          end if;

          if    tg.compare_i('like' ) then
                r.like_  := 1;
          elsif tg.compare_i('likec') then
                r.likec_ := 1;
          elsif tg.compare_i('like2') then
                r.like2_ := 1;
          elsif tg.compare_i('like4') then
                r.like4_ := 1;
          else
                tg.pop_state;
                p('like_condition: no LIKE-like operator, returning null');
                l;
                return null;
          end if;

          tg.next_stored_program_token;

          r.char2 := "expression"(tg, check_outer_join_symbol => false, star_ => false, aggregate_function => false, prior_ => false);

          if tg.type_('ID') and tg.compare_i('escape') then
             tg.next_stored_program_token;

             r.escape_ := "expression"(tg, check_outer_join_symbol => false, star_ => false, aggregate_function => false, prior_ => false);
          end if;


          tg.remove_state;

          next_nd_seq(r.id);
          insert into nd_like_condition values r;
          p('like_condition: id ' || r.id || ' inserted');
          l;
          return r.id;

     end "like_condition";/*}*/

     function  "logical_factor"                 (tg in out token_getter, logical_factor_list in number, check_outer_join_symbol in boolean, prior_ in boolean, boolean_factor in boolean, aggregate_function in boolean) return boolean is/*{*/
          r nd_logical_factor%rowtype;
     begin
          -- A 'logical_factor' evaluates to true of false (or null?). So do
          --'logical_term's, but they're basically or-connected logical factors
          --
          --
          -- A 'logical_factor' can be connected with other 'logical_factor's by
          -- ANDs:
          --        logical_factor_1  AND  logical_factor_2  AND  logical_factor_3 ...
          --
          --  A 'logical_factor' can also be a 'condition', in which case the condition
          --  is within paranthesis:  // TODO_0014: is that really so?
          --       locical_factor_1 AND ( condition ) AND locical_factor_3

          e('logical_factor', tg);
          p('logical_factor, prior_ = '  || case when prior_ then 'true' else 'false' end);

          tg.push_state;

          r.logical_factor_list := logical_factor_list;

          p('logical_factor: checking for starting NOT');
          if tg.type_('ID') and tg.compare_i('NOT') then/*{*/
             p('logical_factor: starts with NOT');
             r.not_ := 1;
             tg.next_stored_program_token;
          end if;/*}*/
          
          p('locical_factor: check for opening paranthesis', tg);
          if tg.type_('SYM') and tg.token_value_sym = '(' then/*{*/

          -- 2nd push_state in this function.
          -- This, because the ( can be the ( of a condition, or
          -- an expression
             tg.push_state;

             tg.next_stored_program_token;

             p('logical_factor: ( found, condition?');
             r.condition := "condition"(tg, check_outer_join_symbol=>check_outer_join_symbol, prior_ => prior_, boolean_factor => boolean_factor, aggregate_function => false);

             if r.condition is not null then/*{*/
                p('logical_factor: condition within paranthes found, checking for closing paranthesis;');


                if tg.token_value_sym != ')' then
                   raise_error(tg, ') expeced for condition in logical factor');
                end if;


                tg.next_stored_program_token;
                insert into nd_logical_factor values r;

                tg.remove_state;
                tg.remove_state;
                l;
                return true;

             end if;/*}*/

             -- It's not a condition, return to the previous "("
             tg.pop_state;

          end if;/*}*/

          p('logical_factor: not opening paranthesis, relation?');
          r.relation := "relation"(tg, check_outer_join_symbol=>check_outer_join_symbol, prior_ => prior_, aggregate_function => aggregate_function);
          if r.relation is not null then/*{*/
             insert into nd_logical_factor values r;
             tg.remove_state;
             p('logical_factor: is a relation, returning true', tg);
             l;
             return true;
          end if;/*}*/

          p('logical_factor: not relation, in_condition?');
          r.in_condition := "in_condition"(tg);
          if r.in_condition is not null then/*{*/
             insert into nd_logical_factor values r;
             tg.remove_state;
             p('logical_factor: yes, in_condition. returning', tg);
             l;
             return true;
          end if;/*}*/

          p('logical_factor: not in_condition, exists_condition?');
          r.exists_condition := "exists_condition"(tg);
          if r.exists_condition is not null then/*{*/
             insert into nd_logical_factor values r;
             tg.remove_state;
             p('logical_factor: yes, exists_condition. returning true', tg);
             l;
             return true;
          end if;/*}*/

          p('logical_factor: not in_condition, like_condition?');
          r.like_condition := "like_condition"(tg);
          if r.like_condition is not null then/*{*/
             insert into nd_logical_factor values r;
             tg.remove_state;
             p('logical_factor: yes like_condition, returning true', tg);
             l;
             return true;
          end if;/*}*/

          p('logical_factor: not like_condition, null_condition?');
          r.null_condition := "null_condition"(tg);
          if r.null_condition is not null then/*{*/
             insert into nd_logical_factor values r;
             tg.remove_state;
             p('logical_factor: yes null_condition, returning true', tg);
             l;
             return true;
          end if;/*}*/

          p('logical_factor: not null_condition, between_condition?');
          r.between_condition := "between_condition"(tg);
          if r.between_condition is not null then/*{*/
             insert into nd_logical_factor values r;
             tg.remove_state;
             p('logical_factor: yes between_condition, returning true', tg);
             l;
             return true;
          end if;/*}*/

          if boolean_factor then/*{*/
           
             -- TODO_0015: check for TRUE, FALSE and NULL.

             p('logical_factor: boolean_function_expression?');
             r.boolean_function_expression := "function_expression"(tg, check_outer_join_symbol => false);
             if r.boolean_function_expression is not null then/*{*/
                tg.remove_state;
                p('logical_factor: boolean_function_expression is not null returning true');
                l;
                return true;
             end if;/*}*/

             -- TODO_0016: complex_plsql_identifier_ident
             r.boolean_plsql_identifier := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);
             if r.boolean_plsql_identifier is not null then /*{*/
                insert into nd_logical_factor values r;
                tg.remove_state;
                p('logical_factor: yes boolean_expression returning true', tg);
                l;
                return true;
             end if;/*}*/
          end if;/*}*/

          l;
          tg.pop_state;
          p('logical_factor: nothing matched, returning false', tg);
          return false;

     end "logical_factor";/*}*/

     function  "logical_factor_list"            (tg in out token_getter, check_outer_join_symbol in boolean, prior_ in boolean, boolean_factor in boolean, aggregate_function in boolean) return number is/*{*/
           r nd_logical_term_list%rowtype;
     begin
           e('logical_factor_list', tg);

           p('logical_factor_list, prior_ = '  || case when prior_ then 'true' else 'false' end);

           next_nd_seq(r.id);
           insert into nd_logical_factor_list values r;

           if not "logical_factor"(tg, r.id, check_outer_join_symbol=>check_outer_join_symbol, prior_ => prior_, boolean_factor => boolean_factor, aggregate_function=>aggregate_function) then
              p('logical_factor_list: no first logical factor found, returning null', tg);
              delete from nd_logical_factor_list where id = r.id;
              l;
              return null;
           end if;

           p('logical_factor_list: first logical factor found, other logical_factors are connected with ANDs', tg);

           if not tg.type_('ID') or not tg.compare_i('AND') then
              p('logical_factor_list: no first connecting AND found', tg);
              l;
              return r.id;
           end if;

           while tg.type_('ID') and tg.compare_i('AND') loop

              tg.next_stored_program_token;

              p('logical_factor_list: keyword AND found, now getting next logical_factor', tg);

              if not "logical_factor"(tg, r.id, check_outer_join_symbol=>check_outer_join_symbol, prior_ => prior_, boolean_factor => boolean_factor, aggregate_function=>false) then
                 raise_error(tg, 'Logical factor expected');
              end if;

           end loop;

           p('logical_factor_list: returning ' || r.id, tg);

           l;
           return r.id;

     end "logical_factor_list";/*}*/

     function  "logical_term"                   (tg in out token_getter, logical_term_list in number, check_outer_join_symbol in boolean, prior_ in boolean, boolean_factor in boolean, aggregate_function in boolean) return boolean is/*{*/
           r nd_logical_term%rowtype;
     begin
           e('logical_term', tg);

           p('logical_term: prior_ ' ||  case when prior_ then 'true' else 'false' end);
           r.logical_factor_list := "logical_factor_list"(tg, check_outer_join_symbol=>check_outer_join_symbol, prior_ => prior_, boolean_factor => boolean_factor, aggregate_function => aggregate_function);

           if r.logical_factor_list is null then
              p('logical_term: none found, returning false');
              l;
              return false;
           end if;

           r.logical_term_list := logical_term_list;

           insert into nd_logical_term values r;
           p('logical_term: returning true', tg);
           l;
           return true;

     end "logical_term";/*}*/

     function  "logical_term_list"              (tg in out token_getter, check_outer_join_symbol in boolean, prior_ in boolean, boolean_factor in boolean, aggregate_function in boolean) return number is/*{*/
          r nd_logical_term_list%rowtype;
     begin

         e('logical_term_list', tg);
         tg.push_state;

         next_nd_seq(r.id);
         insert into nd_logical_term_list values r;

         if not "logical_term"(tg, r.id, check_outer_join_symbol => check_outer_join_symbol, prior_ => prior_, boolean_factor => boolean_factor, aggregate_function => aggregate_function) then/*{*/
            tg.pop_state;
            p('logical_term_list: no first logical_term found, returning null');
            delete from nd_logical_term_list where id = r.id;
            l;
            return null;
         end if;/*}*/

         p('logical_term_list: first logical_term found, searching for further logical_term''s connected by OR', tg);

         if not tg.type_('ID') or not tg.compare_i('OR') then/*{*/
            p('logical_term: not OR', tg);

            if tg.type_('SYM') and tg.token_value_sym in ('||') then/*{*/
               tg.pop_state;
               p('logical_term_list: found || , therefore not a logical_term_list, returning null', tg);
               l;
               return null;
            end if;/*}*/

            tg.remove_state;
            p('logical_term_list: no connecting OR found, returning ' || r.id, tg);
            l;
            return r.id;
         end if;/*}*/

         while tg.type_('ID') and tg.compare_i('OR') loop/*{*/
               p('logical_term_list: connecting OR found, going for next logical_term', tg);

               tg.next_stored_program_token;

               if not "logical_term"(tg, r.id, check_outer_join_symbol=>check_outer_join_symbol, prior_ => prior_, boolean_factor => boolean_factor, aggregate_function => aggregate_function) then
                  raise_error(tg, 'Logical Term expected');
               end if;

         end loop;/*}*/

         tg.remove_state;
         p('logical_factor_list: id=' || r.id);
          
         l;
         return r.id;

     end "logical_term_list";/*}*/

     /*}*/
     -- "N"/*{*/
     function  "nested_table_type_def"          (tg in out token_getter) return number is/*{*/
          r  nd_nested_table_type_def%rowtype;
     begin

        e('nested_table_type_def', tg);

        if not tg.compare_i('TABLE') then
           p('nested_table_type_def: expected keyword TABLE not found, returning');
           l;
           return null;
        end if;
           
        tg.next_stored_program_token;
        if not tg.compare_i('OF') then
           raise_error(tg, 'OF expected');
        end if;

        tg.next_stored_program_token;

        r.datatype := "datatype"(tg, with_precision => true);
        if r.datatype is null then
           raise_error(tg, 'nested_table_type_def: datatype is null');
        end if;


        if tg.compare_i('NOT') then
           tg.next_stored_program_token;

           if not tg.compare_i('NULL') then
              raise_error(tg, 'NULL expected');
           end if;

           tg.next_stored_program_token;

        end if;

--        if not tg.compare_i('INDEX') then
--           raise_error(tg, 'INDEX expected');
--        end if;
--
--        tg.next_stored_program_token;
--
--        if not tg.compare_i('BY') then
--           raise_error(tg, 'BY expected');
--        end if;
--
--        tg.next_stored_program_token;
--
--        r.index_by_pls_integer    := 0;
--        r.index_by_binary_integer := 0;
--        r.index_by_varcharX       := 0;
--        r.index_by_string         := 0;
--        r.index_by_long           := 0;
--
--        if    tg.compare_i('PLS_INTEGER'   ) then
--              r.index_by_pls_integer := 1;
--        elsif tg.compare_i('BINARY_INTEGER') then
--              r.index_by_pls_integer := 1;
--        elsif tg.compare_i('VARCHAR') or 
--              tg.compare_i('VARCHAR2')       then
--              r.index_by_varcharX    := 1;
--        elsif tg.compare_i('STRING')         then
--              r.index_by_string      := 1;
--        elsif tg.compare_i('LONG')           then
--              r.index_by_long        := 1;
--        else
--              raise_error(tg, 'Not yet finished... probably because this is a type attribute or a rowtype attribute');
--        end if;
--
--        tg.next_stored_program_token;
--
--        if r.index_by_varcharx = 1 or r.index_by_string = 1 then
--
--          if tg.token_value_sym != '(' then
--             raise_error(tg, '( expected');
--          end if;
--
--          tg.next_stored_program_token;
--
--          if not tg.type_('NUM') then
--             raise_error(tg, 'NUM expected');
--          end if;
--
--          r.v_size := tg.token_value_num;
--
--          tg.next_stored_program_token;
--
--          if tg.token_value_sym != ')' then
--             raise_error(tg, ') expected');
--          end if;
--
--          tg.next_stored_program_token;
--       end if;

       next_nd_seq(r.id);

       insert into nd_nested_table_type_def values r;

       l;
       return r.id;


     end "nested_table_type_def";/*}*/

     function  "null_condition"                 (tg in out token_getter) return number is/*{*/
           r nd_null_condition%rowtype;
     begin

           e('null_condition', tg);

           tg.push_state;

           p('null_condition: expression?');
           -- TODO_0017: maybe check_outer_join_symbol should be set to true?
           r.expression := "expression"(tg, check_outer_join_symbol => false, star_ => false, aggregate_function => false, prior_ => false);

           if r.expression is null then
              p('null_condition: no expression, returning null');
              l;
              tg.pop_state;
              return null;
           end if;

           if not tg.type_('ID') then
              p('null_condition: no expression no keyword IS, returning null');
              l;
              tg.pop_state;
              return null;
           end if;

           if not tg.compare_i('is') then
              p('null_condition: no expression no keyword IS, returning null');
              l;
              tg.pop_state;
              return null;
           end if;

           tg.next_stored_program_token;

           if tg.type_('ID') and tg.compare_i('not') then
              r.not_ := 1;
              tg.next_stored_program_token;
           end if;

           if not tg.type_('ID') or not tg.compare_i('null') then
              raise_error(tg, 'NULL expected in null condition');
           end if;

           tg.next_stored_program_token;

           tg.remove_state;
           next_nd_seq(r.id);
           insert into nd_null_condition values r;
           p('null_condition: returning ' || r.id);
           l;
           return r.id;

     end "null_condition";/*}*/

     function  "numeric_literal"                (tg in out token_getter) return varchar2 is/*{*/

       ret     varchar2(4000);
     begin

      e('numeric_literal', tg);

       if tg.type_('SYM') then

          if tg.token_value_sym in ('-', '+') then
             ret := tg.token_value_sym;
          else
          -- Error?
             l;
             return null;
          end if;

          tg.next_stored_program_token;

       end if;

       if tg.current_token_.type_ in ('FLT', 'NUM') then
          ret := ret || tg.current_token_.token_;
          tg.next_stored_program_token;
          l;
          return ret;
       end if;

       l;
       return null;

     end "numeric_literal";/*}*/

     /*}*/
     -- "O"/*{*/

     function  "open_for_statement"             (tg in out token_getter) return number is/*{*/
          r  nd_open_for_statement%rowtype;
     begin
          
          if not is_id_eaten(tg, 'open') then
             return null;
          end if;

          tg.push_state;

          r.cursor_variable := "complex_plsql_ident"(tg, star_ => false);
          if r.cursor_variable is null then/*{*/
             -- TODO_0018: shoul error be risen here?
             tg.pop_state;
             return null;
          end if;/*}*/

          if not is_id_eaten(tg, 'for') then/*{*/
             tg.pop_state;
             return null;
          end if;/*}*/

          r.select_statement := "select_statement"(tg, plsql => false);
          if r.select_statement is null then/*{*/
             r.dynamic_string := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);
             if r.dynamic_string is null then/*{*/
                raise_error(tg, 'neither select statement nor dynamic string found in OPEN FOR statement');
             end if;/*}*/

          end if;/*}*/

          r.using_clause := "using_clause"(tg);

          eat_semicolon(tg);

          next_nd_seq(r.id);
          insert into nd_open_for_statement values r;
          return r.id;

     end "open_for_statement";/*}*/

     function  "open_statement"                 (tg in out token_getter) return number is/*{*/
          r  nd_open_statement%rowtype;
     begin
          e('open_statement', tg);

          if not is_id_eaten(tg, 'open') then
             p('open_statement: not OPEN, returning null');
             l;
             return null;
          end if;

          p('open_statement: plsql_identifier?');
          -- TODO_0019: complex_plsql_identifier_ident?
          r.name := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);
          if r.name is null then
             raise_error(tg, 'name expected for cursor');
          end if;

          p('open_statement: parameter_list?');
          r.actual_cursor_parameters := "parameter_list"(tg, check_outer_join_symbol => false);

          eat_semicolon(tg);

          next_nd_seq(r.id);
          insert into nd_open_statement values r;
          p('open_statement: returning ' || r.id);
          l;
          return r.id;

     end "open_statement";/*}*/

     function  "order_by_clause"                (tg in out token_getter) return number is/*{*/
         r   nd_order_by_clause%rowtype;
     begin

     --  TODO_0023: Testcase for order_by_clause/order_by_elem

         e('order_by_clause', tg);

         if not is_id_eaten(tg, 'order') then
            p('order_by_clause: no ORDER, returning null');
            l;
            return null;
         end if;

         if is_id_eaten(tg, 'siblings') then/*{*/
            r.siblings_ := 1;
         end if;/*}*/

         if not is_id_eaten(tg, 'by') then/*{*/
            raise_error(tg, 'Keyword BY expected in ORDER BY clause');
         end if;/*}*/

         next_nd_seq(r.id);

         insert into nd_order_by_clause values r;

         if not "order_by_elem"(tg, r.id) then
            raise_error(tg, 'order by clause requires at least one elem.');
         end if;

         while tg.type_('SYM') and tg.token_value_sym = ',' loop/*{*/

               tg.next_stored_program_token;

               if not "order_by_elem"(tg, r.id) then
                  raise_error(tg, 'order by elem expected.');
               end if;

         end loop;/*}*/

         p('order_by_clause: id=' || r.id);
         l;
         return r.id;
 
     end "order_by_clause";/*}*/

     function  "order_by_elem"                  (tg in out token_getter, order_by_clause in number) return boolean is/*{*/
         r  nd_order_by_elem%rowtype; 
     begin

         e('order_by_clause', tg);

         r.order_by_clause := order_by_clause;

         -- The statement
         -- 
         --   select * from 
         --     dual a, 
         --     dual b 
         --   where 
         --     a.dummy = b.dummy  
         --   order by 
         --     b.dummy (+);
         --
         -- is perfectly valid (the outer join symbol is applicable in an order by element)
         -- Therefore: check_outer_join_symbol => true:
         --
         r.expression := "expression"(tg, check_outer_join_symbol=>true, star_ => false, aggregate_function => true, prior_ => false);
         ---------------------------------------------------------------------------------------

         if r.expression is null then
            return false;
         end if;

         if tg.type_('ID') then

            if    tg.compare_i('DESC') then
                  r.asc_desc := 'D';
                  tg.next_stored_program_token;
            elsif tg.compare_i('ASC') then
                  r.asc_desc := 'A';
                  tg.next_stored_program_token;
            end if;

         end if;

         if tg.type_('ID') then

            if tg.compare_i('NULLS') then
               
               tg.next_stored_program_token;

               if not tg.type_('ID') then
                  raise_error(tg, 'ID after NULLS expected');
               end if;

               if     tg.compare_i('FIRST') then
                      r.nulls_first_last := 'F';
                      tg.next_stored_program_token;
               elsif  tg.compare_i('LAST')  then
                      r.nulls_first_last := 'L';
                      tg.next_stored_program_token;
               else
                      raise_error(tg, 'FIRST or LAST after NULLS expected');
               end if;

            end if;

         end if;

         insert into nd_order_by_elem values r;
         l;

         return true;

     end "order_by_elem";/*}*/

     function  "outer_join_clause"              (tg in out token_getter) return number is /*{*/
           r nd_outer_join_clause%rowtype;
     begin
           e('outer_join_clause', tg); 
           tg.push_state;

           p('outer_join_clause: query_partition_clause(1)?');
           r.query_partition_clause_1 := "query_partition_clause"(tg);

           if tg.type_('ID') and tg.compare_i('natural') then/*{*/
              r.natural_ := 1;

              tg.next_stored_program_token;
           end if;/*}*/

           p('outer_join_clause: going for join type', tg);
           if     tg.type_('ID') and tg.compare_i('full') then/*{*/
                  p('outer_join_clause: FULL');
                  r.full_  := 1;
                  tg.next_stored_program_token;

           elsif  tg.type_('ID') and tg.compare_i('left') then
                  p('outer_join_clause: LEFT');
                  r.left_  := 1;
                  tg.next_stored_program_token;

           elsif  tg.type_('ID') and tg.compare_i('right') then
                  p('outer_join_clause: RIGHT');
                  r.right_ := 1;
                  tg.next_stored_program_token;

           else 
                  -- If keyword 'NATURAL' is not given, 'outer join type' is required.
                  if r.natural_ != 1 then/*{*/
                     tg.pop_state;
                     p('outer_join_clause: no outer join type found, returning null', tg);
                     l;
                     return null;
                  end if;/*}*/

           end if;/*}*/

           p('outer_join_clause: optional keyword OUTER?', tg);
           if tg.type_('ID') and tg.compare_i('outer') then/*{*/
              p('outer_join_clause: optional keyword OUTER found', tg);
              r.outer_ := 1;
              tg.next_stored_program_token;
           end if;/*}*/

           p('outer_join_clause: keyword JOIN?', tg);
           if not tg.type_('ID') or not tg.compare_i('join') then/*{*/
              tg.pop_state;
              p('outer_join_clause: keyword JOIN not found, not an outer join clause, returning null', tg);
              l;
              return null;
           end if;/*}*/
           tg.next_stored_program_token;


           p('outer_join_clause: table_reference?', tg);
           r.table_reference := "table_reference"(tg);
           if r.table_reference is null then/*{*/
              raise_error(tg, 'table_reference missing');
           end if;/*}*/


           p('outer_join_clause: query_partition_clause(2)?');
           r.query_partition_clause_2 := "query_partition_clause"(tg);

           p('outer_join_clause: join_on_using?');
           r.join_on_using := "join_on_using"(tg);

           next_nd_seq(r.id);
           insert into nd_outer_join_clause values r;
           tg.remove_state;
           p('outer_join_clause: returnging ' || r.id, tg);

           l;
           return r.id;

     end "outer_join_clause";/*}*/
     /*}*/
     -- "P"/*{*/

     procedure "package"                        (tg in out token_getter) is/*{*/
          r nd_package%rowtype;

          id_declare_section number;
     begin

          e('package', tg);

          if not tg.compare_i('package') then/*{*/
             raise_application_error(-20800, 'is not a package');
          end if;/*}*/

          tg.next_stored_program_token;

          r.package_name := get_id(tg, 'Package name expected');

          p('package: name is : ' || r.package_name);

          delete from nd_package where package_name = r.package_name;

          p('package: invoker_rights_clause?');
          r.invoker_right := "invoker_rights_clause"(tg);

          p('package: is or as is required', tg);
          if not eat_is_or_as(tg) then/*{*/
             raise_error(tg, 'is or as required');
          end if;/*}*/

          p('package: declare_section?', tg);
          r.declare_section := "declare_section"(tg, autonomous_transaction_allowed => true);

          if not tg.type_('ID') then/*{*//*{*/
             raise_error(tg, 'END (for package ' || r.package_name || ') expected');
          end if;/*}*//*}*/

          if not tg.compare_i('end') then/*{*//*{*/
             raise_error(tg, 'END (for package ' || r.package_name || ') expected');
          end if;/*}*//*}*/

          tg.next_stored_program_token;

          if tg.type_ in ('ID', 'Id') then/*{*/
             if get_id(tg, 'Package name') != r.package_name then
                raise_error(tg, tg.token_value || ' does not match ' || r.package_name);
             end if;
          end if;/*}*/

         -- TODO_0020   eat_semicolon(tg);

          if not tg.type_('SYM') then/*{*//*{*/
             raise_error(tg, '; for package expected');
          end if;/*}*//*}*/

          if tg.token_value_sym != ';' then/*{*//*{*/
             raise_error(tg, '; for package expected');
          end if;/*}*//*}*/

          insert into nd_package values r;
          p('package, returning');
          l;
          return; -- TODO_0021: return true;

     end "package";/*}*/


     procedure "package_body"                   (tg in out token_getter) is/*{*/
          r  nd_package_body%rowtype;
     begin
      
          e('package_body', tg);
          tg.push_state;

          if not tg.type_('ID') or not tg.compare_i('package') then/*{*/
             tg.pop_state;
             p('package_body: keyword package not found, returning', tg);
             l;
             return;
             -- TODO_0022: return null;
          end if;/*}*/
          tg.next_stored_program_token;

          if not tg.type_('ID') or not tg.compare_i('body') then/*{*/
             tg.pop_state;
             p('package_body: keyword package not found, returning', tg);
             l;
             return;
             -- TODO_0022 return null;
          end if;/*}*/
          tg.next_stored_program_token;

          p('package_body: plsql_identifier?', tg);
          r.package_name := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);
          if r.package_name is null then/*{*/
             raise_error(tg, 'package name is null');
          end if;/*}*/

          p('package_body: name is: ' || r.package_name);
          if not eat_is_or_as(tg) then
             raise_error(tg, 'is or as required');
          end if;

          -- TODO_0024: A 'definition_allowed' parameter is probably warranted in order to deteremine if procedure and function definitions
          --            are allowed within the 'declare_section'.
          --
          p('package_body: declare_section?');
          r.declare_section := "declare_section"(tg, autonomous_transaction_allowed => false); 


          next_nd_seq(r.id);
          tg.remove_state;
          insert into nd_package_body values r;
          p('package_body: returning');
          l;
          return; -- TODO_0022: return true;

     end "package_body";/*}*/

     function  "parameter_declaration"          (tg in out token_getter, id_parameter_declaration_list in number, out_parameters_allowed in boolean) return boolean is/*{*/
     -- A 'normal' parameter declaration is almost the same as a 
     -- cursor parameter declaration. The difference is that the cursor parameter declaration does not
     -- allow OUT parameters. If this function encounters an OUT parameter while out_parameters_allowed is set 
     -- to false, an error is thrown.
        r    nd_parameter_declaration%rowtype;
     begin
      
         e('parameter_declaration', tg);

         if not tg.type_ in ('ID', 'Id') then
            raise_error(tg, 'ID for name of parameter declaration expected');
         end if;

         r.name := get_id(tg);

         p('parameter_declaration: name: ' || r.name);

         if tg.compare_i('IN') then/*{*/
            p('parameter_declaration: IN parameter');
            r.in_ := 1;
            tg.next_stored_program_token;
         end if;/*}*/

         if tg.compare_i('OUT') then/*{*/
            p('parameter_declaration: OUT parameter');

            if not out_parameters_allowed then
               raise_error(tg, 'OUT Parameters not allowed.');
            end if;
            r.out_ := 1;
            tg.next_stored_program_token;

            if tg.compare_i('nocopy') then
               p('parameter_declaration: nocopy parameter');
               r.nocopy_ := 1;
               tg.next_stored_program_token;
            end if;

            r.datatype := "datatype"(tg, with_precision => false);
            p('parameter_declaration: datatype (1): ' || r.datatype);

            if r.datatype is null then 
               raise_error(tg, 'datatype expected');
            end if;
         /*}*/
         else/*{*/

            r.datatype := "datatype"(tg, with_precision => false);
            p('parameter_declaration: datatype (2): ' || r.datatype);

            if r.datatype is null then
               raise_error(tg, 'datatype expected');
            end if;

            -- TODO_0025: Call 'is_default_assignment' instead
            if ( tg.type_('SYM') and tg.token_value_sym = ':=' ) 
                 or
                 tg.compare_i('DEFAULT') then

               p('parameter_declaration: default expression follows');

               r.default_ := 1;
               tg.next_stored_program_token;

               r.expression := "expression"(tg, check_outer_join_symbol => false, star_ => false, aggregate_function => false, prior_ => false);
               p('parameter_declaration: expression (2): ' || r.expression);

               if r.expression is null then
                  raise_error(tg, 'expression expected');
               end if;
            end if;

         end if;/*}*/

         next_nd_seq(r.id);
         r.parameter_declaration_list := id_parameter_declaration_list;

         insert into nd_parameter_declaration values r;

         l;
         return true;

     end "parameter_declaration";/*}*/

     function  "parameter_declaration_list"     (tg in out token_getter, out_parameters_allowed in boolean) return number is/*{*/
          r  nd_parameter_declaration_list%rowtype;
     begin

     e('parameter_declaration_list', tg);

          if not tg.type_('SYM') then
             l;
             return null;
          end if;

          p('parameter_declaration_list: it''s a SYM');
  

          if tg.token_value_sym != '(' then
             p('parameter_declaration_list: but it''s not a )');
             l;
             return null;
          end if;

          p('parameter_declaration_list: Advancing to next_stored_program_token');
          tg.next_stored_program_token;

          next_nd_seq(r.id);

          insert into nd_parameter_declaration_list values r;

          if not "parameter_declaration"(tg, r.id, out_parameters_allowed) then
             delete from nd_parameter_declaration_list where id = r.id;
             raise_error(tg, 'At least one parameter declaration expected');
          end if;


          loop  -- Until ')' is found

              if not tg.type_('SYM') then
                 raise_error(tg, 'SYM expected');
              end if;

              if     tg.token_value_sym = ',' then

                     tg.next_stored_program_token;

                     if not "parameter_declaration"(tg, r.id, out_parameters_allowed) then
                        raise_error(tg, 'parameter declaration failed');
                     end if;
                     p('parameter_declaration_list: Another parameter_declaration was found');

              elsif  tg.token_value_sym = ')' then
                     -- The parameter declaration list is finished.
                     -- The closing ')' is supposed to be 'eaten'
                     -- by the caller.

                     tg.next_stored_program_token;
                     p('parameter_declaration_list: Closing ) found, returning || ' || r.id);

                     l;
                     return r.id;

              else
                     raise_error(tg, 'Neither , nor )');

              end if;

          end loop;

          p('parameter_declaration_list: returning after loop');
          l;

     end "parameter_declaration_list";/*}*/

     function  "parameter_elem"                 (tg in out token_getter, parameter_list in number, check_outer_join_symbol in boolean) return boolean is/*{*/
          r  nd_parameter_elem%rowtype;
     begin
          e('parameter_elem', tg);

          r.parameter_list := parameter_list;

          --   Check if we have a named paramater, such as:  P_FOO => 'some expression'
          if tg.type_ in ('ID', 'Id') then
             
             p('parameter_elem: named_parameter?', tg);

          -- It starts with an identifier. So, it might be
          -- a named parameter.

             tg.push_state;
             r.name := get_id(tg);

             if tg.type_ ('SYM') and tg.token_value_sym = '=>' then
                tg.remove_state;
                p('parameter_elem: => found', tg);
                tg.next_stored_program_token;
             else
             -- The => is missing, so it's not a named parameter.
                tg.pop_state;
                p('parameter_elem: not a named_parameter', tg);
                r.name := null;
             end if;
          end if;

          p('parameter_elem: expression?');
          r.expression := "expression"(tg, check_outer_join_symbol=>check_outer_join_symbol, star_ => false, aggregate_function => false, prior_ => false);

          if r.expression is null then
             raise_error(tg, 'Expression expected for parameter elem ' || r.name);
          end if;
          p('parameter_elem: it is an expression.');

          insert into nd_parameter_elem values r;

          p('parameter_elem: returning true');
          l;
          return true;

     end "parameter_elem";/*}*/

     function  "parameter_list"                 (tg in out token_getter, check_outer_join_symbol in boolean) return number is/*{*/
          r  nd_parameter_list%rowtype;
     begin
       
          e('parameter_list', tg);

          p('parameter_list: checking for opening paranthesis');

          if not tg.type_('SYM') or tg.token_value_sym != '(' then
             p('parameter_list: not SYM, not parameter_list, returning');
             l;
             return null;
          end if;

--        if tg.token_value_sym != '(' then
--           p('parameter_list: not (, not parameter_list, returning');
--           l;
--           return null;
--        end if;
          
          p('parameter_list: it has a (');

       -- Eat the opening (
          tg.next_stored_program_token;

          next_nd_seq(r.id);

          insert into nd_parameter_list values r;

          p('parameter_list: checking if the parameter list is empty');
          if tg.type_('SYM') and tg.token_value_sym = ')' then
             p('parameter_list: is emtpy, returning.');
             tg.next_stored_program_token;
             l;
             return r.id;
          end if;
             

          p('parameter_list: checking if there''s at least one parameter_elem');
          if not "parameter_elem"(tg, r.id, check_outer_join_symbol => check_outer_join_symbol) then
                  raise_error(tg, 'parameter elem expected');
          end if;

          p('parameter_list: 1st parameter_elem found');

          while tg.type_('SYM') and tg.token_value_sym = ',' loop
                tg.next_stored_program_token;
                if not "parameter_elem"(tg, r.id, check_outer_join_symbol=>check_outer_join_symbol) then
                        raise_error(tg, 'parameter elem expected');
                end if;
                p('parameter_list: another parameter_elem found');
          end loop;

          if not tg.type_('SYM') or tg.token_value_sym != ')' then
             raise_error(tg, 'Closing ) expected for parameter list');
          end if;
  
--        if tg.token_value_sym != ')' then
--           raise_error(tg, 'Closing ) expected for parameter list');
--        end if;

       -- Eat the closing )
          tg.next_stored_program_token;

          p('parameter_list: valid, id = ' || r.id);
          l;
          return r.id;

     end "parameter_list";/*}*/

     function  "plsql_block"                    (tg in out token_getter) return number is/*{*/
          r  nd_plsql_block%rowtype;
     begin

          if is_id_eaten(tg, 'declare') then/*{*/
             r.declare_section := "declare_section"(tg, autonomous_transaction_allowed => 'TODO_0026' = 'can a declare section in a plsql_block have an autonomous_transaction');
             if r.declare_section is null then/*{*/
                raise_error(tg, 'declare section is null');
             end if;/*}*/

             r.body_ := "body"(tg, expected_name => null);
             if r.body_ is null then
                raise_error(tg, 'body is null');
             end if;

             next_nd_seq(r.id);
             insert into nd_plsql_block values r;
             return r.id;
          end if;/*}*/

          r.body_ := "body"(tg, expected_name => null);
          if r.body_ is null then/*{*/
             return null;
          end if;/*}*/

          next_nd_seq(r.id);
          insert into nd_plsql_block values r;
          return r.id;

     end "plsql_block";/*}*/

     function  "plsql_identifier"               (tg in out token_getter, check_outer_join_symbol in boolean, star_ in boolean/* TODO_0027: star_-parameter necessary?*/) return number is/*{*/

     --   TODO_0028: The @ should be supported here, too.

          r  nd_plsql_identifier%rowtype;

          function star_or_id(tg in out token_getter, star_ in boolean) return varchar2/*{*/
          is
              ident varchar2(30);
          begin

              if star_ then/*{*/

                 if tg.type_ = 'SYM' then

                    if tg.token_value_sym = '*' then/*{*/
                       tg.next_stored_program_token;
                       return '*';
                    end if;/*}*/
                 end if;

              end if;/*}*/

              if tg.type_ not in ('ID', 'Id') then /*{*/
                 return null;
              end if;/*}*/

              if is_keyword(tg.token_value_id) then
                 return null;
              end if;

              tg.push_state;
              ident := get_id(tg, 'PLSQL identifier');

              if is_keyword(ident) then
                 tg.pop_state;
                 return null;
              end if;

              tg.remove_state;
              return ident;

          end star_or_id;/*}*/

     begin

     --   TODO_0029
     --     if last element is DELETE, EXTEND or TRIM, the plsql_identfier is a -> 'collection_method_call';

          e('plsql_identifier', tg);

          if star_ then/*{*/
             p('plsql_identifier star_ is true');
          end if;/*}*/
          
          r.identifier_1 := star_or_id(tg, star_);

          p('plsql_identifier: identifier_1: ' || r.identifier_1);
          if r.identifier_1 is null then/*{*/
             p('plsql_identifier: identifier_1 is null, returning null');
             l;
             return null;
          end if;/*}*/

          -- TODO_0030: special treatment if r.identifier_1 = '*'.

          if tg.type_('SYM') and tg.token_value_sym = '.' then/*{*/
             
             tg.next_stored_program_token;

             r.identifier_2 := star_or_id(tg, star_);
             -- TODO_0030: special treatment if r.identifier_2 = '*'.

             p('plsql_identifier: identifier_2: ' || r.identifier_2);

             if tg.type_('SYM') and tg.token_value_sym = '.' then/*{*/
                
                tg.next_stored_program_token;

                r.identifier_3 := star_or_id(tg, star_);
                p('plsql_identifier: identifier_3: ' || r.identifier_3);

             -- TODO_0031: special treatment if r.identifier_3 = '*'.

             end if;/*}*/

          end if;/*}*/

          if tg.type_('SYM') and tg.token_value_sym = '%' then -- %found/*{*/
             tg.push_state;
             tg.next_stored_program_token;
             if is_id_eaten(tg, 'found') then
                r.found_ := 1;
                tg.remove_state;
             else
                tg.pop_state;
             end if;
          end if;/*}*/


          if is_outer_join_symbol(tg) then
             r.outer_join_symbol := 1;
          end if;
                  

        next_nd_seq(r.id);
        insert into nd_plsql_identifier values r;

        p('plsql_identifier: valid: ' || r.identifier_1 || '.' || r.identifier_2 || '.' || r.identifier_3);

        l;
        return r.id;

     end "plsql_identifier";/*}*/

     function  "plsql_identifier_elem"          (tg in out token_getter, plsql_identifier_list in number) return boolean is/*{*/
         r   nd_plsql_identifier_elem%rowtype;
     begin

         -- TODO_0032: complex_plsql_identifier_ident?
         r.plsql_identifier := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);

         if r.plsql_identifier is null then
            return false;
         end if;

         r.plsql_identifier_list := plsql_identifier_list;

         insert into nd_plsql_identifier_elem values r;

         return true;

     end "plsql_identifier_elem";/*}*/

     function  "plsql_identifier_list"          (tg in out token_getter) return number is/*{*/
        r    nd_plsql_identifier_list%rowtype;
     begin

          next_nd_seq(r.id);
          insert into nd_plsql_identifier_list values r;

          if not "plsql_identifier_elem"(tg, r.id) then/*{*/
             delete from nd_plsql_identifier_list where id = r.id;
             return null;
          end if;/*}*/

          while tg.type_('SYM') and tg.token_value_sym = ',' loop/*{*/
                tg.next_stored_program_token;

                if not "plsql_identifier_elem"(tg, r.id) then
                   raise_error(tg, 'plsql_identifier_elem expected after ,');
                end if;
          end loop;/*}*/

          return r.id;

     end "plsql_identifier_list";/*}*/

     function  "pragma_"                        (tg in out token_getter, autonomous_transaction_allowed in boolean) return number is/*{*/
         r   nd_pragma%rowtype;
     begin
     --
     --   the pragma autonomous_transaction cannot appear in a package body, hence the
     --     autonomous_transaction_allowed 
     --   parameter.
     --
          e('pragma_', tg);

          if not tg.type_('ID') then/*{*/
             p('pragma_: no ID');
             l;
             return null;
          end if;/*}*/

          if not tg.compare_i('pragma') then/*{*/
             p('pragma_: not keyword pragma, returning null');
             l;
             return null;
          end if;/*}*/

          tg.next_stored_program_token;

          if not tg.type_('ID') then/*{*/
             raise_error(tg, 'strange pragma');
          end if;/*}*/

--        if autonomous_transaction_allowed then/*{*/ -- TODO_0033: Is this parameter really needed?
             p('pragma_: autonomous_transaction?');
             if tg.compare_i('autonomous_transaction') then/*{*/
                tg.next_stored_program_token;
                r.autonomous_transaction_ := 1;
   
                eat_semicolon(tg);

                next_nd_seq(r.id);
                insert into nd_pragma values r;
                p('pragma_: autonomous_transaction_!');
                l;
                return r.id;
             end if;/*}*/
--        end if;/*}*/

          p('pragma_: serially_reusable?');
          if tg.compare_i('serially_reusable') then/*{*/
             tg.next_stored_program_token;
             r.serially_reusable_pragma_ := 1;

             eat_semicolon(tg);

             next_nd_seq(r.id);
             p('pragma_: serially_reusable!');
             l;
             insert into nd_pragma values r;
             return r.id;
          end if;/*}*/

          p('pragma_: exception_init_pragma?');
          r.exception_init_pragma := "exception_init_pragma"(tg);
          if r.exception_init_pragma is not null then/*{*/
             next_nd_seq(r.id);
             insert into nd_pragma values r;
             p('pragma_: exception_init_pragma!');
             l;
             return r.id;
          end if;/*}*/

          p('pragma_: restrict_references_pragma?');
          r.restrict_references_pragma := "restrict_references_pragma"(tg);
          if r.restrict_references_pragma is not null then/*{*/
             next_nd_seq(r.id);
             insert into nd_pragma values r;
             p('pragma_: restrict_references_pragma!');
             l;
             return r.id;
          end if;/*}*/

          raise_error(tg, 'unimplemented pragma!');
             

     end "pragma_";/*}*/

     function  "procedure_call"                 (tg in out token_getter) return number is
           r nd_procedure_call%rowtype;
     begin
           e('procedure_call', tg);


           if tg.type_('ID') and is_keyword(tg.token_value) then/*{*/
              p('procedure_call: ' || tg.token_value || ' is a keyword, returning null');
              l;
              return null;
           end if;/*}*/

           if not func_or_proc_call(tg, r.name, r.parameter_list, check_outer_join_symbol => false, parameter_list_required => false) then/*{*/
              p('procedure_call: not func_or_proc_call, returning null', tg);
              l;
              return null;
           end if;/*}*/

           p('procedure_call: eat_semicolon', tg);
           eat_semicolon(tg);

           next_nd_seq(r.id);
           insert into nd_procedure_call values r;
           p('procedure_call: returning ' || r.id);
           l;
           return r.id;

     end "procedure_call";

     function  "procedure_declaration"          (tg in out token_getter) return number is/*{*/
          r  nd_procedure_declaration%rowtype;
     begin

          e('procedure_declaration', tg);
          tg.push_state;

          p('procedure_declaration: procedure_heading?');
          r.procedure_heading := "procedure_heading"(tg);

          if r.procedure_heading is null then/*{*/
             tg.pop_state;
             p('procedure_heading is null, returning null', tg);
             l;
             return null;
          end if;/*}*/

          -- TODO_0034: Has Oracle forgotten to include the ';' in their
          -- EBNF?
          --
          -- TODO_0035: can eat_semicolon be used here?
          if not tg.type_('SYM') then/*{*/
             tg.pop_state;
             p('procedure_heading: no ;, returning null');
             l;
             return null;
          end if;/*}*/
          if tg.token_value_sym != ';' then/*{*/
             tg.pop_state;
             p('procedure_heading: no ;, returning null');
             l;
             return null;
          end if;/*}*/

          tg.next_stored_program_token;

          next_nd_seq(r.id);

          
          insert into nd_procedure_declaration values r;
          tg.remove_state;
          p('procedure_declaration: returning ' || r.id, tg);
          l;
          return r.id;

     end "procedure_declaration";/*}*/

     function  "procedure_definition"           (tg in out token_getter) return number is/*{*/
         r   nd_procedure_definition%rowtype;
     begin
         e('procedure_definition', tg);
         tg.push_state;
         
         p('procedure_definition: procedure_heading?');
         r.procedure_heading := "procedure_heading"(tg);
         if r.procedure_heading is null then/*{*/
            tg.pop_state;
            p('procedure_heading: no procedure_heading: returning null', tg);
            l;
            return null;
         end if;/*}*/

         p('procedure_definition: is or as required', tg);
         if not eat_is_or_as(tg) then
            tg.pop_state;
            p('procedure_definition: not a procedure definition, returning null', tg);
            l;
            return null;
         end if;

         p('procedure_definition: declare_section?');
         r.declare_section := "declare_section"(tg, autonomous_transaction_allowed => false);
         p('procedure_definition: body', tg);
         r.body_           := "body"           (tg, expected_name => 'TODO_0036');

         if r.body_ is null then/*{*/
            tg.pop_state;
            p('procedure_definition: no body, returning null', tg);
            l;
            return null;
         end if;/*}*/

         next_nd_seq(r.id);
         insert into nd_procedure_definition values r;
         tg.remove_state;

         p('procedure_definition: returning ' || r.id);
         l;
         return r.id;

     end "procedure_definition";/*}*/

     function  "procedure_heading"              (tg in out token_getter) return number is/*{*/
           r nd_procedure_heading%rowtype;
     begin

          e('procedure_heading', tg);

          if not tg.compare_i('procedure') then
             p('keyword procedure not found, returning');
             l;
             return null;
          end if;

          tg.next_stored_program_token;

          --     TODO_0037: Similar construct for 'function heading'.
          if     tg.type_('ID') then
                 r.name := upper(tg.token_value);   -- TODO_0038: Name needed?
          elsif  tg.type_('Id') then
                 r.name := tg.token_value_id;
          else
                 raise_error(tg, 'Name of proecedure expected');
          end if;

          p('procedure_heading: name of procedure is: ' || r.name);

          tg.next_stored_program_token;

          r.parameter_declaration_list := "parameter_declaration_list"(tg, out_parameters_allowed => true);

          next_nd_seq(r.id);
          p('valid procedure heading');
          insert into nd_procedure_heading values r;
          l;
          return r.id;

     end "procedure_heading";/*}*/

     /*}*/
     -- "Q"/*{*/

     function  "query_partition_clause"         (tg in out token_getter) return number is/*{*/
           r nd_query_partition_clause%rowtype;
     begin
           e('query_partition_clause', tg);

           if not tg.type_('ID') then
              p('query_partition_clause: no keyword PARTITION, returning null');
              l;
              return null;
           end if;

           if not tg.compare_i('partition') then
              p('query_partition_clause: no keyword PARTITION, returning null');
              l;
              return null;
           end if;
           tg.next_stored_program_token;

           p('query_partition_clause: seems to be one');

           if not tg.compare_i('by') then
              raise_error(tg, 'by expected in query partition clause');
           end if;

           tg.next_stored_program_token;

           r.expression_list := "expression_list"(tg);

           if r.expression_list is null then 
              raise_error(tg, 'expression list expected in query partition clause');
           end if;

           next_nd_seq(r.id);

           insert into nd_query_partition_clause values r;

           p('query_partition_clause: ok, returning ' || r.id);
           l;
           return r.id;

     end "query_partition_clause";/*}*/

     function  "query_table_expression"         (tg in out token_getter) return number is /*{*/
          r  nd_query_table_expression%rowtype;
     begin

          e('query_table_expression', tg);

          -- Checking table_collection_expression first because it starts with the keyword 'TABLE'
          r.table_collection_expression := "table_collection_expression"(tg);
          if r.table_collection_expression is not null then/*{*/
             next_nd_seq(r.id);
             insert into nd_query_table_expression values r;
             p('query_table_expression: table_collection_expression found, returning ' || r.id);
             l;
             return r.id;
          end if;/*}*/

          r.name_ := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);

          if r.name_ is not null then/*{*/
             next_nd_seq(r.id);
             insert into nd_query_table_expression values r;
             p('query_table_expression: name_ = ' || r.name_ || ', returning ' || r.id);
             l;
             return r.id;
          end if;/*}*/

          p('query_table_expression: name is null, subquery in paranthesis?', tg);

          if not tg.type_('SYM') or tg.token_value_sym != '(' then/*{*/
             raise_error(tg, '( expected in query_table_expression');
          end if;/*}*/
          tg.next_stored_program_token;

          p('query_table_expression: subquery? [in paranthesis]', tg);
          r.subquery := "subquery"(tg, into_clause => false);

          if r.subquery is null then/*{*/
             raise_error(tg, 'subquery expected');
          end if;/*}*/

          p('query_table_expression: closing )?', tg);
          if not tg.type_('SYM') then/*{*/
             raise_error(tg, ') expected in query_table_expression');
          end if;/*}*/

          if tg.token_value_sym != ')' then/*{*/
             raise_error(tg, ') expected in query_table_expression');
          end if;/*}*/
          tg.next_stored_program_token;

          next_nd_seq(r.id);
          p('query_table_expression returing ' || r.id, tg);
          l;
          insert into nd_query_table_expression values r;
          return r.id;

     end "query_table_expression";/*}*/

     function  "query_block"                    (tg in out token_getter, into_clause in boolean) return number is/*{*/
          r  nd_query_block%rowtype;
     begin
     -- A 'query block' is something like
     --   
     --    select 
     --       x, y, count(z)
     --    from
     --       table_1,
     --       table_2
     --    where
     --       x=y
     --    group by
     --       x, y
     --
     -- In contrast, a "subquery" is either a
     --    . "query block"  or
     --    . "subquery" union all "subquery"

         e('query_block', tg);

         if not tg.type_('ID') then/*{*/
            p('query_block: not SELECT ID, returning null');
            l;
            return null;
         end if;/*}*/

         if not tg.compare_i('select') then/*{*/
            p('query_block: keyword select not found, it''s not a query block');
            l;
            return null;
         end if;/*}*/
         p('query_block: keyword select found, it''s a query block');

         tg.next_stored_token;

         if tg.type_('WS') then
            tg.next_stored_token;
         end if;
         
         if tg.type_('REM') then/*{*/
            if substr(tg.current_token_.token_, 3,1) = '+' then
               p('query_block: hint found');
               r.hint := tg.current_token_.token_;
            end if;
            tg.next_stored_program_token;
         end if; /*}*/

         if      tg.compare_i('distinct')   then/*{*/
                 r.distinct_ := 1;
                 tg.next_stored_program_token;
         /*}*/
         elsif   tg.compare_i('unique')     then/*{*/
                 r.unique_   := 1;
                 tg.next_stored_program_token;
         /*}*/
         elsif   tg.compare_i('all')        then/*{*/
                 r.all_      := 1;
                 tg.next_stored_program_token;
         end if;/*}*/

         p('query_block: going for select_list', tg);
         r.select_list := "select_list"(tg);

         p('query_block: r.select_list: ' || r.select_list, tg);
         if r.select_list is null then
            raise_error(tg, 'Select list expected');
         end if;

         if into_clause then/*{*/
            p('query_block: into_clause?', tg);
            r.into_clause := "into_clause"(tg);

            if r.into_clause is null then
               raise_error(tg, 'into_clause expected');
            end if;
         end if;/*}*/

         if not tg.compare_i('from') then
            raise_error(tg, 'from expected');
         end if;

         tg.next_stored_program_token;

         p('query_block: going for the from list');

         r.from_list := "from_list"(tg);

         if r.from_list is null then/*{*/
            raise_error(tg, 'from list expected');
         end if;/*}*/

         p('query_block: where_clause?', tg);
         r.where_clause := "where_clause"(tg);

         p('query_block: hierarchical_query_clause?', tg);
         r.hierarchical_query_clause := "hierarchical_query_clause"(tg);

         p('query_block: group_by_clause?', tg);
         r.group_by_clause := "group_by_clause"(tg);

         p('query_block: having?', tg);
         if is_id_eaten(tg, 'having') then/*{*/
            r.having_condition := "condition"(tg, check_outer_join_symbol => false, prior_ => false, boolean_factor => false, aggregate_function => true);
            if r.having_condition is null then/*{*/
               raise_error(tg, 'having_condition exptected');
            end if;/*}*/
         end if;/*}*/

         next_nd_seq(r.id);
         p('query_block: valid query block, id = ' || r.id);
         insert into nd_query_block values r;
         l;
         return r.id;

     end "query_block";/*}*/

     /*}*/
     -- "R"/*{*/

     function  "record_type_definition"         (tg in out token_getter) return number is/*{*/
       r  nd_record_type_definition%rowtype;
     begin

       e('record_type_definition', tg);

       if not tg.compare_i('TYPE') then
          p('record_type_definition: keyword TYPE not found, returning null');
          l;
          return null;
       end if;

       tg.next_stored_program_token;

       r.name := get_id(tg, 'Name for RECORD TYPE expected');

       if not tg.compare_i('IS') then
          p('record_type_definition: keyword IS not found, returning null');
          l;
          return null;
       end if;

       tg.next_stored_program_token;

       if not tg.compare_i('RECORD') then
          p('record_type_definition: keyword RECORD not found, returning null');
          l;
          return null;
       end if;

       tg.next_stored_program_token;


       r.field_definition_list := "field_definition_list"(tg);

       if r.field_definition_list is null then
          p('record_type_definition: no field definition found, returning null');
          raise_error(tg, 'no field definitions found for record.');
       end if;

       eat_semicolon(tg);

       next_nd_seq(r.id);

       p('record_type_definition: OK');
       insert into nd_record_type_definition values r;

       l;
       return r.id;

     end "record_type_definition";/*}*/

     function  "ref_cursor_type_definition"     (tg in out token_getter) return number is/*{*/
       r  nd_ref_cursor_type_definition%rowtype;
     begin

       e('ref_cursor_type_definition', tg);

       if not tg.compare_i('TYPE') then/*{*/
          p('ref_cursor_type_definition: keyword TYPE not found, returning null');
          l;
          return null;
       end if;/*}*/

       tg.next_stored_program_token;

       r.name := get_id(tg, 'Name for REF CURSOR TYPE expected');

       if not tg.compare_i('IS') then/*{*/
          p('ref_cursor_type_definition: keyword IS not found, returning null');
          l;
          return null;
       end if;/*}*/

       tg.next_stored_program_token;

       if not tg.compare_i('REF') then/*{*/
          p('ref_cursor_type_definition: keyword REF not found, returning null');
          l;
          return null;
       end if;/*}*/

       tg.next_stored_program_token;

       if not tg.compare_i('CURSOR') then/*{*/
          p('ref_cursor_type_definition: keyword CURSOR not found, returning null');
          l;
          return null;
       end if;/*}*/

       tg.next_stored_program_token;

       if not tg.compare_i('RETURN') then/*{*/

          if tg.type_('SYM') and tg.token_value_sym = ';' then 
             -- Weak ref cursor declaration
             r.strong_declaration := 0;

             tg.next_stored_program_token;

             next_nd_seq(r.id);
             insert into nd_ref_cursor_type_definition values r;

             l;
             return r.id;

          end if;

          p('ref_cursor_type_definition: neither keyword RETURN nor ; found, returning null');
          l;
          return null;
       end if;/*}*/

       -- Seems to be a strong declaration of a ref cursor...
       r.strong_declaration := 1;

       tg.next_stored_program_token;

       -- TODO_0039: try %TYPE and %ROWTYPE first here!
       r.plsql_identifier := "plsql_identifier"(tg, check_outer_join_symbol => false, star_ => false);

       if r.plsql_identifier is null then
          raise_error(tg, 'Identifier expected for REF CURSOR TYPE');
       end if;

       eat_semicolon(tg);

       next_nd_seq(r.id);

       p('ref_cursor_type_definition: OK');
       insert into nd_ref_cursor_type_definition values r;

       l;
       return r.id;

     end "ref_cursor_type_definition";/*}*/

     function  "relation"                       (tg in out token_getter, check_outer_join_symbol in boolean, prior_ in boolean, aggregate_function in boolean) return number is/*{*/
           r nd_relation%rowtype;
     begin
           e('relation', tg);
           tg.push_state;
    
           p('relation: going to assign expression_1');

           r.expression_1 := "expression"(tg, check_outer_join_symbol => check_outer_join_symbol, star_ => false, aggregate_function => aggregate_function, prior_ => prior_);

           if r.expression_1 is null then/*{*/
              tg.pop_state;
              p('relation: expression_1 is null, returning null', tg);
              l;
              return null;
           end if;/*}*/

           p('relation: expression_1 was assigned', tg);
           next_nd_seq(r.id);

           if not tg.type_('SYM') or tg.token_value_sym not in ('>', '<', '!=', '<>', '=', '>=', '<=') then
--            insert into nd_relation values r; 
              tg.pop_state;
              p('relation: no relop (>, < ...) found, returning null', tg);
              l;
              return null;
           end if;

           r.relop := tg.token_value_sym;
           p('relation: relop is: ' || r.relop, tg);
           tg.next_stored_program_token;

           p('relation: going for expression_2', tg);
           r.expression_2 := "expression"(tg, check_outer_join_symbol => check_outer_join_symbol, star_ => false, aggregate_function => aggregate_function, prior_ => prior_);

           if r.expression_2 is null then
              raise_error(tg, 'expression_2 is null');
           end if;

           insert into nd_relation values r;
           tg.remove_state;
           p('relation: returning ' || r.id, tg);
           l;
           return r.id;

     end "relation";/*}*/

     function  "restrict_references_pragma"     (tg in out token_getter) return number is/*{*/
           r nd_restrict_references_pragma%rowtype;
     begin
          e('restrict_references_pragma', tg);

          if not tg.type_('ID') then
             p('restrict_references_pragma: not ID returning null');
             l;
             return null;
          end if;

          if not tg.compare_i('restrict_references') then
             p('restrict_references_pragma: not ''restrict_references'' returning null');
             l;
             return null;
          end if;

          tg.next_stored_program_token;

          if not tg.type_('SYM') then
             raise_error(tg, 'restrict_references_pragma pragma requires (');
          end if;

          if not tg.token_value_sym = '(' then
             raise_error(tg, 'restrict_references_pragma pragma requires (');
          end if;

          tg.next_stored_program_token;

          r.subprogram_method := get_id(tg, 'subprogram_method id expected for restrict_references_pragma');

          if not tg.type_('SYM') then
             raise_error(tg, 'restrict_references_pragma pragma requires (');
          end if;

          if not tg.token_value_sym = ',' then
             raise_error(tg, 'restrict_references_pragma pragma requires , after subprogram_method');
          end if;

          while tg.token_value_sym = ',' loop/*{*/

                tg.next_stored_program_token;

                if    tg.compare_i('default') then r.default_ := 1;
                elsif tg.compare_i('rnds'   ) then r.rnds_    := 1;
                elsif tg.compare_i('wnds'   ) then r.wnds_    := 1;
                elsif tg.compare_i('rnps'   ) then r.rnps_    := 1;
                elsif tg.compare_i('wnps'   ) then r.wnps_    := 1;
                elsif tg.compare_i('trust'  ) then r.trust_   := 1;
                else  raise_error(tg, 'unknown value for restrict_references_pragma');
                end if;

                tg.next_stored_program_token;

          end loop;/*}*/

          if not tg.type_('SYM') then
             raise_error(tg, 'restrict_references_pragma pragma requires )');
          end if;

          if not tg.token_value_sym = ')' then
             raise_error(tg, 'restrict_references_pragma pragma requires )');
          end if;

          tg.next_stored_program_token;

          eat_semicolon(tg);

          next_nd_seq(r.id);
          p('restrict_references_pragma: id: ' || r.id);

          insert into nd_restrict_references_pragma values r;
          l;
          return r.id;

     end "restrict_references_pragma";/*}*/

     function  "return_statement"               (tg in out token_getter) return number is/*{*/
           r nd_return_statement%rowtype;
     begin

           e('return_statement', tg);
          
           if not is_id_eaten(tg, 'return') then/*{*/
              p('return_statement: no RETURN, returning null');
              l;
              return null;
           end if;/*}*/

           p('return_statement: logical_term?', tg);
           r.logical_term_list := "logical_term_list"(tg, check_outer_join_symbol => false, prior_ => false, boolean_factor => true, aggregate_function => false);
           if r.logical_term_list is null then/*{*/

           -- TODO_0040: can this not be solved easier? the return statement can be either an
           --            expression or a logical_term_list. 

              p('return_statement: expression?', tg);
              r.expr := "expression"(tg, check_outer_join_symbol => false, star_ => false, aggregate_function => false, prior_ => false);

              if r.expr is null then
                 raise_error(tg, 'neither expr nor logical_term_list found in return statement');
              end if;
           end if;/*}*/

           p('return_statement: eat_semicolon', tg);
           eat_semicolon(tg);

           next_nd_seq(r.id);
           insert into nd_return_statement values r;

           p('return_statement: returning ' || r.id, tg);
           l;
           return r.id;
        
     end "return_statement";/*}*/

     function  "returning_clause"               (tg in out token_getter) return number is/*{*/
          r  nd_returning_clause%rowtype;
     begin

          if not is_id_eaten(tg, 'return') and not is_id_eaten(tg, 'returning') then
             return null;
          end if;

          r.expression_list := "expression_list"(tg);
          if r.expression_list is null then/*{*/
             raise_error(tg, 'expression_list expected');
          end if;/*}*/

          if not is_id_eaten(tg, 'into') then
             raise_error(tg, 'into expected');
          end if;

          r.data_item_list := "plsql_identifier_list"(tg);
          if r.data_item_list is null then/*{*/
             raise_error(tg, 'data_item_list expected');
          end if;/*}*/

          next_nd_seq(r.id);
          insert into nd_returning_clause values r;
          return r.id;
     end "returning_clause";/*}*/


     /*}*/
     -- "S"/*{*/ The @ should be supported here, too.

     function  "scalar_datatype"                (tg in out token_getter, with_precision in boolean) return number is/*{*/

     -- Determine a 'scalar datatype', such as
     --   number, varchar2 and the like
     --
     -- If the datatype is used within a declare section, for some datatypes (number, varchar2)
     -- a precision is needed [ number(5,2) or varchar2(42) ].
     -- This precision is not needed (even forbidden) if the datatype occurs within a parameter list
     -- of a function / procedure or as the returned type of a function.
     -- Therefor, with_precision indicates if the function should check for the existance of such
     -- precision.


          r nd_scalar_datatype%rowtype;
     begin

          e('scalar_datatype', tg);

          if not tg.type_('ID') then/*{*/
             p('scalar_datatype: not ID, returning null');
             l;
             return null;
          end if;/*}*/

          if upper(tg.token_value) in ('NUMBER', 'VARCHAR2', 'DATE', 'BOOLEAN', 'CHAR', 'DECIMAL') then/*{*/

             r.type_ := upper(tg.token_value);

             tg.next_stored_program_token;

             if r.type_ in ('VARCHAR2', 'CHAR') then/*{*/

                if with_precision then/*{*/

                   if tg.token_value_sym != '(' then
                      raise_application_error (-20800, r.type_ || ' without (');
                   end if;
   
                   tg.next_stored_program_token;
   
                   r.size_ := tg.token_value_num;
   
                   tg.next_stored_program_token;
   
                   if tg.token_value_sym != ')' then
                      raise_application_error (-20800, r.type_ || ' without )');
                   end if;
   
                   tg.next_stored_program_token;

                end if;/*}*/

                next_nd_seq(r.id);

                insert into nd_scalar_datatype values r;
                p('scalar_datatype: type_: ' || r.type_ || ', returning ' || r.id);
                l;
                return r.id;
             end if;/*}*/

             if r.type_ in ('NUMBER', 'DECIMAL') then/*{*/

                if with_precision then

                   if tg.type_('SYM') then
                   if tg.token_value_sym = '(' then
   
                      tg.next_stored_program_token;
   
                      r.size_ := tg.token_value_num;
   
                      tg.next_stored_program_token;
   
                      if tg.type_('SYM') then /*{ Check for a dot which would be between 4 and 5 in [ NUMBER (4,5) ]*/ 
                         if tg.token_value_sym = ',' then
   
                            tg.next_stored_program_token;
   
                            r.precision := tg.token_value_num;
                            tg.next_stored_program_token;
   
                         end if;
                      end if;/*}*/
   
   
                      if tg.token_value_sym != ')' then
                         raise_error(tg, 'Closing ) expected');
                      end if;
   
                      tg.next_stored_program_token;
   
   
                   end if;
                   end if;

                end if;

                next_nd_seq(r.id);

                insert into nd_scalar_datatype values r;
                p('scalar_datatype: type_: ' || r.type_ || ', returning ' || r.id);
                l;
                return r.id;

             end if;/*}*/

             if r.type_ in ('DATE', 'BOOLEAN') then
             -- No distinction between DATE and BOOLEAN since the
             -- don't have precisions.

                next_nd_seq(r.id);
                insert into nd_scalar_datatype values r;
                p('scalar_datatype: type_: ' || r.type_ || ', returning ' || r.id);
                l;
                return r.id;

             end if;

          end if;/*}*/

          p('scalar_datatype: returning null');
          l;
          return null;

     end "scalar_datatype";/*}*/

     function  "scalar_subquery_expression"     (tg in out token_getter) return number is/*{*/
          r  nd_scalar_subquery_expression%rowtype;
     begin
         
          e('scalar_subquery_expression', tg);

          tg.push_state;

     --   starts with (

          if not tg.type_('SYM') then/*{*/
             p('scalar_subquery_expression:  no (, returning');
             l;
             tg.pop_state;
             -- obviously no (, returning null
             return null;
          end if;/*}*/

          if not tg.token_value_sym = ('(') then/*{*/
             p('scalar_subquery_expression:  no (, returning');
             l;
             tg.pop_state;
             return null;
          end if;/*}*/

          tg.next_stored_program_token;

          p('scalar_subquery_expression: subquery?', tg);
          r.subquery := "subquery"(tg, into_clause => false); -- TODO_0041: Parameter to indicate that exactly one column is expected (in accordance to definition of scalar subquery)

          if r.subquery is null then/*{*/
             p('scalar_subquery_expression: no subquery, returning null;');
             l;
             tg.pop_state;
             return null;
          end if;/*}*/

          p('scalar_subquery_expression: closing )?', tg);

          if not tg.type_('SYM') then/*{*/
             raise_error(tg, ') expected');
          end if;/*}*/

          if not tg.token_value_sym = (')') then/*{*/
             return null;
          end if;/*}*/

          tg.next_stored_program_token;

          tg.remove_state;

          next_nd_seq(r.id);
          insert into nd_scalar_subquery_expression values r;

          p('scalar_subquery_expression: ok', tg);
          l;

          return r.id;

     end "scalar_subquery_expression";/*}*/

     function  "searched_case_elem"             (tg in out token_getter, searched_case_expression in number) return boolean is/*{*/
           r nd_searched_case_elem%rowtype;
     begin
           e('searched_case_elem', tg);

           if not tg.type_('ID') then
              p('searched_case_elem: not an ID, returning false');
              l;
              return false;
           end if;

           if not tg.compare_i('when') then
              p('searched_case_elem: not WHEN ID, returning false');
              l;
              return false;
           end if;

           tg.next_stored_program_token;

           p('searched_case_elem: condition?');
           r.condition := "condition"(tg, check_outer_join_symbol => false, prior_ => false, boolean_factor => false /* TODO_0042 could this not be happening in PL/SQL context */, aggregate_function => false);

           if r.condition is null then
              raise_error(tg, 'condition expected');
           end if;

           if not tg.type_('ID') then
              raise_error(tg, 'then expected');
           end if;

           if not tg.compare_i('then') then
              raise_error(tg, 'then expected');
           end if;

           tg.next_stored_program_token;

           r.return_expr := "expression"(tg, check_outer_join_symbol => false, star_ => false, aggregate_function => false, prior_ => false);

           if r.return_expr is null then
              raise_error(tg, 'return expression expected');
           end if;

           r.searched_case_expression := searched_case_expression;

           insert into nd_searched_case_elem values r;

           l;
           return true;
     end "searched_case_elem";/*}*/

     function  "searched_case_stmt_elem"        (tg in out token_getter, searched_case_statement in number) return boolean is/*{*/
           r nd_searched_case_stmt_elem%rowtype;
     begin
           e('searched_case_stmt_elem', tg);

           if not tg.type_('ID') then
              p('searched_case_stmt_elem: not an ID, returning false');
              l;
              return false;
           end if;

           if not tg.compare_i('when') then
              p('searched_case_stmt_elem: not WHEN ID, returning false');
              l;
              return false;
           end if;

           tg.next_stored_program_token;

           p('searched_case_stmt_elem: condition?');
           r.condition := "condition"(tg, check_outer_join_symbol => false, prior_ => false, boolean_factor => true, aggregate_function => false);


           if r.condition is null then/*{*/
              raise_error(tg, 'condition expected');
           end if;/*}*/

           if not is_id_eaten(tg, 'then') then/*{*/
              raise_error(tg, 'then expected');
           end if;/*}*/

           r.statement_list := "statement_list"(tg);

           if r.statement_list is null then/*{*/
              raise_error(tg, 'statement list expression expected');
           end if;/*}*/

           r.searched_case_statement := searched_case_statement;

           insert into nd_searched_case_stmt_elem values r;

           l;
           return true;
     end "searched_case_stmt_elem";/*}*/

     function  "searched_case_expression"       (tg in out token_getter) return number is/*{*/
          r nd_searched_case_expression%rowtype;
     begin

          e('searched_case_expression', tg);

          next_nd_seq(r.id);

          insert into nd_searched_case_expression values r;

          if not "searched_case_elem"(tg, r.id) then
             delete from nd_searched_case_expression where id = r.id;
             p('searched_case_elem: not first searched_case_elem found, returning null');
             l;
             return null;
          end if;

          p('searched_case_elem: first searched_case_elem found');

          while "searched_case_elem"(tg, r.id) loop
                p('searched_case_elem: next searched_case_elem found');
          end loop;

          l;
          return r.id;
     end "searched_case_expression";/*}*/

     function  "searched_case_statement"        (tg in out token_getter) return number is/*{*/
          r nd_searched_case_statement%rowtype;
     begin

          e('searched_case_statement', tg);

          next_nd_seq(r.id);

          insert into nd_searched_case_statement values r;

          if not "searched_case_stmt_elem"(tg, r.id) then
             delete from nd_searched_case_statement where id = r.id;
             p('searched_case_elem: not first searched_case_elem found, returning null');
             l;
             return null;
          end if;

          p('searched_case_elem: first searched_case_elem found');

          while "searched_case_stmt_elem"(tg, r.id) loop
                p('searched_case_elem: next searched_case_elem found');
          end loop;

          l;
          return r.id;
     end "searched_case_statement";/*}*/

     function  "select_elem"                    (tg in out token_getter, select_list in number) return boolean is/*{*/
        r    nd_select_elem%rowtype;
     begin

        e('select_elem', tg);
        r.select_list := select_list;

        -- ORA-30563: outer join operator (+) not allowed in select-list
        r.expression := "expression"(tg, check_outer_join_symbol => false, star_ => true, aggregate_function => true, prior_ => false);

        if r.expression          is null then
           raise_error(tg, 'expression expected for select_elem');
        end if;

        p('select_elem: checking for alias');

        if tg.type_('ID') and tg.compare_i('as')  then 
           p('select_elem: AS found');
           r.as_ := 1;
           tg.next_stored_program_token;
        end if;

        if tg.type_('ID') and not is_keyword(tg.token_value) then/*{*/

           r.c_alias := get_id(tg);
           p('select_elem: alias found: ' || r.c_alias);

        end if;/*}*/

        insert into nd_select_elem values r;
        p('select_elem: returning true');

        l;
        return true;

     end "select_elem";/*}*/

     function  "select_list"                    (tg in out token_getter) return number is/*{*/
         r   nd_select_list%rowtype;
     begin

       e('select_list', tg);
 
          next_nd_seq(r.id);
 
          insert into nd_select_list values r;
 
          if not "select_elem"(tg, r.id) then
             p('select_list: no select_elem found: it''s not a select_list');
             delete from nd_select_list where id = r.id;
             l;
             return null;
          end if;
          p('select_list: 1st select_elem found');

       -- While there are commas
          while tg.type_('SYM') and tg.token_value_sym = ',' loop/*{*/

                tg.next_stored_program_token;

                if not "select_elem"(tg, r.id) then
                   raise_error(tg, 'Select item expected');
                end if;
                p('select_list: another select_elem found');

          end loop;/*}*/

          p('select_list: last select_elem, returning: ' || r.id);
 
          l;
          return r.id;

     end "select_list";/*}*/

     function  "select_into_statement"          (tg in out token_getter) return number is/*{*/
           r nd_select_into_statement%rowtype;
     begin

           e('select_into_statement', tg);


           p('select_into_statement: select_statement?', tg); 
           r.select_statement := "select_statement"(tg, plsql => true);
           if r.select_statement is not null then
              
              p('select_into_statement: ;? after select_statement', tg);

              eat_semicolon(tg);

              next_nd_seq(r.id);
              insert into nd_select_into_statement values r;
              p('select_into_statement: returning ' || r.id);
              l;
              return r.id;
           end if;

           p('select_into_statement: returning null', tg);
           l;
           return null;

     end "select_into_statement";/*}*/

     function  "select_statement"               (tg in out token_getter, plsql in boolean) return number is/*{*/
     --
     -- http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/statements_10002.htm#SQLRF01702
     --
     -- A 'select statement' doesn't necessarily start with the 'select'
     -- keyword. In fact, a select statement is:
     --
     --    select_statement ::= [subquery_factoring_clause] subquery [for_update_clause]
     --
     -- and a subquery is
     --
     --    subquery ::= query_block | subquery .... | "(" subquery ")"
     --
     -- and the 'select' keyword is the first keyword in -> subquery.
     --
     -- If a select_statement is used in PLSQL, it must have an INTO
     -- clause, which must not be existant if not used as PLSQL.
     -- This behaviour is controlled with the -> plsql parameter.
     -- Note, Cursors can be defined in PLSQL, but can't have the INTO clause,
     -- so they must be called with plsql = false.

       r  nd_select_statement%rowtype;
     begin

       e('select_statement', tg);

          r.subquery_factoring_clause := "subquery_factoring_clause"(tg);

          p('select_statement: going for subquery');
          r.subquery := "subquery"(tg, into_clause => plsql);

          if r.subquery is null then
             p('select_statement: no subquery found, returning');
             l;
             return null;
          end if;

          r.for_update_clause := "for_update_clause"(tg);

          next_nd_seq(r.id);
          p('select_statement: returning ' || r.id, tg);
          insert into nd_select_statement values r;
          l;
          return r.id;

     end "select_statement";/*}*/

     function  "simple_case_elem"               (tg in out token_getter, simple_case_expression in number) return boolean is/*{*/
           r nd_simple_case_elem%rowtype;
     begin
          e('simple_case_elem', tg);

          if not tg.type_('ID') then
             p('simple_case_elem: not WHEN ID, returning false');
             l;
             return false;
          end if;

          if not tg.compare_i('when') then
             p('simple_case_elem: not WHEN, returning false');
             l;
             return false;
          end if;

          tg.next_stored_program_token;
          p('simple_case_elem: going for comparison_expr');
          r.comparison_expr := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

          if r.comparison_expr is null then
             raise_error(tg, 'comparison expression expected');
          end if;

          if not tg.type_('ID') then
             raise_error(tg, 'then expected');
          end if;

          if not tg.compare_i('then') then
             raise_error(tg, 'then expected');
          end if;

          tg.next_stored_program_token;

          p('simple_case_elem: going for return_expr');
          r.return_expr := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

          if r.return_expr is null then
             raise_error(tg, 'return expression expected');
          end if;

          r.simple_case_expression := simple_case_expression;
          insert into nd_simple_case_elem values r;

          p('simple_case_elem: ok');
          l;

          return true;

     end "simple_case_elem";/*}*/

     function  "simple_case_expression"         (tg in out token_getter) return number is   /*{*/
           r nd_simple_case_expression%rowtype;
     begin
           e('simple_case_expression', tg);
           r.expression := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

           if r.expression is null then
              p('simple_case_expression: no expression found, returning null');
              l;
              return null;
           end if;

           p('simple_case_expression: expression found, now going for elems');
           next_nd_seq(r.id);
           insert into nd_simple_case_expression values r;

           if not "simple_case_elem"(tg, r.id) then
              raise_error(tg, 'at least one simple case elem expected');
           end if;

           while "simple_case_elem"(tg, r.id) loop
                  null;
           end loop;
           p('simple_case_expression: returning ' || r.id);
           l;
           return r.id;
       
     end "simple_case_expression";/*}*/

     function  "simple_case_stmt_elem"          (tg in out token_getter, simple_case_statement in number) return boolean is/*{*/
           r nd_simple_case_stmt_elem%rowtype;
     begin
          e('simple_case_stmt_elem', tg);

          p('simple_case_stmt_elem: when?');
          if not is_id_eaten(tg, 'when') then/*{*/
             p('simple_case_stmt_elem: not WHEN id, returning false');
             l;
             return false;
          end if;/*}*/

          p('simple_case_stmt_elem: comparison_expr?');
          r.comparison_expr := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

          if r.comparison_expr is null then
             raise_error(tg, 'comparison expression expected');
          end if;

          if not is_id_eaten(tg, 'then') then
             raise_error(tg, 'then expected');
          end if;

          p('simple_case_stmt_elem: statement_list?');
          r.statement_list := "statement_list"(tg);

          if r.statement_list is null then
             raise_error(tg, 'statement list expected');
          end if;

          r.simple_case_statement := simple_case_statement;
          insert into nd_simple_case_stmt_elem values r;

          p('simple_case_stmt_elem: returning true');
          l;

          return true;

     end "simple_case_stmt_elem";/*}*/

     function  "simple_case_statement"          (tg in out token_getter) return number is   /*{*/
           r nd_simple_case_statement%rowtype;
     begin
           e('simple_case_statement', tg);

           p('simple_case_statement: selector?');
           r.selector := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

           if r.selector is null then/*{*/
              p('simple_case_statement: selector is null, returning null');
              l;
              return null;
           end if;/*}*/

           p('simple_case_expression: selector found, now going for elems',tg);
           next_nd_seq(r.id);
           insert into nd_simple_case_statement values r;

           if not "simple_case_stmt_elem"(tg, r.id) then/*{*/
              raise_error(tg, 'at least one simple case stmt elem expected');
           end if;/*}*/

           while "simple_case_stmt_elem"(tg, r.id) loop/*{*/
                  null;
           end loop;/*}*/

           p('simple_case_statement: returning ' || r.id);
           l;
           return r.id;
       
     end "simple_case_statement";/*}*/

     function  "single_table_insert"            (tg in out token_getter) return number is /*{*/
          r  nd_single_table_insert%rowtype;
     begin

          r.insert_into_clause := "insert_into_clause"(tg);
          if r.insert_into_clause is null then/*{*/
             return null;
          end if;/*}*/

          r.values_clause := "values_clause"(tg);
          if r.values_clause is null then
             r.subquery := "subquery"(tg, into_clause => false);
             if r.subquery is null then
                raise_error(tg, 'neither values clause nor subquery');
             end if;
          else
             r.returning_clause := "returning_clause"(tg);
          end if;

          r.error_logging_clause := "error_logging_clause"(tg);

          next_nd_seq(r.id);
          insert into nd_single_table_insert values r;
          return r.id;

     end "single_table_insert";/*}*/

     function  "sql_statement"                  (tg in out token_getter) return number is/*{*/
        r    nd_sql_statement%rowtype;
     begin
        
           e('sql_statement', tg);

           p('sql_statement: dml_statement?', tg);
           r.dml_statement := "dml_statement"(tg);
           if r.dml_statement is not null then
--            eat_semicolon(tg);
              next_nd_seq(r.id);
              insert into nd_sql_statement values r;
              p('sql_statement: returning ' || r.id, tg);
              l;
              return r.id;
           end if;

           p('sql_statement: returning null', tg);
           l;

           return null;

     end "sql_statement";/*}*/

     function  "start_with_condition"           (tg in out token_getter) return number is/*{*/
         condition number;
     begin

          -- There is no 'node' associated with a start with condition.
          -- The id of a condition is returned instead.
          -- However, the function checks for the existence of the keywords
          --'START' and 'WITH'.
          -- TODO_0043: this function is quite similar to -> "connect_by_condition"

          e('start_with_condition', tg);

          if not tg.type_('ID') then/*{*/
             l;
             return null;
          end if;/*}*/

          if not tg.compare_i('start') then/*{*/
             l;
             return null;
          end if;/*}*/

          tg.next_stored_program_token;

          if not tg.compare_i('with') then
             raise_error(tg, 'with in start with condition expected');
          end if;
          tg.next_stored_program_token;

          condition := "condition"(tg, check_outer_join_symbol=>false /* TODO_0044: or should it be true? */, prior_ => false, boolean_factor => false, aggregate_function => false);

          if condition is null then /*{*/
             raise_error(tg, 'condition expected for start with');
          end if;/*}*/

          p('start_with_condition ok, returning ' || condition);
          l;
          return condition;

     end "start_with_condition";/*}*/

     function  "statement_elem"                 (tg in out token_getter, statement_list in number) return boolean/*{*/
     is
           r nd_statement_elem%rowtype;
     begin
     --    http://download.oracle.com/docs/cd/E11882_01/appdev.112/e17126/block.htm#CJACHDGG
           e('statement_elem', tg);
           r.statement_list := statement_list;

           -- TODO: Why this check?
           if tg.type_('ID') and is_keyword(tg.token_value) then/*{*/
              if not tg.compare_i('select') and not tg.compare_i('case') and not tg.compare_i('begin') and not tg.compare_i('while') then
                 p('statement_elem: ' || tg.token_value || ' is a keyword, returning false');
                 l;
                 return false;
              end if;
           end if;/*}*/

           p('statement_elem: checking for label', tg);
           if tg.type_('SYM') and tg.token_value_sym = '<<' then/*{*/
              tg.next_stored_program_token;

              r.label_ := get_id(tg, 'label name expected');

              if tg.token_value_sym != '>>' then
                 raise_error(tg, '>> expected');
              end if;
              tg.next_stored_program_token;
           end if;/*}*/

           if tg.type_('ID')  then/*{*/

              if tg.compare_i('null') then/*{*/

                 tg.next_stored_program_token;

                 eat_semicolon(tg);

                 r.null_statement := 1;
                 insert into nd_statement_elem values r;
                 p('statement_elem: null statement found, returning true');
                 l;
                 return true;
              end if;/*}*/

           end if;/*}*/

           p('statement_elem: basic_loop_statement?', tg);
           r.basic_loop_statement := "basic_loop_statement"(tg);
           if r.basic_loop_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: basic_loop_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: exit/continue_statement?', tg);
           "exit/continue_statement"(tg, r.exit_statement, r.continue_statement);
           if r.exit_statement is not null or r.continue_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: exit_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: execute_immediate_statement?', tg);
           r.execute_immediate_statement := "execute_immediate_statement"(tg);
           if r.execute_immediate_statement is not null then /*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: execute_immediate_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: return_statement?');
           r.return_statement := "return_statement"(tg);
           if r.return_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: return_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: case_statement?');
           r.case_statement := "case_statement"(tg);
           if r.case_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: case_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: close_statement?');
           r.close_statement := "close_statement"(tg);
           if r.close_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: close_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: fetch_statement?');
           r.fetch_statement := "fetch_statement"(tg);
           if r.fetch_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: fetch_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: for_loop_statement?');
           r.for_loop_statement := "for_loop_statement"(tg);
           if r.for_loop_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: for_loop_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: forall_statement?');
           r.forall_statement := "forall_statement"(tg);
           if r.forall_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: forall_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: if_statment?');
           r.if_statement := "if_statement"(tg);
           if r.if_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: if_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: cursor_for_loop_statement?');
           r.cursor_for_loop_statement := "cursor_for_loop_statement"(tg);
           if r.cursor_for_loop_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: cursor_for_loop_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: open_for_statement?');
           r.open_for_statement := "open_for_statement"(tg);
           if r.open_for_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: open_for_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: open_statement?');
           r.open_statement := "open_statement"(tg);
           if r.open_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: open_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: plsql_block?');
           r.plsql_block := "plsql_block"(tg);
           if r.plsql_block is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: plsql_block found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: sql_statement?', tg);
           r.sql_statement := "sql_statement"(tg);
           if r.sql_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: sql_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: assignment_statement?');
           r.assignment_statement := "assignment_statement"(tg);
           if r.assignment_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: assignment_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: while_loop_statement?');
           r.while_loop_statement := "while_loop_statement"(tg);
           if r.while_loop_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: while_loop_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: procedure_call?');
           r.procedure_call := "procedure_call"(tg);
           if r.procedure_call is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: procedure_call found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: select_into_statement?');
           r.select_into_statement := "select_into_statement"(tg);
           if r.select_into_statement is not null then/*{*/
              insert into nd_statement_elem values r;
              p('statement_elem: select_into_statement found, returning true');
              l;
              return true;
           end if;/*}*/

           p('statement_elem: no statement found, returning false');
           l;
           return false; 

     end "statement_elem";/*}*/

     function  "statement_list"                 (tg in out token_getter) return number is/*{*/
           r nd_statement_list%rowtype;
     begin
        
           e('statement_list', tg);
         
           next_nd_seq(r.id);
           insert into nd_statement_list values r;

           if not "statement_elem"(tg, r.id) then/*{*/
              delete from nd_statement_list where id = r.id;
              p('statement_list: no statement_elem found returning null');
              l;
              return null;
           end if;/*}*/

           loop/*{*/
               exit when tg.type_('ID') and tg.compare_i('exception');
               exit when not "statement_elem"(tg, r.id);
           end loop;/*}*/


           p('statement_list: returning ' || r.id, tg);
           l;
           return r.id;

     end "statement_list";/*}*/

     function  "subquery"                       (tg in out token_getter, into_clause in boolean) return number is/*{*/
         r   nd_subquery%rowtype;
         set_operator nd_subquery_elem.set_operator%type;

     begin
     -- A subquery is one or more subquery_elem each joined to the previous one by a so called 'set operator'

      e('subquery', tg);
      next_nd_seq(r.id);
      insert into nd_subquery values r;

      if not "subquery_elem"(tg, subquery => r.id, set_operator => null, into_clause => into_clause) then/*{*/
         p('subquery: no subquery_elem found, returning null');
         delete from nd_subquery where id = r.id;
         l;
         return null;

      end if;/*}*/

      while tg.type_('ID') loop/*{*/

            if    tg.compare_i('union') then/*{*/
                  set_operator := tg.token_value;
                  tg.next_stored_program_token;

                  if tg.type_('ID') and tg.compare_i('all') then
                     set_operator := set_operator || ' ' || tg.token_value;
                     tg.next_stored_program_token;
                  end if;
            /*}*/
            elsif tg.compare_i('minus') then/*{*/
                  set_operator := tg.token_value;
                  tg.next_stored_program_token;
            /*}*/
            elsif tg.compare_i('intersect') then/*{*/
                  set_operator := tg.token_value;
                  tg.next_stored_program_token;
            /*}*/
            else/*{*/
              p('subquery_elem: no further set operator found, exiting loop');
              exit;
            end if;/*}*/

            -- into_clause set to false as only first subquery_elem within a select statement can have one!
            if not "subquery_elem"(tg, subquery => r.id, set_operator => set_operator, into_clause => false) then/*{*/
               raise_error(tg, 'subquery elem after ' || set_operator || ' expected');
            end if;/*}*/

      end loop;/*}*/

      p('subquery: order_by_clause?');
      r.order_by_clause := "order_by_clause"(tg);

      if r.order_by_clause is not null then
         update nd_subquery set row = r where id = r.id;
      end if;

      p('subquery: id ' || r.id || ' inserted');

      l;
      return r.id;

     end "subquery";/*}*/

     function  "subquery_elem"                  (tg in out token_getter, subquery in number, set_operator in varchar2, into_clause in boolean) return boolean is/*{*/
         r   nd_subquery_elem%rowtype;
     begin

         e('subquery_elem', tg);

         r.subquery     := subquery;
         r.set_operator := set_operator;

         if   not tg.type_('SYM') or tg.token_value_sym != '(' then/*{*/
         ----------------------------------------------------------
         --   It is not a .... "(" subquery ")" branch.
         --   So, it might either be a
         --       subquery UNION / INTERSECT / MINUS subquery, or a
         --       query_block.
         -- 
         --   We first check for the query block possibility:

              p('subquery: NO opening ( found, query_block?');
              r.query_block := "query_block"(tg, into_clause => into_clause);

              if r.query_block is null then/*{*/
                 p('subquery: no query_block after opening (, returning false');
                 l;
                 return false;
              end if;/*}*/

         /*}*/
         else /*{*/
         -------------------------------------------------------
         --    First, we check if this is the 
         --    .... "(" subquery ")" branch:
               tg.next_stored_program_token;

               p('subquery: opening ( found, subquery?');
               r.subquery_in_paranthesis := "subquery"(tg, into_clause => false);

               if r.subquery_in_paranthesis is null then/*{*/
                  raise_error(tg, 'subquery_in_paranthesis expected');
               end if;/*}*/
                  
--             tg.next_stored_program_token;

               if not tg.type_('SYM') then/*{*/
                  raise_error(tg, 'Closing ) expected in subquery');
               end if;/*}*/

               if not tg.token_value_sym = ')' then/*{*/
                  raise_error(tg, 'Closing ) expected in subquery');
               end if;/*}*/

               tg.next_stored_program_token;

         end if;/*}*/

         insert into nd_subquery_elem values r;
         p('subquery_elem: returning true');
         l;
         return true;

     end "subquery_elem";/*}*/

     function  "subquery_factoring_clause"      (tg in out token_getter) return number is
         r   nd_subquery_factoring_clause%rowtype;
     begin

         if not is_id_eaten(tg, 'with') then/*{*/
            return null;
         end if;/*}*/

         next_nd_seq(r.id);
         insert into nd_subquery_factoring_clause values r;

         if not "subquery_factoring_elem"(tg, r.id) then
            raise_error(tg, 'at least one subquery factoring elem expected');
         end if;

         while tg.type_('SYM') and tg.token_value_sym = ',' loop/*{*/
           tg.next_stored_program_token;
           if not "subquery_factoring_elem"(tg, r.id) then/*{*/
              raise_error(tg, 'another subquery_factoring_elem expected.');
           end if;/*}*/
         end loop;/*}*/

         return r.id;

     end "subquery_factoring_clause";

     function  "subquery_factoring_elem"        (tg in out token_getter, subquery_factoring_clause in number) return boolean is/*{*/
          r  nd_subquery_factoring_elem%rowtype;
     begin

         e('subquery_factoring_elem', tg);

         if not tg.type_('ID') then/*{*/
            p('subquery_factoring_elem: not ID, returning false');
            l;
            return false;
         end if;/*}*/

         p('subquery_factoring_elem: query_name?', tg);
         r.query_name := get_id(tg, 'query name expected');

         p('subquery_factoring_elem: column_alias_list?', tg);
         if tg.type_('SYM') and tg.token_value_sym = '(' then/*{*/
            tg.next_stored_program_token;

            p('subquery_factoring_elem: plsql_identifier_list', tg);
            r.column_alias_list := "plsql_identifier_list"(tg);
            if r.column_alias_list is null then/*{*/
               raise_error(tg, 'column_alias_list is null');
            end if;/*}*/

            if not tg.type_('SYM') or tg.token_value_sym != ')' then/*{*/
               raise_error(tg, ') expected');
            end if;/*}*/

            tg.next_stored_program_token;


         end if;/*}*/

         p('subquery_factoring_elem: as?', tg);
         if not is_id_eaten(tg, 'as') then/*{*/
            raise_error(tg, 'as expected');
         end if;/*}*/

         p('subquery_factoring_elem: subquery?', tg);
         r.subquery := "subquery"(tg, into_clause => false);

         if r.subquery is null then /*{*/
            raise_error(tg, 'subquery is null');
         end if;/*}*/

         r.subquery_factoring_clause := subquery_factoring_clause;
         insert into nd_subquery_factoring_elem values r;
         p('subquery_factoring_clause: returning true', tg);
         l;
         return true;

     end "subquery_factoring_elem";/*}*/

     function  "subtype_definition"             (tg in out token_getter) return number is/*{*/
         r nd_subtype_definition%rowtype;
     begin
       -- TODO_0070: Testcase for subtype definition
       --
       --          for example:
       --              SUBTYPE abc is tab%rowtype;
       --
       e('subtype_definition', tg);

       if not tg.compare_i('SUBTYPE') then
          p('subtype_definition: keyword SUBTYPE not found, returning null');
          l;
          return null;
       end if;

       tg.next_stored_program_token;

       r.name := get_id(tg, 'Name for SUBTYPE expected');

       if not tg.compare_i('IS') then
          p('subtype definition: keyword IS not found, returning null');
          l;
          return null;
       end if;

       tg.next_stored_program_token;

       r.basetype := "datatype"(tg, with_precision => true);

       if r.basetype is null then
          raise_error(tg, 'base type!');
       end if;

       eat_semicolon(tg);

       next_nd_seq(r.id);

       p('record_type_definition: OK');
       insert into nd_subtype_definition values r;

       l;
       return r.id;

     end "subtype_definition";/*}*/

     /*}*/
     -- "T"/*{*/

     function  "table_collection_expression"    (tg in out token_getter) return number is/*{*/
          r  nd_table_collection_expression%rowtype;
     begin
      
          e('table_collection_expression', tg);

          p('table_collection_expression: keyword TABLE?');
          if not is_id_eaten(tg, 'table') then/*{*/
             p('table_collection_expression: no TABLE, returning null');
             l;
             return null;
          end if;/*}*/

          p('table_collection_expression: opening (?', tg);
          if not tg.type_('SYM') or tg.token_value_sym != '(' then
             raise_error(tg, '( expected');
          end if;
          tg.next_stored_program_token;

          p('table_collection_expression: expression?');
          r.collection_expression := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);
          if r.collection_expression is null then/*{*/
             raise_error(tg, 'collection_expression is null');
          end if;/*}*/

          p('table_collection_expression: closing )?', tg);
          if not tg.type_('SYM') or tg.token_value_sym != ')' then
             raise_error(tg, ') expected');
          end if;
          tg.next_stored_program_token;

          next_nd_seq(r.id);
          insert into nd_table_collection_expression values r;
          p('table_collection_expression: returning ' || r.id);
          l;
          return r.id;

     end "table_collection_expression";/*}*/

     function  "table_reference"                (tg in out token_getter) return number is/*{*/
          r  nd_table_reference%rowtype;
     begin
       
          e('table_reference', tg);

          p('table_reference: query_table_expression?', tg);
          r.query_table_expression := "query_table_expression"(tg);

          -- Before checking for an alias for the 'table reference', we're
          -- checking if the current token is 'where', which obviously
          -- cannot be an alias, but rather starts a where condition:
          if tg.type_('ID') and tg.compare_i('where') then
             -- We have a where. So, we return without eating the 'where'.
             next_nd_seq(r.id);
             insert into nd_table_reference values r;
             p('table_reference: where found, returning ' || r.id, tg);
             l;
             return r.id;
          end if;

          p('table_reference: Checking for an alias for the ''query table expression''', tg);

          if tg.type_ in ('ID', 'Id') then/*{*/
             if not is_keyword(tg.token_value) then
                r.t_alias := get_id(tg);
                p('table_reference: alias found: ' || r.t_alias, tg);
             end if;
          end if;/*}*/

          next_nd_seq(r.id);
          
          insert into nd_table_reference values r;
          p('table_reference: returning ' || r.id, tg);
          l;
          return r.id;

     end "table_reference";/*}*/

     function  "term"                           (tg in out token_getter, expression in number, addop in varchar2, check_outer_join_symbol in boolean, star_ in boolean, aggregate_function in boolean) return boolean is/*{*/
           r nd_term%rowtype;

           mulop varchar2(1);
     begin

       e('term', tg);

       next_nd_seq(r.id);
       r.addop      := addop;
       r.expression := expression;
       insert into nd_term values r;

       -- The first factor in a term is connected by no mulop,
       -- therefore, the coresponding parameter is null
       --
       -- If the term can be a 'star-term', the first factor can be a star-factor as well, hence the star_ => star_.
       if not "factor"(tg, term => r.id, mulop => null, check_outer_join_symbol => check_outer_join_symbol, star_ => star_, aggregate_function => aggregate_function) then
          p('term: no first factor found, returning false', tg);
          delete from nd_term where id = r.id;
          l;
          return false;
       end if;

       p('term: first factor found, searching for further factors (that whould be connected with * or /', tg);

       if is_keyword(tg.current_token_.token_) then/*{*/
       -- This is mainly necessery because (for example) the
       -- following is possible:
       --   select 4+5+6*7 from dual
       -- and we don't want the from to destroy the
       -- select statement.
      
          p('term: keyword found, returning true', tg);
          l;
          return true;
       end if;/*}*/

       loop/*{*/

           if not tg.type_('SYM') then/*{*/
              p('term: not SYM, exiting loop');
              exit;
           end if;/*}*/

           if tg.token_value_sym not in ('*', '/') then/*{*/
              p('term: not * nor /, exiting loop over terms');
              exit;
           end if;/*}*/

           p('term: mulop found [' || tg.token_value_sym || '], going for next factor connected by it');

           mulop := tg.token_value_sym;
           tg.next_stored_program_token;

           -- The n-th factor (for n>1) cannot be a star-factor, even if the term can be a star-term, hence the star_ => false.
           if not "factor"(tg, term=> r.id, mulop => mulop, check_outer_join_symbol => check_outer_join_symbol, star_ => false, aggregate_function => aggregate_function) then/*{*/
              raise_error(tg, 'factor expected after mulop ' || mulop);
           end if;/*}*/

       end loop;/*}*/

       p('term: found and finished, returning true', tg);
       l;
       return true;

     end "term";/*}*/

     function  "type_definition"                (tg in out token_getter) return number is/*{*/
          r  nd_type_definition%rowtype;
     begin

          e('type_definition', tg);
     
          tg.push_state;
          r.collection_type_definition := "collection_type_definition"(tg);
          if r.collection_type_definition is not null then/*{*/
             next_nd_seq(r.id);
             insert into nd_type_definition values r;
             l;
             tg.remove_state;
             return r.id;
          end if;/*}*/
          tg.pop_state;

          p('type_definition: not a collection type, maybe a record type?');

          tg.push_state;
          r.record_type_definition := "record_type_definition"(tg);
          if r.record_type_definition is not null then/*{*/
             next_nd_seq(r.id);
             insert into nd_type_definition values r;
             l;
             tg.remove_state;
             return r.id;
          end if;/*}*/
          tg.pop_state;

          p('type_definition: not a record type, maybe a ref cursor type?');

          tg.push_state;
          r.ref_cursor_type_definition := "ref_cursor_type_definition"(tg);
          if r.ref_cursor_type_definition is not null then
             next_nd_seq(r.id);
             insert into nd_type_definition values r;
             l;
             tg.remove_state;
             return r.id;
          end if;
          tg.pop_state;

          p('type_definition: not a ref cursor type, maybe a subtype definition?');

          tg.push_state;
          r.subtype_definition := "subtype_definition"(tg);
          if r.subtype_definition is not null then
             next_nd_seq(r.id);
             insert into nd_type_definition values r;
             l;
             tg.remove_state;
             return r.id;
          end if;
          tg.pop_state;

          p('type_definition: Not a type definition.');
          l;
          return null;

     end "type_definition";/*}*/

     /*}*/
     -- "U"/*{*/

     function  "update_set_clause"              (tg in out token_getter) return number is/*{*/
         r   nd_update_set_clause%rowtype;
     begin

           next_nd_seq(r.id);
           insert into nd_update_set_clause values r;

           if not "update_set_clause_elem"(tg, r.id) then/*{*/
              delete from nd_update_set_clause where id = r.id;
              return null;
           end if;/*}*/

           while tg.type_('SYM') and tg.token_value_sym = ',' loop/*{*/
                 tg.next_stored_program_token;
                 if not "update_set_clause_elem"(tg, r.id) then
                    raise_error(tg, 'update_set_clause_elem expected');
                 end if;
           end loop;/*}*/

           return r.id;

     end "update_set_clause";/*}*/

     function "update_set_clause_elem"          (tg in out token_getter, update_set_clause in number) return boolean is/*{*/
         r  nd_update_set_clause_elem%rowtype;
     begin

         -- TODO_0046: plsql_identifier?
         r.column_ := "complex_plsql_ident"(tg, star_ => false);

         if r.column_ is null then/*{*/
            return false;
         end if;/*}*/

         if not tg.type_('SYM') or tg.token_value_sym != '=' then/*{*/
            raise_error(tg, '= expected');
         end if;/*}*/
         tg.next_stored_program_token;

         r.expression_ := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);
         if r.expression_ is null then/*{*/
            raise_error(tg, 'expression_ is null');
         end if;/*}*/

         r.update_set_clause := update_set_clause;
         insert into nd_update_set_clause_elem values r;
         return true;

     end "update_set_clause_elem";/*}*/


     function  "update_statement"               (tg in out token_getter) return number is/*{*/
           r nd_update_statement%rowtype;
     begin
       
           e('update_statement', tg);

           if not is_id_eaten(tg, 'update') then/*{*/
              p('update_statement: not UPDATE, returning null');
              l;
              return null;
           end if;/*}*/

           p('update_statement: hint?',tg);
           r.hint := "hint"(tg);

           p('update_statement: dml_table_expression_clause?', tg);
           r.dml_table_expression_clause := "dml_table_expression_clause"(tg);
           -- TODO_0047 or "ONLY (dml_table_expression_clause)"

           p('update_statement: alias?', tg);
           if tg.type_('ID') and not is_keyword(tg.token_value) then/*{*/
              r.alias_ := get_id(tg, null);
           end if;/*}*/

           p('update_statement: update_set_clause?', tg);
           r.update_set_clause := "update_set_clause"(tg);
           if r.update_set_clause is null then/*{*/
              raise_error(tg, 'update_set_clause expected');
           end if;/*}*/

           p('update_statement: where_clause?', tg);
           r.where_clause     := "where_clause"(tg);

           p('update_statement: returning_clause?', tg);
           r.returning_clause := "returning_clause"(tg);

           p('update_statement: error_logging_clause?', tg);
           r.error_logging_clause := "error_logging_clause"(tg);

           p('update_statement: semicolon?', tg);
           eat_semicolon(tg);

           next_nd_seq(r.id);
           insert into nd_update_statement values r;

           p('update_statement: returning ' || r.id);
           l;
           return r.id;


     end "update_statement";/*}*/

     function  "using_clause"                   (tg in out token_getter) return number is/*{*/
           r nd_using_clause%rowtype;
     begin

           e('using_clause', tg);
           if not is_id_eaten(tg, 'using') then/*{*/
              p('using_clause: no USING, returning null', tg);
              l;
              return null;
           end if;/*}*/

           if is_id_eaten(tg, 'in') then/*{*/
              r.in_ := 1;
           end if;/*}*/

           if is_id_eaten(tg, 'out') then/*{*/
              r.out_ := 1;
           end if;/*}*/

           p('using_clause: plsql_identifier_list?');
           r.bind_arguments := "plsql_identifier_list"(tg);

           next_nd_seq(r.id);
           insert into nd_using_clause values r;
           p('using_clause: returning ' || r.id);
           return r.id;

     end "using_clause";/*}*/

     /*}*/
     -- "V"/*{*/

     function  "values_clause"                  (tg in out token_getter) return number is/*{*/
          r  nd_values_clause%rowtype;
     begin
       
          if not is_id_eaten(tg, 'values') then/*{*/
             return null;
          end if;/*}*/

          if not tg.type_('SYM') or tg.token_value_sym != '(' then/*{*/
             raise_error(tg, '( expected');
          end if;/*}*/

          tg.next_stored_program_token;

          r.expression_list := "expression_list"(tg);
          if r.expression_list is null then/*{*/
             raise_error(tg, 'expression list is null');
          end if;/*}*/

          if not tg.type_('SYM') or tg.token_value_sym != ')' then/*{*/
             raise_error(tg, ') expected');
          end if;/*}*/

          tg.next_stored_program_token;

          next_nd_seq(r.id);
          insert into nd_values_clause values r;

          return r.id;

     end "values_clause";/*}*/

     function  "variable_declaration"           (tg in out token_getter) return number is /*{*/
         r nd_variable_declaration%rowtype;
     begin
     -- TODO_0048
     --   Note the similarity to a 
     --  "constant_declaration".

         e('variable_declaration', tg);

         if tg.type_('ID') then/*{*/
            r.name := upper(tg.current_token_.token_);
            if is_keyword(r.name) then/*{*/
               p('variable_declaration: ' || r.name || ' would be a keyword, returning null');
               l;
               return null;
            end if;/*}*/
         /*}*/
         else/*{*/
            p('variable_declaration: Not an ID, therefore not a variable declaration, returning null');
            l;
            return null;
         end if;/*}*/

         if tg.compare_i('cursor') then/*{*/
         -- TODO_0049: Is it possible for the parser to come here at all?
            l;
            return null;
         end if;/*}*/

         tg.next_stored_program_token;

         r.datatype   := "datatype"(tg, with_precision => true);

         if r.datatype is null then
            raise_error(tg, 'variable_declaration: datatype is null');
         end if;

         p('variable_declaration: datatype found', tg);

         if tg.compare_i('not') then
            tg.next_stored_program_token;

            if not tg.compare_i('null') then
               raise_application_error('-20800', 'not null expected');
            end if;

            tg.next_stored_program_token;
         end if;


         if tg.type_('SYM') and tg.token_value_sym = ':=' then

            tg.next_stored_program_token;
            r.expression := "expression"(tg, check_outer_join_symbol=>false, star_ => false, aggregate_function => false, prior_ => false);

            if r.expression is null then 
               raise_error(tg, 'expression expected');
            end if;

         end if;

         p('variable_declaration: ;?', tg);
         eat_semicolon(tg);

         next_nd_seq(r.id);

         p('variable_declaration: returning ' || r.id);
         insert into nd_variable_declaration values r;
         l;
         return r.id;

     end "variable_declaration";/*}*/

     /*}*/
     -- "W"/*{*/

     function  "where_clause"                   (tg in out token_getter) return number is/*{*/
          r  nd_where_clause%rowtype;
     begin
         e('where_clause', tg);

         if not is_id_eaten(tg, 'where') then/*{*/
            p('where_clause: not WHERE, returning null');
            l;
            return null;
         end if;/*}*/

--         if not tg.type_('ID') then
--            p('where_clause: not an ID');
--            l;
--            return null;
--         end if;
--
--         if not tg.compare_i('where')  then
--            p('where_clause: not keyword where');
--            l;
--            return null;
--         end if;
--
--       tg.next_stored_program_token;

         -- Obviously, the condition within a where clause can consist of 
         -- outer join expressions.
         r.condition := "condition"(tg, check_outer_join_symbol=>true, prior_ => false, boolean_factor => false, aggregate_function => false);

         next_nd_seq(r.id);
         insert into nd_where_clause values r;
         p('where_clause: returning ' || r.id, tg);

         l;
         return r.id;

     end "where_clause";/*}*/

     function  "while_loop_statement"           (tg in out token_getter) return number is/*{*/
          r  nd_while_loop_statement%rowtype;
     begin

          if not is_id_eaten(tg, 'while') then
             return null;
          end if;

          r.condition := "condition"(tg, check_outer_join_symbol=>false, prior_ => true, boolean_factor => true, aggregate_function => false);

          if not is_id_eaten (tg, 'loop') then/*{*/
             raise_error(tg, 'loop expected');
          end if;/*}*/

          r.statement_list := "statement_list"(tg);

          if r.statement_list is null then/*{*/
             raise_error(tg, 'statement_list expected');
          end if;/*}*/

          if not is_id_eaten(tg, 'end') then/*{*/
             raise_error(tg, 'end expected');
          end if;/*}*/

          if not is_id_eaten(tg, 'loop') then/*{*/
             raise_error(tg, 'loop expected');
          end if;/*}*/

          r.label := eat_id_or_return_null(tg);

          eat_semicolon(tg);

          next_nd_seq(r.id);
          insert into nd_while_loop_statement values r;
          return r.id;

     end "while_loop_statement";/*}*/

     function  "windowing_clause"               (tg in out token_getter) return number is/*{*/
          r  nd_windowing_clause%rowtype;
     begin
          return null;

     end "windowing_clause";/*}*/

     /*}*/

end plsql_parser;
/
