declare

--  Be sure to have run parser_1.sql 

    -- r_xx/*{*/
    r_package                 nd_package               %rowtype;
    r_declare_section         nd_declare_section       %rowtype;
    r_function_declaration    nd_function_declaration  %rowtype;
    r_function_heading        nd_function_heading      %rowtype;
    r_procedure_declaration   nd_procedure_declaration %rowtype;
    r_procedure_heading       nd_procedure_heading     %rowtype;
    r_datatype_returned       nd_datatype              %rowtype;
    r_scalar_datatype         nd_scalar_datatype       %rowtype;
    r_typename                nd_plsql_identifier      %rowtype;
    r_expression              nd_expression            %rowtype;
    r_factor                  nd_factor                %rowtype;
    r_aggregate_function      nd_aggregate_function    %rowtype;
    r_term                    nd_term                  %rowtype;
    r_item_declaration        nd_item_declaration      %rowtype;
    r_constant_declaration    nd_constant_declaration  %rowtype;
    r_plsql_identifier        nd_plsql_identifier      %rowtype;
    r_cursor_definition       nd_cursor_definition     %rowtype;
    r_select_statement        nd_select_statement      %rowtype;
    r_subquery                nd_subquery              %rowtype;
    r_query_block             nd_query_block           %rowtype;
--  TODO_0006: r_function_expression still used?
    r_function_expression     nd_function_expression   %rowtype;
    r_simple_expression       nd_simple_expression     %rowtype;
    r_table_reference         nd_table_reference       %rowtype;
    r_query_table_expression  nd_query_table_expression%rowtype;
/*}*/

    procedure check_plsql_identifier(r in nd_plsql_identifier%rowtype, i1 varchar2, i2 varchar2, i3 varchar2) is/*{*/
    begin

        if nvl(r.identifier_1, '?') != nvl(i1, '?') then 
           raise_application_error(-20800, 'expected 1: ' || i1 || ', but identifier_1: ' || r.identifier_1);
        end if;

        if nvl(r.identifier_2, '?') != nvl(i2, '?') then 
           raise_application_error(-20800, 'expected 2: ' || i2 || ', but identifier_2: ' || r.identifier_2);
        end if;

        if nvl(r.identifier_3, '?') != nvl(i3, '?') then 
           raise_application_error(-20800, 'expected 3: ' || i3 || ', but identifier_3: ' || r.identifier_3);
        end if;

    end check_plsql_identifier;/*}*/

    procedure check_plsql_identifier(id in nd_plsql_identifier.id%type, i1 varchar2, i2 varchar2, i3 varchar2) is/*{*/
      r_plsql_identifier  nd_plsql_identifier%rowtype;
    begin

      select * into r_plsql_identifier from nd_plsql_identifier where nd_plsql_identifier.id = check_plsql_identifier.id;
      check_plsql_identifier(r_plsql_identifier, i1, i2, i3);

    end check_plsql_identifier;/*}*/

    procedure check_complex_plsql_id(id in nd_complex_plsql_ident.id%type, i1 varchar2, i2 varchar2, i3 varchar2) is/*{*/
      r nd_complex_plsql_ident%rowtype;
    begin

      
      for elem in (select nd_complex_plsql_ident_elem.*, row_number() over (order by coalesce(plsql_Identifier, paran_parameter_list)) cnt from nd_complex_plsql_ident_elem where complex_plsql_ident = r.id ) loop

          if elem.cnt = 1 and nvl(i1, '?') != nvl(i1, '?') then 
             raise_application_error(-20800, 'expected 1: ' || i1 || ', but identifier_1: ' || i1);
          end if;

          if elem.cnt = 2 and nvl(i2, '?') != nvl(i2, '?') then 
             raise_application_error(-20800, 'expected 2: ' || i2 || ', but identifier_2: ' || i2);
          end if;

          if elem.cnt = 3 and nvl(i3, '?') != nvl(i3, '?') then 
             raise_application_error(-20800, 'expected 3: ' || i3 || ', but identifier_3: ' || i3);
          end if;

      end loop;

    end check_complex_plsql_id;/*}*/

    procedure error(txt in varchar2) is/*{*/
    begin
        raise_application_error(-20800, '* Error occured: ' || txt);
    end error;/*}*/

begin

  -- tq84_pck_1/*{*/

  select * into r_package from nd_package where package_name = 'TQ84_PCK_1';

  if r_package.declare_section is not null then
     raise_application_error(-20800, 'declare section is not null');
  end if;

  if r_package.invoker_right != 'CURRENT_USER' then
     raise_application_error(-20800, 'CURRENT_USER expected');
  end if;

  dbms_output.put_line('  pck 1 ok');

  /*}*/
  -- tq84_pck_2/*{*/

  select * into r_package from nd_package where package_name = 'TQ84_PCK_2';

  if r_package.declare_section is not null then
     raise_application_error(-20800, 'declare section is not null');
  end if;

  if r_package.invoker_right != 'DEFINER' then
     raise_application_error(-20800, 'DEFINER expected');
  end if;
  dbms_output.put_line('  pck 2 ok');

  /*}*/
  -- tq84_pck_3/*{*/
  select * into r_package from nd_package where package_name = 'TQ84_PCK_3';

  if r_package.declare_section is null then
     raise_application_error(-20800, 'declare section is null');
  end if;

  if r_package.invoker_right is not null then
     raise_application_error(-20800, 'null expected');
  end if;

  select * into r_declare_section from nd_declare_section where id = r_package.declare_section;

  declare
    cnt_items_1 number := 0;
    cnt_items_2 number := 0;
    r_item_declaration       nd_item_declaration       %rowtype;
    r_constant_declaratation nd_constant_declaration   %rowtype; -- TODO: typo.
    r_datatype               nd_datatype               %rowtype;
    r_scalar_datatype        nd_scalar_datatype        %rowtype;
    r_expression             nd_expression             %rowtype;
    r_term                   nd_term                   %rowtype;
    r_factor                 nd_factor                 %rowtype;
  begin
    for i in (select * from nd_item_elem_1 where item_list_1 = r_declare_section.item_list_1 order by item_declaration) loop/*{*/

           cnt_items_1 := cnt_items_1 + 1;

           select * into r_item_declaration       from nd_item_declaration     where id = i.item_declaration;

           select * into r_constant_declaratation from nd_constant_declaration where id = r_item_declaration.constant_declaration;

           select * into r_datatype               from nd_datatype             where id = r_constant_declaratation.datatype;
           select * into r_expression             from nd_expression           where id = r_constant_declaratation.expression;
           select * into r_scalar_datatype        from nd_scalar_datatype      where id = r_datatype.scalar_datatype;

           select * into r_term                   from nd_term                 where expression = r_expression.id;
           select * into r_factor                 from nd_factor               where term       = r_term.id;


           if     cnt_items_1 = 1 then/*{*/

                  if nvl(r_constant_declaratation.name, 'n/a') != 'C_FOO_3' then
                     raise_application_error(-20800, 'c_foo_3 expected');
                  end if;

                  if r_scalar_datatype.type_ != 'VARCHAR2' then
                     raise_application_error(-20800, 'VARCHAR2 expected');
                  end if;

                  if nvl(r_scalar_datatype.size_, -9) != 20 then
                    raise_application_error(-20800, 'size 20 expected');
                  end if;

                  if r_scalar_datatype.precision is not null then
                     raise_application_error(-20800, 'precision null expected');
                  end if;

                  if r_factor.sign_ is not null then
                     raise_application_error(-20800, 'null sign expected');
                  end if;

                  if nvl(r_factor.string_, 'x') != '''A constant''' then
                     raise_application_error(-20800, 'A constant expected');
                  end if;
           /*}*/
           elsif  cnt_items_1 = 2 then/*{*/

                  if nvl(r_constant_declaratation.name, 'n/a') != 'C_BAR_3' then
                     raise_application_error(-20800, 'c_foo_3 expected');
                  end if;

                  if r_scalar_datatype.type_ != 'VARCHAR2' then
                    raise_application_error(-20800, 'VARCHAR2 expected');
                  end if;

                  if nvl(r_scalar_datatype.size_, -9) != 40 then
                    raise_application_error(-20800, 'size 40 expected');
                  end if;

                  if r_scalar_datatype.precision is not null then
                     raise_application_error(-20800, 'precision null expected');
                  end if;

                  if r_factor.sign_ is not null then
                     raise_application_error(-20800, 'null sign expected');
                  end if;

                  if nvl(r_factor.string_, 'x') != '''Another constant''' then
                     raise_application_error(-20800, 'Another constant');
                  end if;
           /*}*/
           elsif  cnt_items_1 = 3 then/*{*/

                  if nvl(r_constant_declaratation.name, 'n/a') != 'C_NUM_3' then
                     raise_application_error(-20800, 'c_foo_3 expected');
                  end if;

                  if r_scalar_datatype.type_ != 'NUMBER' then
                     raise_application_error(-20800, 'NUMBER expected');
                  end if;

                  if nvl(r_scalar_datatype.size_,-9) != -9 then
                     raise_application_error(-20800, 'size null expected');
                  end if;

                  if nvl(r_scalar_datatype.precision,-9) != -9 then
                     raise_application_error(-20800, 'precision null expected');
                  end if;

                  if r_factor.sign_ is null then
                     raise_application_error(-20800, 'not null sign expected');
                  end if;

                  if r_factor.sign_ != '-' then
                     raise_application_error(-20800, '- sign expected');
                  end if;

                  if nvl(r_factor.num_flt, 'x') != '42' then
                     raise_application_error(-20800, '42 expected');
                  end if;
           /*}*/
           elsif  cnt_items_1 = 4 then/*{*/

                  if nvl(r_constant_declaratation.name, 'n/a') != 'C_FLT_3' then
                     raise_application_error(-20800, 'c_foo_3 expected');
                  end if;

                  if r_scalar_datatype.type_ != 'NUMBER' then
                     raise_application_error(-20800, 'NUMBER expected');
                  end if;

                  if nvl(r_scalar_datatype.size_,-9) != 5 then
                     raise_application_error(-20800, 'size 5 expected');
                  end if;

                  if nvl(r_scalar_datatype.precision,-9) != 2 then
                     raise_application_error(-20800, 'precision 2 expected');
                  end if;

                  if r_factor.sign_ is not null then
                     raise_application_error(-20800, 'null sign expected');
                  end if;

                  if nvl(r_factor.num_flt, 'x') != '22.8' then
                     raise_application_error(-20800, '22.8 expected');
                  end if;
           /*}*/
           elsif  cnt_items_1 = 5 then/*{*/


                  if nvl(r_constant_declaratation.name, 'n/a') != 'C_DAT_3' then
                     raise_application_error(-20800, 'c_foo_3 expected');
                  end if;

                  if r_scalar_datatype.type_ != 'DATE' then
                     raise_application_error(-20800, 'DATE expected');
                  end if;

                  if nvl(r_scalar_datatype.size_,-9) != -9 then
                     raise_application_error(-20800, 'size null expected');
                  end if;

                  if nvl(r_scalar_datatype.precision,-9) != -9 then
                     raise_application_error(-20800, 'precision null expected');
                  end if;

                  if r_factor.sign_ is not null then
                     raise_application_error(-20800, 'null sign expected');
                  end if;
                  
                  check_complex_plsql_id(r_factor.complex_plsql_ident, 'TO_DATE', null, null);

--
-- TODO: This is now a complex_plsql_ident
--
--                  declare /*{*/
--                      r_expression_ nd_expression%rowtype;
--                      r_term_       nd_term      %rowtype;
--                      r_factor_     nd_factor    %rowtype;
--                      cnt_          number := 0;
--                  begin
--
--                  for param_elem in (select * from nd_parameter_elem where parameter_list = r_function_expression.parameter_list order by expression) loop/*{*/
--
--                      cnt_ := cnt_+1;
--
--                      select * into r_expression_ from nd_expression where id         = param_elem.expression;
--                      select * into r_term_       from nd_term       where expression = r_expression_.id;
--                      select * into r_factor_     from nd_factor     where term       = r_term_.id;
--
--                      if    cnt_ = 1 then/*{*/
--
--                            if nvl(r_factor_.string_, 'x') != '''20.10.2010''' then
--                               raise_application_error(-20800, '20.10.2010 expected, but gotten: ' || r_factor_.string_ || ', r_term_.id=' || r_term_.id);
--                            end if;
--                      /*}*/
--                      elsif cnt_ = 2 then/*{*/
--
--                            if nvl(r_factor_.string_, 'x') != '''dd.mm.yyyy''' then
--                               raise_application_error(-20800, 'dd.mm.yyyy expected');
--                            end if;
--
--                      end if;/*}*/
--
--                  end loop;/*}*/
--
--                  if cnt_ != 2 then
--                     raise_application_error(-20800,'cnt_=2 expected, but is ' || cnt_ || ', r_function_expression.id=' || r_function_expression.id);
--                  end if;
--
--                  end;/*}*/

           /*}*/
           elsif  cnt_items_1 = 6 then/*{*/


                  if nvl(r_constant_declaratation.name, 'n/a') != 'C_CHR_2' then
                     raise_application_error(-20800, 'C_CHR_2 expected');
                  end if;

                  if r_scalar_datatype.type_ != 'CHAR' then
                     raise_application_error(-20800, 'CHAR expected');
                  end if;

                  if nvl(r_scalar_datatype.size_,-9) != 2 then
                     raise_application_error(-20800, 'size 2 expected');
                  end if;

                  if nvl(r_scalar_datatype.precision,-9) != -9 then
                     raise_application_error(-20800, 'precision null expected');
                  end if;

                  if r_factor.sign_ is not null then
                     raise_application_error(-20800, 'null sign expected');
                  end if;

           /*}*/
           else /*{*/
                  
                  raise_application_error(-20800, 'unknown cnt_items_1');

           end if;/*}*/


    end loop;/*}*/

    if cnt_items_1 != 6 then
       raise_application_error(-20800, 'cnt_items_1 != 6, but ' || cnt_items_1);
    end if;

    dbms_output.put_line('  pck 3 ok');

  end;
  /*}*/
  -- tq84_pck_4/*{*/

  declare /*{*/
    cnt_declare_items_1 number := 0;
    cnt_declare_items_2 number := 0;
    cnt_argument      number;

    r_datatype              nd_datatype        %rowtype;
    r_scalara_datatype      nd_scalar_datatype %rowtype;
    r_typename              nd_plsql_identifier%rowtype;


    id_parameter_declaration_list number;

    check_3_done            boolean := false;/*{*/
--  check_datatype_done     boolean := false;
    check_p1_done           boolean := false;
    check_p2_done           boolean := false;
    check_arg_1_done        boolean := false;
    check_arg_2_done        boolean := false;
    check_arg_5_done        boolean := false;
    check_arg_5_null_done   boolean := false;
--  check_0_args_5          boolean := false;
    check_f5_pck4_done      boolean := false;
    check_name_f1           boolean := false;
    check_name_f2           boolean := false;
    check_name_f3           boolean := false;
    check_c_flt             boolean := false;/*}*/

  /*}*/
  begin/*{*/

    select * into r_package from nd_package where package_name = 'TQ84_PCK_4';
  
    select * into r_declare_section from nd_declare_section where id = r_package.declare_section;
  
    for item_elem_1 in (select * from nd_item_elem_1 where item_list_1 = r_declare_section.item_list_1 /*{*/
                         order by coalesce(item_declaration, cursor_declaration, cursor_definition, function_declaration, procedure_declaration, type_definition, pragma_)
                       ) loop
        
        cnt_declare_items_1 := cnt_declare_items_1 + 1;

        if cnt_declare_items_1 > 15 then 
           error('expected 15, but actual: ' || cnt_declare_items_1);
        end if;
  
        if     cnt_declare_items_1 in(1,2,3,4,5,6) then/*{  Functions and Procedures*/ 

               if     cnt_declare_items_1 in (1, 3, 6) then/*{ Functions */
  
                      select * into r_function_declaration from nd_function_declaration where id = item_elem_1           .function_declaration;
                      select * into r_function_heading     from nd_function_heading     where id = r_function_declaration.function_heading;

                      id_parameter_declaration_list := r_function_heading.parameter_declaration_list;
  
                      if r_function_declaration.deterministic_   is not null or
                         r_function_declaration.pipelined_       is not null or
                         r_function_declaration.parallel_enable_ is not null or
                         r_function_declaration.result_cache_    is not null then
    
                         raise_application_error(-20800, 'deterministic_ or something is not null');
    
                      end if;

                      select * into r_datatype_returned from nd_datatype         where id = r_function_heading .datatype_returned;
    
                      if    cnt_declare_items_1 = 1 then/*{*/
                            if r_function_heading.name != 'F1_PCK4' then
                               raise_application_error(-20800, 'Name F1_PCK4 expected');
                            end if;
                            check_name_f1 := true;

                            select * into r_scalar_datatype   from nd_scalar_datatype  where id = r_datatype_returned.scalar_datatype;
    
                            if r_scalar_datatype.type_ != 'NUMBER' then 
                               raise_application_error(-20800, 'Datatype NUMBER expected');
                            end if;
    
                            if r_scalar_datatype.size_               is not null or
                               r_scalar_datatype.precision           is not null or
                               r_scalar_datatype.char_byte_semantics is not null then
    
                               raise_application_error(-20800, 'Precision not expected');
    
                            end if;
                      /*}*/
                      elsif cnt_declare_items_1 = 3 then/*{*/


                            if r_function_heading.name != 'F2_PCK4' then
                               raise_application_error(-20800, 'Name F2_PCK4 expected');
                            end if;
                            check_name_f2 := true;

                            check_plsql_identifier(r_datatype_returned.typename_plsql_identifier, 'TQ84_PCK_4_TABLE', 'COL_1', null);

                            if nvl(r_datatype_returned.rowtype_, -1) != -1 then
                               error('rowtype_ is not null');
                            end if;

                            if nvl(r_datatype_returned.type_, -1) != 1 then
                               error('type_ is not set');
                            end if;


                            check_3_done := true;
                      /*}*/
                      elsif cnt_declare_items_1 = 6 then/*{*/
  
                            if r_function_heading.name != 'F3_PCK4' then
                               raise_application_error(-20800, 'Name F3 expected');
                            end if;
                            check_name_f3 := true;

                            select * into r_typename from nd_plsql_identifier where id = r_datatype_returned.typename_plsql_identifier;

                            check_plsql_identifier(r_typename, 'TQ84_PCK_4_TYPE', null, null);

--                          check_datatype_done := true;
                      end if;/*}*/
  
  
                      if cnt_declare_items_1 = 3 then
                         if r_function_heading.parameter_declaration_list is not null then
                            raise_application_error(-20800, 'No parameter declaration expected');
                         end if;
                      end if;
  
  
               /*}*/
               elsif  cnt_declare_items_1 in (2, 4, 5) then/*{ Procedure */


                      select * into r_procedure_declaration from nd_procedure_declaration where id = item_elem_1             . procedure_declaration;
                      select * into r_procedure_heading     from nd_procedure_heading     where id = r_procedure_declaration . procedure_heading;

                      id_parameter_declaration_list := r_procedure_heading.parameter_declaration_list;
  
                      if cnt_declare_items_1 = 2 then
                         if r_procedure_heading.name != 'P1_PCK4' then 
                            raise_application_error(-20800, 'Name P1_PCK4 expected');
                         end if;
                         check_p1_done := true;
                      end if;
  
                      if cnt_declare_items_1 = 4 then
                         if r_procedure_heading.name != 'P2_PCK4' then 
                            raise_application_error(-20800, 'Name P2_PCK4 expected');
                         end if;
                         check_p2_done := true;
                      end if;

                      if cnt_declare_items_1 = 5 then
                         if r_procedure_heading.name != 'P3_PCK4' then 
                            raise_application_error(-20800, 'Name P3_PCK4 expected');
                         end if;
                      end if;
  
               end if; /*}*/
  
               cnt_argument := 0;
               for param in (select * from nd_parameter_declaration where parameter_declaration_list = id_parameter_declaration_list order by id) loop/*{*/
                   cnt_argument := cnt_argument + 1;

                   select * into r_datatype from nd_datatype where id = param.datatype;
  
                   if      cnt_declare_items_1 = 1 then/*{*/

                           select * into r_scalar_datatype from nd_scalar_datatype where id = r_datatype.scalar_datatype;
  
                           if     cnt_argument = 1 then/*{*/

                                  if nvl(param.default_, -1) != -1 then
                                     raise_application_error(-20800, 'default_ != -1');
                                  end if;

                                  if nvl(param.in_, -999) != 1 then 
                                     raise_application_error(-20800, 'param.in_');
                                  end if;

                                  if nvl(param.out_, -99) != -99 then
                                     raise_application_error(-20800, 'non-out expected');
                                  end if;
  
                                  if param.name != 'ARG3' then
                                     raise_application_error(-20800, 'ARG3 expected');
                                  end if;

                                  if nvl(r_scalar_datatype.type_, 'n/a') != 'VARCHAR2' then
                                     raise_application_error(-20800, 'VARCHAR2 expected');
                                  end if;

                           /*}*/
                           else/*{*/
                               raise_application_error(-20800, 'F1_PCK4 has only 1 argument');
                           end if;/*}*/
                   /*}*/
                   elsif   cnt_declare_items_1 = 2 then/*{*/

                           if nvl(param.default_, -1) != -1 then
                              raise_application_error(-20800, 'default_ != -1');
                           end if;

                           select * into r_scalar_datatype from nd_scalar_datatype where id = r_datatype.scalar_datatype;
    
                           if     cnt_argument = 1 then/*{*/

                                  if nvl(param.in_, -1) != 1 then
                                     raise_application_error(-20800, 'in expected');
                                  end if;

                                  if nvl(param.out_, -1) != 1 then
                                     raise_application_error(-20800, 'out expected');
                                  end if;
  
                                  if param.name != 'ARG1' then
                                     raise_application_error(-20800, 'ARG1 expected');
                                  end if;

                                  if nvl(r_scalar_datatype.type_, 'n/a') != 'NUMBER' then
                                     raise_application_error(-20800, 'NUMBER expected');
                                  end if;

                                  check_arg_1_done := true;
                           /*}*/
                           elsif  cnt_argument = 2 then/*{*/

                                  if nvl(param.in_, -1) != -1 then
                                     raise_application_error(-20800, 'in expected');
                                  end if;

                                  if nvl(param.out_, -1) != 1 then
                                     raise_application_error(-20800, 'out expected');
                                  end if;

                                  if nvl(param.nocopy_, -1) != -1 then
                                     raise_application_error(-20800, 'no nocopy expected');
                                  end if;
  
                                  if param.name != 'ARG2' then
                                     raise_application_error(-20800, 'ARG2 expected');
                                  end if;

                                  if nvl(r_scalar_datatype.type_, 'n/a') != 'DATE' then
                                     raise_application_error(-20800, 'VARCHAR2 expected');
                                  end if;

                                  check_arg_2_done := true;
                           /*}*/
                           else/*{*/
                                  raise_application_error(-20800, 'P1_PCK4 has only 2 arguments');
  
  
                           end if;/*}*/
  
                   /*}*/
                   elsif   cnt_declare_items_1 = 4 then/*{*/

                   --      procedure p2_pck4 (arg5 number default null, arg_5_1 tq84_pck_4_type default tq84_pck_4_type());

  
                           if       cnt_argument = 1 then/*{*/

                                    select * into r_scalar_datatype from nd_scalar_datatype where id = r_datatype.scalar_datatype;
  
                                    if param.name != 'ARG5' then
                                       raise_application_error(-20800,'ARG5 expected');
                                    end if;
  
                                    check_arg_5_done := true;
  
                                    if nvl(param.in_, -8) != -8 then
                                       raise_application_error(-20800, 'no in expected');
                                    end if;

                                    if nvl(param.out_, -8) != -8 then
                                       raise_application_error(-20800, 'no out expected');
                                    end if;
  
                                    if nvl(param.default_, -1) != 1 then
                                       raise_application_error(-20800, 'default_ != -1');
                                    end if;
  
                                    select * into r_expression         from nd_expression         where id = param.expression;
                                    select * into r_term               from nd_term               where expression = r_expression.id;
                                    select * into r_factor             from nd_factor             where term       = r_term      .id;

                                    if nvl(r_factor.null_,-1) != 1 then
                                       raise_application_error(-20800, 'NULL expected, expression: ' || r_expression.id);
                                    end if;
  
                                    check_arg_5_null_done := true;
                           /*}*/
                           elsif    cnt_argument = 2 then/*{*/

                                    null;

                                    -- TODO: check 2nd argument of p2_pck4 
                                    --            arg_5_1 tq84_pck_4_type default tq84_pck_4_type()
                                    --

                           /*}*/
                           else/*{*/
                             
                                    raise_application_error(-20800, 'Has only two argument.');
  
                           end if;/*}*/

  
                   end if;/*}*/

                   if cnt_declare_items_1 = 3 then/*{*/
                      raise_application_error(-20800, 'No arguments for F2_PCK4 expected');
                   end if;/*}*/

                   if cnt_declare_items_1 = 5  then/*{*/
                      raise_application_error(-20800, 'No arguments for F2_PCK4 expected');
--                    check_0_args_5 := true;
                   end if;/*}*/
  
               end loop;/*}*/
          
        /*}*/
        elsif  cnt_declare_items_1 = 7 then/*{ constant number declaration */

               select * into r_item_declaration      from nd_item_declaration      where id = item_elem_1.item_declaration;
               select * into r_constant_declaration  from nd_constant_declaration  where id = r_item_declaration     .constant_declaration;
               select * into r_expression            from nd_expression            where id = r_constant_declaration .expression;
               select * into r_term                  from nd_term                  where expression = r_expression.id;
               select * into r_factor                from nd_factor                where term       = r_term      .id;

--             check_plsql_identifier(r_plsql_identifier, 'TQ84_PCK_3', 'C_FLT_3', null);
               check_complex_plsql_id(r_factor.complex_plsql_ident, 'TQ84_PCK_3', 'C_FLT_3', null);

               check_c_flt := true;

        /*}*/
        elsif  cnt_declare_items_1 = 8 then/*{*/
               select * into r_cursor_definition from nd_cursor_definition where id = item_elem_1.cursor_definition;

               if r_cursor_definition.name != 'CUR_PCK4' then
                  raise_application_error(-20800, 'Name CUR_PCK4 expected');
               end if;

               select * into r_select_statement from nd_select_statement where id = r_cursor_definition.select_statement;
               select * into r_subquery         from nd_subquery         where id = r_select_statement .subquery;
               select * into r_query_block      from nd_query_block      where id = (select query_block from nd_subquery_elem where subquery =  r_subquery.id);

               if nvl(r_query_block.hint , '???') != '/*+ hint */' then /*{*/
                  raise_application_error(-20800, 'hint expected');
               end if;/*}*/

               declare /*{*/
                 cnt_select_elems number := 0;
                 cnt_from_elems   number := 0;
               begin
                 
                 for select_elem in (select * from nd_select_elem where select_list = r_query_block.select_list order by expression) loop/*{*/
                     cnt_select_elems := cnt_select_elems + 1;
                     select * into r_expression        from nd_expression        where id = select_elem        .expression;
                     select * into r_term              from nd_term              where expression  = r_expression.id;
                     select * into r_factor            from nd_factor            where term        = r_term      .id;

                     check_complex_plsql_id(r_factor.complex_plsql_ident, 'COL_1', null, null);

                 end loop;/*}*/

                 if cnt_select_elems != 1 then/*{*/
                    raise_application_error(-20800, 'cnt_select_elems != 1: ' || cnt_select_elems);
                 end if;/*}*/

                 for from_elem in (select * from nd_from_elem where from_list = r_query_block.from_list) loop/*{*/
                     cnt_from_elems := cnt_from_elems + 1;

                     select * into r_table_reference        from nd_table_reference        where id = from_elem        .table_reference;
                     select * into r_query_table_expression from nd_query_table_expression where id = r_table_reference.query_table_expression;
                     select * into r_plsql_identifier       from nd_plsql_identifier       where id = r_query_table_expression.name_;

                     if nvl(r_plsql_identifier.identifier_1,'?') != 'TQ84_PCK_4_TABLE' then
                        raise_application_error(-20800, 'COL_1 expected');
                     end if;

                     if nvl(r_plsql_identifier.identifier_2,'?') != '?' then
                        raise_application_error(-20800, 'identifier_2 is not null');
                     end if;

                     if nvl(r_plsql_identifier.identifier_3,'?') != '?' then
                        raise_application_error(-20800, 'identifier_3 is not null');
                     end if;
                end loop;/*}*/

                if cnt_from_elems != 1 then/*{*/
                   raise_application_error(-20800, 'cnt_from_elems != 1 : ' || cnt_from_elems);
                end if;/*}*/

              end;/*}*/

        /*}*/
        elsif  cnt_declare_items_1 = 9 then/*{*/

               select * into r_function_declaration from nd_function_declaration where id = item_elem_1.function_declaration;
               select * into r_function_heading     from nd_function_heading     where id = r_function_declaration.function_heading;

               if r_function_heading.name != 'F5_PCK4' then
                  raise_application_error(-20800, 'F5_PCK4 expected');
               end if;

               cnt_argument := 0;
               for param in (select * from nd_parameter_declaration where parameter_declaration_list = r_function_heading.parameter_declaration_list order by id) loop
                   cnt_argument := cnt_argument + 1;

                   if cnt_argument != 1 then
                      raise_application_error(-20800, 'Only one argument for f5_pck4 expected');
                   end if;

                   if param.name != 'ARG6' then
                      raise_application_error(-20800,'ARG6 expected');
                   end if;
  
                   if nvl(param.in_, -8) != 1 then
                      raise_application_error(-20800, 'in expected');
                   end if;

                   if nvl(param.out_, -8) != 1 then
                      raise_application_error(-20800, 'out expected');
                   end if;
  
                   if nvl(param.default_, -1) != -1 then
                      raise_application_error(-20800, 'no default_ expected');
                   end if;

               end loop;

               check_f5_pck4_done := true;
        /*}*/
        elsif  cnt_declare_items_1 = 10 then /*{ cursor declaration */
  
               -- TODO Finish me!
               null;
        /*}*/
        elsif  cnt_declare_items_1 = 11 then/*{*/
        -- type table_of_type is table of sys.anydata; 
           declare /*{*/
             r_type_definition            nd_type_definition           %rowtype;
             r_collection_type_definition nd_collection_type_definition%rowtype;
             r_nested_table_type_def      nd_nested_table_type_def     %rowtype;
             r_datatype                   nd_datatype                  %rowtype;
           begin
             select * into r_type_definition            from nd_type_definition            where id = item_elem_1                 .type_definition;
             select * into r_collection_type_definition from nd_collection_type_definition where id = r_type_definition           .collection_type_definition;
             select * into r_nested_table_type_def      from nd_nested_table_type_def      where id = r_collection_type_definition.nested_table_type_def;
             select * into r_datatype                   from nd_datatype                   where id = r_nested_table_type_def     .datatype;

             check_plsql_identifier(r_datatype.typename_plsql_identifier, 'SYS', 'ANYDATA', NULL);

           end;/*}*/

        /*}*/
        elsif  cnt_declare_items_1 = 12 then /*{*/

           declare /*{*/
             r_type_definition            nd_type_definition           %rowtype;
             r_collection_type_definition nd_collection_type_definition%rowtype;
             r_nested_table_type_def      nd_nested_table_type_def     %rowtype;
             r_datatype                   nd_datatype                  %rowtype;
             r_scalar_datatype            nd_scalar_datatype           %rowtype;
           begin
             select * into r_type_definition            from nd_type_definition            where id = item_elem_1                 .type_definition;
             select * into r_collection_type_definition from nd_collection_type_definition where id = r_type_definition           .collection_type_definition;
             select * into r_nested_table_type_def      from nd_nested_table_type_def      where id = r_collection_type_definition.nested_table_type_def; 
             select * into r_datatype                   from nd_datatype                   where id = r_nested_table_type_def     .datatype;
             select * into r_scalar_datatype            from nd_scalar_datatype            where id = r_datatype                  .scalar_datatype;

             if nvl(r_collection_type_definition.name, '?') != 'TABLE_OF_NUMBER_5' then
                error('name TABLE_OF_NUMBER_5 expected');
             end if;

             if nvl(r_scalar_datatype.type_, '?') != 'NUMBER' then
                error('number expected');
             end if;

             if nvl(r_scalar_datatype.size_,-1) != 5 then
                error('5 expected');
             end if;

             if r_scalar_datatype.precision is not null then
                error('null precision expected');
             end if;

           end; /*}*/
           /*}*/
        elsif  cnt_declare_items_1 = 13 then /*{*/

           declare /*{*/
             r_type_definition            nd_type_definition           %rowtype;
             r_collection_type_definition nd_collection_type_definition%rowtype;
             r_assoc_array_type_def       nd_assoc_array_type_def      %rowtype;
             r_datatype                   nd_datatype                  %rowtype;
           begin
             select * into r_type_definition            from nd_type_definition            where id = item_elem_1                 .type_definition;
             select * into r_collection_type_definition from nd_collection_type_definition where id = r_type_definition           .collection_type_definition;
             select * into r_assoc_array_type_def       from nd_assoc_array_type_def       where id = r_collection_type_definition.assoc_array_type_def;
             select * into r_datatype                   from nd_datatype                   where id = r_assoc_array_type_def      .datatype;

             if nvl(r_collection_type_definition.name, '?') != 'TABLE_TYPE_TYPE_TYPE' then
                error('name TABLE_TYPE_TYPE_TYPE expected');
             end if;

             if nvl(r_datatype.rowtype_, -1) != -1 then
                error('rowtype_');
             end if;

             if nvl(r_datatype.type_,-1) != 1 then
                error('type_');
             end if;


           end; /*}*/

        /*}*/
        elsif  cnt_declare_items_1 = 14 then/*{*/
              declare 
                r_pragma                          nd_pragma                    %rowtype;
                r_restrict_references_pragma      nd_restrict_references_pragma%rowtype;
              begin

                select * into r_pragma                     from nd_pragma                     where id = item_elem_1.pragma_;
                select * into r_restrict_references_pragma from nd_restrict_references_pragma where id = r_pragma.restrict_references_pragma;

                  if nvl(r_restrict_references_pragma.subprogram_method, 'n/a') != 'F3_PCK4' then
                     error('subprogram_method != F3_PCK4, but ' || r_restrict_references_pragma.subprogram_method);
                  end if;

                if nvl(r_restrict_references_pragma.wnds_, -99999) != 1 then
                   error('wnds_');
                end if;

                if nvl(r_restrict_references_pragma.wnps_, -99999) != 1 then
                   error('wnps_');
                end if;

                if nvl(r_restrict_references_pragma.rnds_, -99999) != -99999 then
                   error('rnds_');
                end if;
              end;
        /*}*/
        elsif  cnt_declare_items_1 = 15 then/*{*/
               null; -- TODO: finish me.
        end if;/*}*/
  
    end loop;/*}*/

    /*{  Checks for item_elem_1: */ 
    if cnt_declare_items_1 != 15 then
       raise_application_error(-20800, 'cnt_declare_items_1: ' || cnt_declare_items_1 || ', r_declare_section.item_list_1: ' || r_declare_section.item_list_1);
    end if;

    if not check_name_f1 then
       raise_application_error(-20800, 'check_name_f1');
    end if;

    if not check_name_f2 then
       raise_application_error(-20800, 'check_name_f2');
    end if;

    if not check_name_f3 then
       raise_application_error(-20800, 'check_name_f3');
    end if;

    if not check_c_flt then
       raise_application_error(-20800, 'check_c_flt');
    end if;

    if not check_arg_1_done then
       raise_application_error(-20800, 'check_arg_1_done');
    end if;

    if not check_arg_2_done then
       raise_application_error(-20800, 'check_arg_2_done');
    end if;

    if not check_p1_done then
       raise_application_error(-20800, 'check_p1_done');
    end if;

    if not check_p2_done then
       raise_application_error(-20800, 'check_p2_done');
    end if;

    if not check_3_done then
       raise_application_error(-20800, 'check_3_done');
    end if;

--  if not check_datatype_done then
--     raise_application_error(-20800, 'check_datatype_done');
--  end if;

    if not check_arg_5_done then
       raise_application_error(-20800, 'check_arg_5_done');
    end if;

    if not check_arg_5_null_done then
       raise_application_error(-20800, 'check_arg_5_null_done');
    end if;


--  if not check_0_args_5 then
--     raise_application_error(-20800, 'check_0_args_5');
--  end if;

    /*}*/

   -- Items 2/*{*/


    if not check_f5_pck4_done then
       raise_application_error(-20800, 'check_f5_pck4_done');
    end if;

    if cnt_declare_items_2 != 0 then
       raise_application_error(-20800, 'cnt_declare_items_2: ' || cnt_declare_items_2);
    end if;

    /*}*/

  end; /*}*/


  dbms_output.put_line('  pck 4 ok');

  /*}*/
  -- tq84_pck_5/*{*/
  declare/*{*/
   
    cnt_item           number := 0;
    cnt_select_elem    number := 0; 
    cnt_parameter_elem number := 0;
    cnt_param_decl     number := 0;
    r_from_elem        nd_from_elem%rowtype;
    r_table_reference  nd_table_reference%rowtype;
    r_select_elem      nd_select_elem%rowtype;
    r_where_clause     nd_where_clause%rowtype;
    r_relation         nd_relation%rowtype;
    r_condition        nd_condition%rowtype;
--  r_expression_1     nd_expression%rowtype;
--  r_expression_2     nd_expression%rowtype;
   
    r_term             nd_term%rowtype;
    r_factor           nd_factor%rowtype;

    r_aggregate_function nd_aggregate_function%rowtype;
    r_analytic_clause    nd_analytic_clause%rowtype;

    cnt_logical_term   number := 0;
    cnt_logical_factor number;

    procedure check_simple_factor(id_expression in nd_expression.id%type, plsql_identifier in varchar2) is/*{*/
      r_term     nd_term    %rowtype;
      r_factor   nd_factor  %rowtype;
    begin

        select * into r_term   from nd_term   where expression = id_expression;
        select * into r_factor from nd_factor where term       = r_term.id;

        if r_factor.sign_ is not null then
           raise_application_error(-20800, 'sign_ is not null');
        end if;

        if r_factor.mulop is not null then
           raise_application_error(-20800, 'mulop is not null');
        end if;

        if r_factor.function_expression is not null then
           raise_application_error(-20800, 'function_expression is not null');
        end if;

        check_complex_plsql_id(r_factor.complex_plsql_ident, plsql_identifier, null, null);

    end check_simple_factor;/*}*/

    procedure check_simple_relation(id in nd_relation.id%type, plsql_identifier_1 in varchar2, relop in varchar2, plsql_identifier_2 in varchar2) is/*{*/

      r_relation nd_relation%rowtype;
      
    begin

        select * into r_relation from nd_relation where check_simple_relation.id = nd_relation.id;

        if nvl(r_relation.relop, '?') != relop then
           raise_application_error(-20800, 'relop = expected, but was: ' || relop);
        end if;

        check_simple_factor(r_relation.expression_1, plsql_identifier_1);
        check_simple_factor(r_relation.expression_2, plsql_identifier_2);

    end check_simple_relation;/*}*/

  /*}*/
  begin/*{*/

    select * into r_package         from nd_package         where package_name = 'tq84_pck_5';
    select * into r_declare_section from nd_declare_section where id = r_package.declare_section;

    if r_declare_section.item_list_1 is null then
       raise_application_error(-20800, 'item_list 1 is not null');
    end if;

    for item_elem_1 in (/*{*/
        select * from nd_item_elem_1 where item_list_1 = r_declare_section.item_list_1 order by cursor_definition
    ) loop

      cnt_item := cnt_item + 1;

      select * into r_cursor_definition from nd_cursor_definition where id          = item_elem_1.cursor_definition;

      if    cnt_item = 1 then/*{ "cur_5"  */
    
        if nvl(r_cursor_definition.name, '?') != 'cur_5' then
           raise_application_error(-20800, 'cur_5 expected');
        end if;
    
        select * into r_select_statement from nd_select_statement where id = r_cursor_definition.select_statement;
        select * into r_subquery         from nd_subquery         where id = r_select_statement .subquery;
        select * into r_query_block      from nd_query_block      where id = (select query_block from nd_subquery_elem where subquery =  r_subquery.id);

        declare
          r_for_udpate_clause     nd_for_update_clause    %rowtype;
          r_plsql_identifier_list nd_plsql_identifier_list%rowtype;
          r_plsql_identifier_elem nd_plsql_identifier_elem%rowtype;
        begin
          select * into r_for_udpate_clause     from nd_for_update_clause      where id = r_select_statement.for_update_clause;
          select * into r_plsql_identifier_list from nd_plsql_identifier_list  where id = r_for_udpate_clause.plsql_identifier_list;
          select * into r_plsql_identifier_elem from nd_plsql_identifier_elem  where plsql_identifier_list = r_plsql_identifier_list.id;
          check_plsql_identifier(r_plsql_identifier_elem.plsql_identifier, 'col_1', null, null);
        end;
        
    
        for select_elem in (select * from nd_select_elem where select_list = r_query_block.select_list /*{*/
                            order by /*coalesce(*//*plsql_identifier,*/ expression /*, function_expression*//*)*/ ) loop
    
            cnt_select_elem := cnt_select_elem + 1;

            select * into r_term from nd_term where expression = select_elem.expression;
            select * into r_factor from nd_factor where term = r_term.id;
    
            if     cnt_select_elem = 1 then/*{*/
                   check_complex_plsql_id(r_factor.complex_plsql_ident, 'T5', 'col_1', null);
    
            /*}*/
            elsif  cnt_select_elem = 2 then/*{*/

                   check_complex_plsql_id(r_factor.complex_plsql_ident, 'SUBSTR', null, null);

                   for parameter_elem in ( -- {
    
                       select * from nd_parameter_elem where parameter_list in (select paran_parameter_list from nd_complex_plsql_ident_elem where complex_plsql_ident = r_factor.complex_plsql_ident)/*r_function_expression.parameter_list */
                         order by expression
    
                   ) loop
    
                     cnt_parameter_elem := cnt_parameter_elem + 1;

                     if parameter_elem.name is not null then 
                        raise_application_error(-20800, 'parameter_elem.name: ' || parameter_elem.name);
                     end if;
    
                     select * into r_expression            from nd_expression where id = parameter_elem. expression;
                     select * into r_term                  from nd_term       where expression = r_expression.id;
                     select * into r_factor                from nd_factor     where term       = r_term.id;
    
                     if     cnt_parameter_elem = 1 then/*{*/
                      
                            check_complex_plsql_id(r_factor.complex_plsql_ident, 'T5', 'col_2', null);
                       
                     /*}*/
                     elsif  cnt_parameter_elem = 2 then/*{*/
    
                            if nvl(r_factor.num_flt, 'n/a') != '4' then
                               raise_application_error(-20800, '!= 4');
                            end if;
    
                      /*}*/
                     elsif  cnt_parameter_elem = 3 then/*{*/
    
                            if nvl(r_factor.num_flt, 'n/a') != '2' then
                               raise_application_error(-20800, '!= 2');
                            end if;
                      /*}*/
                     else   raise_application_error(-20800, 'cnt_parameter_elem: ' || cnt_parameter_elem);/*{*/
                     end if;/*}*/
    
                   end loop; -- }
    
                   if cnt_parameter_elem != 3 then
                      raise_application_error(-20800, 'cnt_parameter_elem: ' || cnt_parameter_elem);
                   end if;

            /*}*/
            else/*{*/
                   raise_application_error(-20800, 'cnt_select_elem: ' || cnt_select_elem);
            end if;/*}*/
    
        end loop;/*}*/

      /*}*/
      elsif cnt_item = 2 then/*{  cur_5_1 */

         if nvl(r_cursor_definition.name, '?') != 'CUR_5_1' then
            raise_application_error(-20800, 'CUR_5_1 expected');
         end if;

         for param_decl in (/*{*/
             select * from nd_parameter_declaration where parameter_declaration_list = r_cursor_definition.parameter_declaration_list order by id
         ) loop
             cnt_param_decl := cnt_param_decl + 1;

             if      cnt_param_decl = 1 then/*{*/

                     if nvl(param_decl.name,'?') != 'P_1' then
                        raise_application_error(-20800, 'P_1 expected');
                     end if;
             /*}*/
             elsif   cnt_param_decl = 2 then/*{*/

                     if nvl(param_decl.name,'?') != 'P_2' then
                        raise_application_error(-20800, 'P_2 expected');
                     end if;
             /*}*/
             elsif   cnt_param_decl = 3 then/*{*/

                     if nvl(param_decl.name,'?') != 'P_3' then
                        raise_application_error(-20800, 'P_3 expected');
                     end if;
             /*}*/
             else/*{*/
                     raise_application_error(-20800, 'cnt_param_decl');
             end if;/*}*/

         end loop;/*}*/

         if cnt_param_decl != 3 then
            raise_application_error(-20800, 'cnt_param_decl != 3');
         end if;

         select * into r_select_statement from nd_select_statement where id = r_cursor_definition.select_statement;
         select * into r_subquery         from nd_subquery         where id = r_select_statement.subquery;
--       select * into r_query_block      from nd_query_block      where id = r_subquery.query_block;
         select * into r_query_block      from nd_query_block      where id = (select query_block from nd_subquery_elem where subquery =  r_subquery.id);

         select * into r_from_elem              from nd_from_elem              where from_list = r_query_block.from_list;
         select * into r_table_reference        from nd_table_reference        where id = r_from_elem.table_reference;
         select * into r_query_table_expression from nd_query_table_expression where id = r_table_reference.query_table_expression;
         select * into r_plsql_identifier       from nd_plsql_identifier       where id = r_query_table_expression.name_;
         check_plsql_identifier(r_plsql_identifier, 'tq84_pck_5_table', null, null);

         select * into r_select_elem      from nd_select_elem      where select_list = r_query_block.select_list;
         select * into r_expression       from nd_expression       where id          = r_select_elem.expression;
         select * into r_term             from nd_term             where expression  = r_expression .id;
         select * into r_factor           from nd_factor           where term        = r_term       .id;
         check_complex_plsql_id(r_factor.complex_plsql_ident, '*', null, null);
    

         select * into r_where_clause from nd_where_clause where id = r_query_block.where_clause;

         select * into r_condition from nd_condition where id = r_where_clause.condition;

         for logical_term in (select * from nd_logical_term where logical_term_list = r_condition.logical_term_list order by logical_factor_list) loop/*{*/

             cnt_logical_term   := cnt_logical_term + 1;
             cnt_logical_factor := 0;

             for logical_factor in (select *  from nd_logical_factor where logical_factor_list = logical_term.logical_factor_list order by coalesce(relation, condition)) loop/*{*/
                 cnt_logical_factor := cnt_logical_factor + 1;

                 if cnt_logical_term = 2 and cnt_logical_factor = 6 then/*{*/
                    -- The 6th logical factor is a condition, not a relation.
                    select * into r_condition from nd_condition where id = logical_factor.condition;

                    -- The condition consists of two logical terms (connected by ORs):
                    --                               (2+3)/4 > 9/(8+1) or
                    --                               (5)+(9*4) <= (8/3)+2

                    for logical_term in (/*{*/

                        select count(*) over (order by logical_factor_list) cnt, nd_logical_term.* from nd_logical_term where logical_term_list = r_condition.logical_term_list

                    ) loop

                      declare/*{*/
                      -- Both logical terms consist each of one logical factor which in turn
                      -- consists of (or better: is) one relation.
                         r_logical_factor_ nd_logical_factor%rowtype;
                         r_relation_       nd_relation      %rowtype;
                         r_term_           nd_term          %rowtype;
                      begin

                         select * into r_logical_factor_ from nd_logical_factor where logical_factor_list = logical_term.logical_factor_list;
                         select * into r_relation_       from nd_relation       where id                  = r_logical_factor_.relation;

                         if     logical_term.cnt = 1 then/*{*/

                             -- (2+3)/4 > 9/(8+1) or
                                
                                if r_relation_.relop != '>' then
                                   error('relop > expected');
                                end if;

                             -- (2+3)/4 is a term...

                                select * into r_term_ from nd_term where expression = r_relation_.expression_1;

                             -- ...consisting of two factors

                                declare factor_checked boolean := false; begin/*{*/

                                for factor in (

                                    select count(*) over (order by id) cnt, nd_factor.* from nd_factor where term = r_term_.id

                                ) loop
                                   

                                   if    factor.cnt = 1 then --    The first factor is (2+3)/*{*/

                                         if nvl(factor.mulop, 'n/a') != 'n/a' then
                                            error('mulop: ' || factor.mulop);
                                         end if;

                                         declare 
                                           term_checked boolean := false; 

                                           r_factor___ nd_factor%rowtype;
                                         begin
                                         for term in (
                                             select count(*) over (order by id) cnt, nd_term.* from nd_term where expression = factor.expression


                                         ) loop

                                           select * into r_factor___ from nd_factor where term = term.id;

                                           if     term.cnt = 1 then/*{*/

                                                  if nvl(term.addop, 'n/a') != 'n/a' then
                                                     error('term.addop: ' || term.addop);
                                                  end if;

                                                  if nvl(r_factor___.num_flt, 'n/a') != '2' then
                                                     error('term.num_flt: ' || r_factor___.num_flt);
                                                  end if;
                                           /*}*/
                                           elsif  term.cnt = 2 then/*{*/
                                                  if nvl(term.addop, 'n/a') != '+' then
                                                     error('term.addop: ' || term.addop);
                                                  end if;

                                                  if nvl(r_factor___.num_flt, -1) != 3 then
                                                     error('term.num_flt: ' || r_factor___.num_flt);
                                                  end if;

                                           --     All (two) terms were checked:
                                                  term_checked := true;
                                           /*}*/
                                           else /*{*/
                                                  error('term.cnt: ' || term.cnt);
                                           end if;/*}*/


                                         end loop;
                                         if not term_checked then error('not term_checked'); end if;
                                         end;
                                   /*}*/
                                   elsif factor.cnt = 2 then --    The second factor is 4 (the mulop of which is "/")/*{*/

                                    
                                         if nvl(factor.mulop, 'n/a') != '/' then
                                            error('mulop: ' || factor.mulop);
                                         end if;

                                         if nvl(factor.num_flt,'n/a') != '4' then
                                            error('factor.num_flt: ' || factor.num_flt);
                                         end if;

                                   --    factor can only be checked if all factors were checked
                                         factor_checked := true;
                                   /*}*/
                                   else/*{*/
                                         error('factor.cnt: ' || factor.cnt);
                                   end if;/*}*/

                                end loop;

                                   if not factor_checked then error('not factor_checked'); end if;

                                end;/*}*/
                                

                         /*}*/
                         elsif  logical_term.cnt = 2 then/*{*/

                             -- (5)+(9*4) <= (8/3)+2
                                if r_relation_.relop != '<=' then
                                   error('relop <= expected');
                                end if;

                         /*}*/
                         else/*{*/
                                error('logical_term.cnt: ' || logical_term.cnt);

                         end if;/*}*/

                       end;/*}*/

                    end loop;/*}*/

                 elsif cnt_logical_term = 2 and cnt_logical_factor in (7,8) then
                       null;
                       -- TODO...

                 else
                    select * into r_relation from nd_relation where id = logical_factor.relation;
                 end if;/*}*/

                 if     cnt_logical_term = 1 then/*{*/

                        if    cnt_logical_factor = 1 then  --     "col_1" = p_1/*{*/

                              check_simple_relation(logical_factor.relation, 'col_1', '=', 'P_1');

                        /*}*/
                        elsif cnt_logical_factor = 2 then  --     "col_2" > p_2/*{*/

                              check_simple_relation(logical_factor.relation, 'col_2', '>', 'P_2');

                        /*}*/
                        else/*{*/
                              raise_application_error(-20800, 'cnt_logical_factor: ' || cnt_logical_factor);
                        end if;/*}*/
                 /*}*/
                 elsif  cnt_logical_term = 2 then/*{*/

                        if    cnt_logical_factor = 1 then  --     "col_3" < p_3/*{*/

                              check_simple_relation(logical_factor.relation, 'col_3', '<', 'P_3');

                        /*}*/
                        elsif cnt_logical_factor = 2 then  -- not "col_3" != sysdate/*{*/

                              check_simple_relation(logical_factor.relation, 'col_3', '!=', 'SYSDATE');

                        /*}*/
                        elsif cnt_logical_factor = 3 then  --     "col_3" <> to_date("col_2", 'yyyy.mm.dd')/*{*/

                              if nvl(r_relation.relop, '?') != '<>' then
                                 raise_application_error(-20800, 'relop > expected');
                              end if;

                        /*}*/
                        elsif cnt_logical_factor = 4 then  --      sysdate >= to_date("col_2", 'yyyy.mm.dd') + -2*-3.2*-4 - -5*6* (700.0+333.3-400)*8/*{*/

                              if nvl(r_relation.relop, '?') != '>=' then
                                 raise_application_error(-20800, 'relop >= expected');
                              end if;
                        /*}*/
                        elsif cnt_logical_factor = 5 then  --     '14''39' || 2.01 <= 14.2 /*{*/

                              if nvl(r_relation.relop, '?') != '<=' then
                                 raise_application_error(-20800, 'relop <= expected');
                              end if;

                              for term in (select nd_term.*, count(*) over() cnt, row_number() over (order by id) r from nd_term where expression = r_relation.expression_1) loop/*{*/

                                  if     term.r = 1 then/*{*/

                                         if term.cnt != 2 then
                                            raise_application_error(-20800, 'term.cnt: ' || term.cnt);
                                         end if;

                                         if term.addop is not null then
                                            error('term.addop is not null');
                                         end if;

                                         select * into r_factor from nd_factor where term = term.id;

                                         if r_factor.null_ is not null or r_factor.function_expression is not null or r_factor.complex_plsql_ident is not null or r_factor.expression is not null then
                                            error('wrong fields are null');
                                         end if;

                                         if nvl(r_factor.string_, 'n/a') != q'!'14''39'!' then
                                            error('14''''39 expected, but is: >' || r_factor.string_ || '<');
                                         end if;

                                  /*}*/
                                  elsif  term.r = 2 then/*{*/

                                         if nvl(term.addop, 'n/a') != '||' then
                                            error('|| expected');
                                         end if;
                                         
                                         select * into r_factor from nd_factor where term = term.id;

                                         if r_factor.null_ is not null or r_factor.function_expression is not null or r_factor.complex_plsql_ident is not null or r_factor.expression is not null then
                                            error('wrong fields are null');
                                         end if;

                                         if nvl(r_factor.num_flt, 'n/a') != '2.01' then
                                            error('2.01 expected, but is: >' || r_factor.num_flt || '<');
                                         end if;

                                  end if;/*}*/

                              end loop;/*}*/
 

                        /*}*/
                        elsif cnt_logical_factor = 6 then  --      condition within paranthes/*{*/

--                          for logical_term_condition in (
--
--
--                              from
--                                nd_condition                                                                           join
--                                nd_logical_term on nd_condition.logical_term_list = nd_logical_term.logical_term_list  joinh
--
--
--
--                          ) loop
--
--                            if    logical_term_condition.cnt = 1 then/*{*/
--
--                                  if logical_term_condition.relop != '>' then
--                                     error('> expected');
--                                  end if;
--
--                                  for term in (select nd_term.*, count(1) over(order by id) cnt from nd_term where expression in (locigal_factor_list.expression_1, expression_2) order by id) loop
--
--                                      if    term.cnt = 1 then
--                                            null;
--                                      elsif term.cnt = 2 then
--                                            null;
--                                      else 
--                                            error('term.cnt > 2');
--                                      end if;
--
--                                  end loop;
--
--                            /*}*/
--                            elsif logical_term_condition.cnt = 2 then/*{*/
--                               
--                                  if logical_term_condition.relop != '>' then
--                                     error('<= expected');
--                                  end if;
--
--                                  for term in (select nd_term.*, count(1) over(order by id) cnt from nd_term where expression in (locigal_factor_list.expression_1, expression_2) order by id) loop
--                                      if    term.cnt = 1 then
--                                            null;
--                                      elsif term.cnt = 2 then
--                                            null;
--                                      elsif term.cnt = 3 then
--                                            null;
--                                      elsif term.cnt = 4 then
--                                            null;
--                                      else
--                                            error('term.cnt > 2');
--                                      end if;
--
--                                  end loop;
--
--                            /*}*/
--                            else/*{*/
--
--                                  raise_application_error(-20800, 'cnt >= 3');
--                            end if;/*}*/
--
--                        end loop;

  null;
                          
                 
                        /*}*/
                        else/*{*/
                          if cnt_logical_factor not in (7,8) then
                          -- TODO: Clean up this mess!
                              raise_application_error(-20800, 'cnt_logical_factor: ' || cnt_logical_factor);
                          end if;
                        end if;/*}*/
                 
                 end if;/*}*/

             end loop;/*}*/

             if      cnt_logical_term = 1 then/*{*/

                     if cnt_logical_factor != 2 then 
                        raise_application_error(-20800, 'cnt_logical_factor != 2, but: ' || cnt_logical_factor);
                     end if;
             /*}*/
             elsif   cnt_logical_term = 2 then/*{*/

                     if cnt_logical_factor != 7 then 
                        raise_application_error(-20800, 'cnt_logical_factor != 7, but : ' || cnt_logical_factor);
                     end if;

             /*}*/
             else/*{*/
                     raise_application_error(-20800, 'only 2 b terms expected');
             end if;/*}*/

         end loop;/*}*/

         if cnt_logical_term != 2 then
            raise_application_error(-20800, 'cnt_logical_term: ' || cnt_logical_term);
         end if;


      /*}*/
      elsif cnt_item = 3 then/*{  cur_5_2 */

         if nvl(r_cursor_definition.name, '?') != 'CUR_5_2' then/*{*/
            raise_application_error(-20800, 'CUR_5_2 expected, but was: '  || r_cursor_definition.name);
         end if;/*}*/

         if r_cursor_definition.parameter_declaration_list is not null then/*{*/
            error('parameter_declaration_list');
         end if;/*}*/

         select * into r_select_statement from nd_select_statement where id = r_cursor_definition.select_statement;
         select * into r_subquery         from nd_subquery         where id = r_select_statement.subquery;
         select * into r_query_block      from nd_query_block      where id = (select query_block from nd_subquery_elem where subquery =  r_subquery.id);

         declare/*{ Check a.* und b.* */
           select_elem_counter number := 0;
         begin

           for select_elem in (/*{*/

               select 
                 row_number() over (order by expression) counter,
                 nd_select_elem.*
               from
                 nd_select_elem
               where
                 select_list = r_query_block.select_list
               order by 
                 expression

           ) loop

             select * into r_expression       from nd_expression       where id          = select_elem.expression;
             select * into r_term             from nd_term             where expression  = r_expression .id;

             if    select_elem.counter in (1,2,3) then/*{*/
                     select * into r_factor   from nd_factor           where term        = r_term       .id;
             end if;/*}*/
             
             if select_elem.counter in (1,2) then
                null;
             -- TODO   select * into r_plsql_identifier from nd_plsql_identifier where id          = r_factor     .plsql_identifier;
             else
                select * into r_aggregate_function from nd_aggregate_function where id = r_factor.aggregate_function;
             end if;

             if     select_elem.counter = 1 then/*{*/
                    -- a.*
                    check_complex_plsql_id(r_factor.complex_plsql_ident, 'A', '*', null);/*}*/
             elsif  select_elem.counter = 2 then/*{*/
                    -- b.*
                    check_complex_plsql_id(r_factor.complex_plsql_ident, 'B', '*', null);/*}*/
             elsif  select_elem.counter = 3 then/*{*/
                    -- min(a.dummy || 'foo') as min_dummy_foo

                    if r_aggregate_function.name != 'min' then
                       error('min expected');
                    end if;

                    if nvl(select_elem.c_alias,'n/a') != 'MIN_DUMMY_FOO' then
                       error('MIN_DUMMY_FOO expected');
                    end if;

                    if nvl(select_elem.as_, -1) != 1 then 
                       error('AS_ is not set!');
                    end if;

             /*}*/
             elsif  select_elem.counter = 4 then/*{*/
                    -- 5.1 * row_number() over (partition by b.dummy order by a.dummy) as rrr

               declare /*{*/
                 factor_counter number := 0;/*}*/
               begin/*{*/

                   for factor in (/*{*/
                     select 
                       nd_factor.*,
                       row_number() over (order by id) r
                     from
                       nd_factor
                     where term = r_term.id
                   ) loop

                     factor_counter := factor_counter + 1;

                     if     factor_counter = 1 then/*{*/
                            if nvl(factor.num_flt, -1) != '5.1' then
                               error('factor.num_flt: ' || factor.num_flt);
                            end if;/*}*/
                     elsif  factor_counter = 2 then/*{*/

                            if nvl(factor.mulop, '?') != '*' then
                               error('* expected');
                            end if;

                            select * into r_aggregate_function from nd_aggregate_function where id = factor.aggregate_function;

                            if nvl(r_aggregate_function.name,'?') != 'row_number' then
                               error('row_number expected');
                            end if;

                            select * into r_analytic_clause from nd_analytic_clause where id = r_aggregate_function.analytic_clause;
                            -- TODO: Check content of r_analytic_clause.

                     end if;/*}*/

                   end loop;/*}*/

                   if factor_counter != 2 then/*{*/
                      error('factor_counter: ' || 2);
                   end if;/*}*/

               end; /*}*/
             /*}*/
             elsif  select_elem.counter = 5 then/*{*/
                    -- case a.dummy when '#'   then 1.01 when           '*' then 2.02 else 3.03 end simple_case_expression

                    if nvl(select_elem.c_alias, 'n/a') != 'SIMPLE_CASE_EXPRESSION' then
                       error('Alias != SIMPLE_CASE_EXPRESSION');
                    end if;

                    declare/*{*/
                      r_case_expression         nd_case_expression       %rowtype;
                      r_simple_case_expression  nd_simple_case_expression%rowtype;
                      r_else_clause             nd_else_clause           %rowtype;
                    begin

                      select nd_case_expression.* into r_case_expression 
                        from nd_case_expression                                              join 
                             nd_factor on nd_case_expression.id = nd_factor.case_expression  join
                             nd_term   on nd_term           .id = nd_factor.term             
                       where nd_term.expression = select_elem.expression;

                      select * into r_simple_case_expression from nd_simple_case_expression where id = r_case_expression.simple_case_expression;
                      select * into r_else_clause            from nd_else_clause            where id = r_case_expression.else_clause;

                    end;/*}*/
                    --- TODO: finish this testcase.
             /*}*/
             elsif  select_elem.counter = 6 then/*{*/
                    -- case when a.dummy = '!' then 4.04 when a.dummy = '*' then 5.05 else 6.06 ....

                    if nvl(select_elem.c_alias, 'n/a') != 'SEARCHED_CASE_EXPRESSION' then
                       error('Alias != SEARCHED_CASE_EXPRESSION');
                    end if;

                    declare/*{*/
                      r_case_expression           nd_case_expression         %rowtype;
                      r_searched_case_expression  nd_searched_case_expression%rowtype;
                      r_else_clause               nd_else_clause             %rowtype;
                    begin

                      select nd_case_expression.* into r_case_expression 
                        from nd_case_expression                                              join 
                             nd_factor on nd_case_expression.id = nd_factor.case_expression  join
                             nd_term   on nd_term           .id = nd_factor.term             
                       where nd_term.expression = select_elem.expression;

                      select * into r_searched_case_expression from nd_searched_case_expression where id = r_case_expression.searched_case_expression;
                      select * into r_else_clause              from nd_else_clause            where id = r_case_expression.else_clause;

                    end;/*}*/

                    --- TODO: finish this testcase.
             /*}*/
             else /*{*/

                    error('too many elem in select list: ' || select_elem.counter);
             end if;/*}*/

             select_elem_counter := select_elem_counter + 1;

           end loop;/*}*/

           if select_elem_counter != 6 then/*{*/
              error('select_elem_counter: ' || select_elem_counter);
           end if;/*}*/
         end;/*}*/

         declare/*{ Check select list */
           from_elem_found boolean := false;/*}*/
         begin/*{*/
           for from_elem in (

               select /*{*/
                 row_number( ) over (order by table_reference) counter,
                 nd_from_elem.*
               from
                 nd_from_elem
               where
                 from_list = r_query_block.from_list/*}*/

           ) loop

             select * into r_table_reference        from nd_table_reference        where id = from_elem.table_reference;
             select * into r_query_table_expression from nd_query_table_expression where id = r_table_reference.query_table_expression;

             if     from_elem.counter = 1 then/*{ dual.a */

                    if r_table_reference.t_alias != 'A' then
                       error('!= A');
                    end if;

                    check_complex_plsql_id(r_query_table_expression.name_, 'DUAL', null, null);
             /*}*/
             elsif  from_elem.counter = 2 then/*{ dual.b */

                    if r_table_reference.t_alias != 'B' then
                       error('!= B');
                    end if;

                    check_complex_plsql_id(r_query_table_expression.name_, 'DUAL', null, null);
             /*}*/
             else/*{*/
                    error('from_elem.counter: ' || from_elem.counter);
             end if;/*}*/

             from_elem_found := true;

           end loop;


           if not from_elem_found then 
              error('from_elem_found');
           end if;
         end;/*}*/

         declare /*{ Where clause */
           r_where_clause   nd_where_clause  %rowtype;
           r_condition      nd_condition     %rowtype;
           r_relation       nd_relation      %rowtype;
           r_logical_factor nd_logical_factor%rowtype;
           r_in_condition   nd_in_condition  %rowtype;
           r_like_condition nd_like_condition%rowtype;
           r_parameter_elem nd_parameter_elem%rowtype;

           logical_term_checked    boolean := false;
           in_condition_checked    boolean := false;
           like_condition_checked  boolean := false;

           procedure check_simple_expression_(expression_id in number, plsql_1 in varchar2, plsql_2 in varchar2) is/*{*/
              r_term              nd_term            %rowtype;
              r_factor            nd_factor          %rowtype;
--            r_plsql_identifier  nd_plsql_identifier%rowtype;
           begin

           -- TODO cmp with check_simple_...

              select * into r_term             from nd_term             where expression   = expression_id;
              select * into r_factor           from nd_factor           where term         = r_term.id;
--            select * into r_plsql_identifier from nd_plsql_identifier where id           = r_factor.plsql_identifier;

              check_complex_plsql_id(r_factor.complex_plsql_ident, plsql_1, plsql_2, null);

--              if nvl(r_plsql_identifier.identifier_1, 'n/a') != nvl(plsql_1, 'n/a') then
--                 error('check_simple_');
--              end if;
--
--              if nvl(r_plsql_identifier.identifier_2, 'n/a') != nvl(plsql_2, 'n/a') then
--                 error('check_simple_');
--              end if;

           end check_simple_expression_;/*}*/

         begin

           select * into r_where_clause from nd_where_clause where id = r_query_block .where_clause;
           select * into r_condition    from nd_condition    where id = r_where_clause.condition;

           for logical_term in (
            
               select logical_factor_list,
                      row_number() over (order by logical_factor_list) counter
                 from nd_logical_term
                where logical_term_list = r_condition.logical_term_list

           ) loop


                select * into r_logical_factor from nd_logical_factor where logical_factor_list = logical_term.logical_factor_list;

                if    logical_term.counter = 1 then /*{ a.dummy = b.dummy (+) */

                      -- check relation 
                      --
                      --   a.dummy = b.dummy (+)

                      logical_term_checked := true;

                      select * into r_relation from nd_relation where id = r_logical_factor.relation;
                      if nvl(r_relation.relop, 'n/a') != '=' then
                         error('relation.relop: ' || r_relation.relop);
                      end if;

                      check_simple_expression_(r_relation.expression_1, 'A', 'DUMMY');
                      check_simple_expression_(r_relation.expression_2, 'B', 'DUMMY');
        
                /*}*/
                elsif logical_term.counter = 2 then /*{ b.dummy in (chr(20), 'F' */

                      -- check in condition
                      --
                      --     b.dummy in (chr(20), 'F')

                      select * into r_in_condition from nd_in_condition where id = r_logical_factor.in_condition;

                      check_simple_expression_(r_in_condition.expression, 'B', 'DUMMY');

                      for expression_list_elem in (/*{*/

                          select nd_expression_list_elem.*,
                                 row_number() over (order by expression) counter
                            from nd_expression_list_elem
                           where expression_list = r_in_condition.expression_list_2

                      ) loop

                         select * into r_term                 from nd_term                where expression = expression_list_elem.expression;
                         select * into r_factor               from nd_factor              where term       = r_term              .id;

                         if     expression_list_elem.counter = 1 then


                                check_complex_plsql_id(r_factor.complex_plsql_ident, 'CHR', null, null);

                                for elem in (select nd_complex_plsql_ident_elem.*, 
                                                    row_number() over (order by coalesce(plsql_Identifier, paran_parameter_list)) cnt 
                                               from nd_complex_plsql_ident_elem where complex_plsql_ident = r_factor.complex_plsql_ident ) loop

                                    if elem.cnt = 1 and nvl('CHR', '?') != nvl('CHR', '?') then /*{*/
                                       raise_application_error(-20800, 'CHR expected');
                                    end if;/*}*/

                                    if elem.cnt = 2 then /*{*/
                                       select * into r_parameter_elem       
                                         from nd_parameter_elem      
                                        where parameter_list = elem.paran_parameter_list;

                                        select * into r_term                 from nd_term                where expression = r_parameter_elem.expression;
                                        select * into r_factor               from nd_factor              where term       = r_term          .id;

                                        if r_factor.num_flt != '20' then
                                           error('num_flt != 20');
                                        end if;

                                    end if;/*}*/

                                    if elem.cnt = 3 then /*{*/
                                       raise_application_error(-20800, 'unexpected 3');
                                    end if;/*}*/

                                end loop;


                         elsif  expression_list_elem.counter = 2 then


                                if r_factor.string_ != '''F''' then
                                   error('string_ != ''F''');
                                end if;


                                in_condition_checked := true;
                         else   
                                error('Counter: ' || expression_list_elem.counter);
                         end if;
                       

                      end loop;/*}*/

                      if not in_condition_checked then
                         error('in_condition_checked');
                      end if;

                /*}*/
                elsif logical_term.counter = 3 then /*{ b.dummy not like 'NOT_LIKE' */

                      -- like condition
                      --
                      --     b.dummy not like 'NOT_LIKE'

                      select * into r_like_condition from nd_like_condition where id = r_logical_factor.like_condition;

                      if nvl(r_like_condition.not_,-1) != 1 then
                         error('not_');
                      end if;

                      if nvl(r_like_condition.like_,-1) != 1 then
                         error('like_');
                      end if;

                      if nvl(r_like_condition.escape_,-1) != -1 then
                         error('escape_');
                      end if;


                      like_condition_checked := true;
                /*}*/
                elsif logical_term.counter = 4 then /*{ b.dummy is null */
                      declare
                        r_null_condition nd_null_condition%rowtype;
                      begin
                        
                        select * into r_null_condition from nd_null_condition where id = r_logical_factor.null_condition;

                      end;

                /*}*/
                else /*{*/
                      error('logical_term.counter: ' || logical_term.counter);
                end if;/*}*/


           end loop;

           if not logical_term_checked then
              error('logical_term_checked');
           end if;

           if not like_condition_checked then
              error('like_condition_checked');
           end if;

         end;/*}*/

      /*}*/
      elsif cnt_item = 4 then/*{  cur_5_3 */

            declare
              r_select_statement        nd_select_statement      %rowtype;
              r_subquery                nd_subquery              %rowtype;
              r_group_by_clause         nd_group_by_clause       %rowtype;
              r_query_block             nd_query_block           %rowtype;
              r_from_elem               nd_from_elem             %rowtype;
              r_table_reference         nd_table_reference       %rowtype;
              r_query_table_expression  nd_query_table_expression%rowtype;

            begin
              select * into r_select_statement        from nd_select_statement       where id = r_cursor_definition       .select_statement;
              select * into r_subquery                from nd_subquery               where id = r_select_statement        .subquery; 
--            select * into r_query_block             from nd_query_block            where id = r_subquery                .query_block;
              select * into r_query_block             from nd_query_block            where id = (select query_block from nd_subquery_elem where subquery =  r_subquery.id);

              select * into r_group_by_clause         from nd_group_by_clause        where id = r_query_block             .group_by_clause;

              select * into r_from_elem               from nd_from_elem              where from_list = r_query_block      .from_list;
              select * into r_table_reference         from nd_table_reference        where id = r_from_elem               .table_reference;
              select * into r_query_table_expression  from nd_query_table_expression where id = r_table_reference         .query_table_expression;
              -->
              select * into r_subquery                from nd_subquery               where id = r_query_table_expression  .subquery; 
--            select * into r_query_block             from nd_query_block            where id = r_subquery                .query_block;
              select * into r_query_block             from nd_query_block            where id = (select query_block from nd_subquery_elem where subquery =  r_subquery.id);
              select * into r_from_elem               from nd_from_elem              where from_list = r_query_block.from_list;
              select * into r_table_reference         from nd_table_reference        where id = r_from_elem.table_reference;

              if nvl(r_table_reference.t_alias, '?') != 'DUAL_CUR_5_3' then
                 error ('DUAL_CUR_5_3 expected');
              end if;

              select * into r_query_table_expression  from nd_query_table_expression where id = r_table_reference.query_table_expression;
              check_complex_plsql_id(r_query_table_expression.name_, 'DUAL', null, null);


            end;

      /*}*/
      elsif cnt_item = 5 then/*{  cur_5_4 */
        null; -- TODO;
      /*}*/
      elsif cnt_item = 6 then/*{  cur_5_5 */
        null; -- TODO: this test case
      /*}*/
      else/*{*/
        raise_application_error(-20800, 'cnt_item: ' || cnt_item);
      end if;/*}*/

    end loop;/*}*/

    if cnt_select_elem != 2 then 
       error('cnt_select_elem != 2');
    end if;

    dbms_output.put_line('  pck 5 ok');
  end;/*}*/
  /*}*/
  -- tq84_pck_6/*{*/

  declare/*{*/

    cnt_item_elems number := 0;

    r_type_definition            nd_type_definition           %rowtype;
    r_collection_type_definition nd_collection_type_definition%rowtype;
    r_assoc_array_type_def       nd_assoc_array_type_def      %rowtype;
    r_datatype                   nd_datatype                  %rowtype;
    r_scalar_datatype            nd_scalar_datatype           %rowtype;
    r_record_type_definition     nd_record_type_definition    %rowtype;
    r_ref_cursor_type_definition nd_ref_cursor_type_definition%rowtype;
    r_plsql_identifier           nd_plsql_identifier          %rowtype;/*}*/
  begin /*{*/

    select * into r_package         from nd_package         where package_name = 'TQ84_PCK_6';
    select * into r_declare_section from nd_declare_section where id = r_package.declare_section;

    for i in (select * from nd_item_elem_1 where item_list_1 = r_declare_section.item_list_1 order by type_definition) loop/*{*/
        cnt_item_elems := cnt_item_elems + 1;

        if    cnt_item_elems = 1 then/*{*/

              select * into r_type_definition from nd_type_definition where id = i.type_definition;

              select * into r_collection_type_definition from nd_collection_type_definition where id = r_type_definition.collection_type_definition;

              if r_collection_type_definition.name != 'SOME_TYPE' then
                 raise_application_error(-20800, 'SOME_TYPE expected');
              end if;

              select * into r_assoc_array_type_def from nd_assoc_array_type_def where id = r_collection_type_definition.assoc_array_type_def;

              if r_assoc_array_type_def.index_by_pls_integer != 1 then
                 raise_application_error(-20800, 'index_by_pls_integer != 1');
              end if;

              select * into r_datatype        from nd_datatype        where id = r_assoc_array_type_def.datatype;
              select * into r_scalar_datatype from nd_scalar_datatype where id = r_datatype.scalar_datatype;

              if r_scalar_datatype.type_ != 'NUMBER' then
                 raise_application_error(-20800, 'NUMBER expected');
              end if;
        /*}*/
        elsif cnt_item_elems = 2 then/*{*/

              select * into r_type_definition from nd_type_definition where id = i.type_definition;

              select * into r_collection_type_definition from nd_collection_type_definition where id = r_type_definition.collection_type_definition;

              if r_collection_type_definition.name != 'SOME_OTHER_TYPE' then
                 raise_application_error(-20800, 'SOME_OTHER_TYPE expected');
              end if;

              select * into r_assoc_array_type_def from nd_assoc_array_type_def where id = r_collection_type_definition.assoc_array_type_def;

              if r_assoc_array_type_def.index_by_string != 1 then
                 raise_application_error(-20800, 'index_by_string != 1');
              end if;

              if r_assoc_array_type_def.v_size != 5 then
                 raise_application_error(-20800, 'v_size != 5');
              end if;

              select * into r_datatype        from nd_datatype        where id = r_assoc_array_type_def.datatype;
              select * into r_scalar_datatype from nd_scalar_datatype where id = r_datatype.scalar_datatype;

              if r_scalar_datatype.type_ != 'VARCHAR2' then
                 raise_application_error(-20800, 'VARCHAR2 expected');
              end if;

              if r_scalar_datatype.size_ != 10 then
                 raise_application_error(-20800, 'size 10 for varchar2 expected');
              end if;
        /*}*/
        elsif cnt_item_elems = 3 then/*{*/

              select * into r_type_definition        from nd_type_definition where id = i.type_definition;
              select * into r_record_type_definition from nd_record_type_definition where id = r_type_definition.record_type_definition;

              if r_record_type_definition.name != 'RECORD_TYPE' then
                 raise_application_error(-20800, 'Name RECORD_TYPE expected');
              end if;

              declare
                fld_count number := 0;
              begin
                for fld in (

                    select * from nd_field_definition
                     where field_definition_list = r_record_type_definition.field_definition_list
                     order by datatype

                ) loop

                  fld_count := fld_count + 1;

                  if     fld_count = 1 then
                         
                         if    fld.name != 'ELEM_NUM' then
                               raise_application_error(-20800, 'Fieldname ELEM_NUM expected');
                         end if;

                  elsif fld_count = 2 then
                     
                         if    fld.name != 'ELEM_VC' then
                               raise_application_error(-20800, 'Fieldname ELEM_VC expected');
                         end if;

                  elsif fld_count = 3 then
                     
                         if    fld.name != 'ELEM_DT' then
                               raise_application_error(-20800, 'Fieldname ELEM_DT expected');
                         end if;

                  end if;

                end loop;

                if fld_count != 3 then
                   raise_application_error(-20800, 'fld_count != 3');
                end if;
              end;
        /*}*/
        elsif cnt_item_elems = 4 then/*{*/

              select * into r_type_definition        from nd_type_definition where id = i.type_definition;

              select * into r_ref_cursor_type_definition
                from nd_ref_cursor_type_definition
               where id = r_type_definition.ref_cursor_type_definition;

              if r_ref_cursor_type_definition.strong_declaration != 1 then
                 raise_application_error(-20800, 'strong declaration expected');
              end if;

              if nvl(r_ref_cursor_type_definition.name, 'n/a') != 'REF_CURSOR_TYPE' then
                 raise_application_error(-20800, 'Name REF_CURSOR_TYPE expected');
              end if;

              select * into r_plsql_identifier from nd_plsql_identifier
               where id = r_ref_cursor_type_definition.plsql_identifier;

              check_plsql_identifier(r_plsql_identifier, 'RECORD_TYPE', null, null);
        /*}*/
        elsif cnt_item_elems = 5 then/*{*/

              select * into r_type_definition        from nd_type_definition where id = i.type_definition;

              select * into r_ref_cursor_type_definition
                from nd_ref_cursor_type_definition
               where id = r_type_definition.ref_cursor_type_definition;

              if r_ref_cursor_type_definition.strong_declaration != 0 then
                 raise_application_error(-20800, 'weak declaration expected');
              end if;

              if nvl(r_ref_cursor_type_definition.name, 'n/a') != 'REF_CURSOR_WEAK' then
                 raise_application_error(-20800, 'Name REF_CURSOR_WEAK expected');
              end if;

        end if;/*}*/

    end loop;/*}*/

    if cnt_item_elems != 5 then
       raise_application_error(-20800, 'cnt_item_elems != 5');
    end if;

    dbms_output.put_line('  pck 6 ok');

  end;/*}*/

  /*}*/
  -- tq84_pck_7/*{*/

  declare/*{*/

    cnt_item_elems number := 0;

    r_item_declaration           nd_item_declaration          %rowtype;
    r_exception_declaration      nd_exception_declaration     %rowtype;


  begin/*{*/

    select * into r_package         from nd_package         where package_name = 'TQ84_PCK_7';
    select * into r_declare_section from nd_declare_section where id = r_package.declare_section;

    for i in (select * from nd_item_elem_1 where item_list_1 = r_declare_section.item_list_1 order by item_declaration) loop/*{*/
        cnt_item_elems := cnt_item_elems + 1;


        if    cnt_item_elems = 1 then/*{*/

              select * into r_item_declaration      from nd_item_declaration      where id = i.item_declaration;

              select * into r_exception_declaration from nd_exception_declaration where id = r_item_declaration.exception_declaration;

              if r_exception_declaration.name != 'SOME_EXCEPTION' then
                 raise_application_error(-20800, 'Name SOME_EXCEPTION expected');
              end if;

        /*}*/
        elsif cnt_item_elems = 2 then/*{*/

              select * into r_item_declaration      from nd_item_declaration      where id = i.item_declaration;

              select * into r_exception_declaration from nd_exception_declaration where id = r_item_declaration.exception_declaration;

              if r_exception_declaration.name != 'SOME_OTHER_EXCEPTION' then
                 raise_application_error(-20800, 'Name SOME_OTHER_EXCEPTION expected');
              end if;


        /*}*/
        elsif cnt_item_elems = 3 then/*{*/

              declare /*{*/
                r_pragma                     nd_pragma                    %rowtype;
                r_exception_init_pragma      nd_exception_init_pragma     %rowtype;/*}*/
              begin/*{*/

                select * into r_pragma                from nd_pragma                where id = i.pragma_;
                select * into r_exception_init_pragma from nd_exception_init_pragma where id = r_pragma.exception_init_pragma;

                if nvl(r_exception_init_pragma.exception_, 'n/a') != 'SOME_OTHER_EXCEPTION' then/*{*/
                   error('exception != SOME_OTHER_EXCEPTION');
                end if;/*}*/

                if nvl(r_exception_init_pragma.error_code, -99999) != -20900 then/*{*/
                   error('error_code != -20900');
                end if;/*}*/

              end;/*}*/
           

        end if;/*}*/

    end loop;/*}*/

    if cnt_item_elems != 3 then
       raise_application_error(-20800, 'cnt_item_elems != 3');
    end if;

    dbms_output.put_line('  pck 7 ok');

  end;/*}*/

  /*}*/

  /*}*/
  -- tq84_pck_4 body /*{*/

  declare/*{*/

     r_package_body nd_package_body%rowtype;
  /*}*/
  begin/*{*/

     select * into r_package_body from nd_package_body where package_name = (select id from nd_plsql_identifier where identifier_1 = 'TQ84_PCK_4');
     declare/*{*/
       d nd_declare_section%rowtype;
       item_list_2_checked boolean := false;
     begin
       select * into d from nd_declare_section where id = r_package_body.declare_section;

       if d.item_list_1 is not null then
          error('item_list_1');
       end if;

       for e in (select e.*, 
                        count(*) over() cnt, 
                        row_number() over(order by coalesce(procedure_definition, function_definition)) r 
                   from nd_item_elem_2 e where item_list_2 = d.item_list_2) loop
        
           if e.cnt != 8 then/*{*/
              error('e.cnt: ' || e.cnt);
           end if;/*}*/

           if e.function_declaration is not null or e.procedure_declaration is not null then/*{*/
              error('function_declaration/procedure_declaration not null');
           end if;/*}*/

           item_list_2_checked := true;

       end loop;

       if not item_list_2_checked then
          error('not item_list_2_checked');
       end if;


     end;/*}*/
     

     dbms_output.put_line('  pck body 4 ok');
  end;/*}*/

/*}*/

end;
/
