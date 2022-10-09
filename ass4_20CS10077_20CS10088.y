%{
#include <string.h>
#include <stdio.h>
extern int yylex();
extern int yyparse();
void yyerror(char *s);
%}

%token identifier
%token constant
%token string_constant

%token symbol_colon
%token symbol_closed_curly_bracket
%token symbol_open_curly_bracket
%token symbol_semi_colon
%token symbol_closed_bracket
%token symbol_open_bracket
%token symbol_comma
%token symbol_equal
%token symbol_open_square_bracket
%token symbol_closed_square_bracket
%token symbol_star
%token symbol_threedot
%token symbol_dot
%token symbol_dash_greater
%token symbol_double_plus
%token symbol_double_minus
%token symbol_and
%token symbol_plus
%token symbol_minus
%token symbol_tilda
%token symbol_exclamation
%token symbol_divide
%token symbol_modulo
%token symbol_leftshift
%token symbol_rightshift
%token symbol_less
%token symbol_greater
%token symbol_greatereq
%token symbol_lesseq
%token symbol_doubleeq
%token symbol_noteq
%token symbol_xor
%token symbol_oneor
%token symbol_doubleor
%token symbol_question
%token symbol_doubleand
%token symbol_muleq
%token symbol_diveq
%token symbol_modeq
%token symbol_pluseq
%token symbol_minuseq
%token symbol_leftshifteq
%token symbol_rightshifteq
%token symbol_xoreq
%token symbol_andeq
%token symbol_oreq
%token symbol_hash


%token keyword_if
%token keyword_else
%token keyword_switch
%token keyword_while
%token keyword_do
%token keyword_for
%token keyword_goto
%token keyword_continue
%token keyword_break
%token keyword_return
%token keyword_extern
%token keyword_static
%token keyword_auto
%token keyword_register
%token keyword_void
%token keyword_char
%token keyword_short
%token keyword_int
%token keyword_long
%token keyword_float
%token keyword_double
%token keyword_signed
%token keyword_unsigned
%token keyword__Bool
%token keyword__Complex
%token keyword__Imaginary
%token keyword_enum
%token keyword_const
%token keyword_restrict
%token keyword_volatile
%token keyword_inline
%token keyword_sizeof
%token keyword_default
%token keyword_struct
%token keyword_typedef
%token keyword_union
%token keyword_case

%token enumeration_constant
%%
/*External definitions*/

translation_unit        :   external_declaration
                        |   translation_unit external_declaration
                        ;
external_declaration    :   function_definition
                        |   declaration
                        ;
function_definition     :   declaration_specifiers declarator declaration_list_opt compound_statement
                        ;
declaration_list        :   declaration
                        |   declaration_list declaration
                        ;
/* Statement  */

statement               :   labeled_statement
                        |   compound_statement
                        |   expression_statement
                        |   selection_statement
                        |   iteration_statement
                        |   jump_statement
                        ;
labeled_statement       :   identifier symbol_colon statement
                        |   keyword_case constant_expression symbol_colon statement
                        |   keyword_default symbol_colon statement
                        ;

compound_statement      :   symbol_open_curly_bracket block_item_list_opt symbol_closed_curly_bracket 
                        ;

block_item_list         :   block_item
                        |   block_item_list block_item
                        ;

block_item              :   declaration
                        |   statement
                        ;

expression_statement    :   expression_opt symbol_semi_colon
                        ;

selection_statement     :   keyword_if symbol_open_bracket expression symbol_closed_bracket statement
                        |   keyword_if symbol_open_bracket expression symbol_closed_bracket statement keyword_else statement
                        |   keyword_switch symbol_open_bracket expression symbol_closed_bracket statement
                        ;

iteration_statement     :   keyword_while symbol_open_bracket expression symbol_closed_bracket statement
                        |   keyword_do statement keyword_while symbol_open_bracket expression symbol_closed_bracket symbol_semi_colon
                        |   keyword_for symbol_open_bracket expression_opt symbol_semi_colon expression_opt symbol_semi_colon expression_opt symbol_closed_bracket statement
                        |   keyword_for symbol_open_bracket declaration expression_opt symbol_semi_colon expression_opt symbol_closed_bracket statement
                        ;
jump_statement          :   keyword_goto identifier symbol_semi_colon
                        |   keyword_continue symbol_semi_colon
                        |   keyword_break symbol_semi_colon
                        |   keyword_return expression_opt symbol_semi_colon
                        ;

/*  Declarations */

declaration             :   declaration_specifiers init_declarator_list_opt symbol_semi_colon
                        ;
declaration_specifiers  :   storage_class_specifier declaration_specifiers_opt
                        |   type_specifier declaration_specifiers_opt
                        |   type_qualifier declaration_specifiers_opt
                        |   function_specifier declaration_specifiers_opt
                        ;
init_declarator_list    :   init_declarator
                        |   init_declarator_list symbol_comma init_declarator
                        ;
init_declarator         :   declarator
                        |   declarator symbol_equal initializer
                        ;
storage_class_specifier :   keyword_extern
                        |   keyword_static
                        |   keyword_auto
                        |   keyword_register
                        ;
type_specifier          :   keyword_void
                        |   keyword_char
                        |   keyword_short
                        |   keyword_int
                        |   keyword_long
                        |   keyword_float
                        |   keyword_double
                        |   keyword_signed
                        |   keyword_unsigned
                        |   keyword__Bool
                        |   keyword__Complex
                        |   keyword__Imaginary
                        |   enum_specifier
                        ;
specifier_qualifier_list:   type_specifier specifier_qualifier_list_opt
                        |   type_qualifier specifier_qualifier_list_opt
                        ;
enum_specifier          :   keyword_enum identifier_opt symbol_open_curly_bracket enumerator_list symbol_closed_curly_bracket
                        |   keyword_enum identifier_opt symbol_open_curly_bracket enumerator_list symbol_comma symbol_closed_curly_bracket
                        |   keyword_enum identifier
                        ;
enumerator_list         :   enumerator
                        |   enumerator_list symbol_comma enumerator
                        ;
enumerator              :   enumeration_constant
                        |   enumeration_constant symbol_equal constant_expression
                        ;
type_qualifier          :   keyword_const
                        |   keyword_restrict
                        |   keyword_volatile
                        ;
function_specifier      :   keyword_inline
                        ;
declarator              :   pointer_opt direct_declarator
                        ;
direct_declarator       :   identifier
                        |   symbol_open_bracket declarator symbol_closed_bracket
                        |   direct_declarator symbol_open_square_bracket type_qualifier_list_opt assignment_expression_opt symbol_closed_square_bracket
                        |   direct_declarator symbol_open_square_bracket keyword_static type_qualifier_list_opt assignment_expression symbol_closed_square_bracket
                        |   direct_declarator symbol_open_square_bracket type_qualifier_list keyword_static assignment_expression symbol_closed_square_bracket
                        |   direct_declarator symbol_open_square_bracket type_qualifier_list_opt symbol_star symbol_closed_square_bracket
                        |   direct_declarator symbol_closed_bracket parameter_type_list symbol_closed_bracket
                        |   direct_declarator symbol_open_bracket identifier_list_opt symbol_closed_bracket
                        ;
pointer                 :   symbol_star type_qualifier_list_opt
                        |   symbol_star type_qualifier_list_opt pointer
                        ;
type_qualifier_list     :   type_qualifier
                        |   type_qualifier_list type_qualifier
                        ;
parameter_type_list     :   parameter_list
                        |   parameter_list symbol_comma symbol_threedot
                        ;
parameter_list          :   parameter_declaration
                        |   parameter_list symbol_comma parameter_declaration
                        ;
parameter_declaration   :   declaration_specifiers declarator
                        |   declaration_specifiers
                        ;
identifier_list         :   identifier
                        |   identifier_list symbol_comma identifier
                        ;
type_name               :  specifier_qualifier_list
                        ;
initializer             :   assignment_expression
                        |   symbol_open_curly_bracket initializer_list symbol_open_curly_bracket
                        |   symbol_open_curly_bracket initializer_list symbol_comma symbol_closed_curly_bracket
                        ;
initializer_list        :   designation_opt initializer
                        |   initializer_list symbol_comma designation_opt initializer
                        ;
designation             :   designator_list symbol_equal
                        ;
designator_list         :   designator
                        |   designator_list designator
                        ;
designator              :   symbol_open_square_bracket constant_expression symbol_closed_square_bracket
                        |   symbol_dot identifier
                        ;

/*  Expressions   */

primary_expression      :   identifier
                        |   constant
                        |   string_constant
                        |   symbol_open_bracket expression symbol_closed_bracket
                        ;
postfix_expression      :   primary_expression
                        |   postfix_expression symbol_open_square_bracket expression symbol_closed_square_bracket
                        |   postfix_expression symbol_open_bracket argument_expression_list_opt symbol_closed_bracket
                        |   postfix_expression symbol_dot identifier
                        |   postfix_expression symbol_dash_greater identifier
                        |   postfix_expression symbol_double_plus
                        |   postfix_expression symbol_double_minus
                        |   symbol_open_bracket type_name symbol_closed_bracket symbol_open_curly_bracket initializer_list symbol_closed_curly_bracket
                        |   symbol_open_bracket type_name symbol_closed_bracket symbol_open_curly_bracket initializer_list symbol_comma symbol_closed_curly_bracket
                        ;
argument_expression_list:   assignment_expression
                        |   argument_expression_list symbol_comma assignment_expression
                        ;
unary_expression        :   postfix_expression
                        |   symbol_double_plus unary_expression
                        |   symbol_double_minus unary_expression
                        |   unary_operator cast_expression
                        |   keyword_sizeof unary_expression
                        |   keyword_sizeof symbol_open_bracket type_name symbol_closed_bracket
                        ;
unary_operator          :   symbol_and
                        |   symbol_star
                        |   symbol_plus
                        |   symbol_minus
                        |   symbol_tilda
                        |   symbol_tilda
                        ;
cast_expression         :   unary_expression
                        |   symbol_open_bracket type_name symbol_closed_bracket cast_expression
                        ;
multiplicative_expression:  cast_expression
                        |   multiplicative_expression symbol_star cast_expression
                        |   multiplicative_expression symbol_divide cast_expression
                        |   multiplicative_expression symbol_modulo cast_expression
                        ;
additive_expression     :   multiplicative_expression
                        |   additive_expression symbol_plus multiplicative_expression
                        |   additive_expression symbol_minus multiplicative_expression
                        ;
shift_expression        :   additive_expression
                        |   shift_expression symbol_leftshift additive_expression
                        |   shift_expression symbol_rightshift additive_expression
                        ;
relational_expression   :   shift_expression
                        |   relational_expression symbol_less shift_expression
                        |   relational_expression symbol_greater shift_expression
                        |   relational_expression symbol_lesseq shift_expression
                        |   relational_expression symbol_greatereq shift_expression
                        ;
equality_expression     :   relational_expression
                        |   equality_expression symbol_doubleeq relational_expression
                        |   equality_expression symbol_noteq relational_expression
                        ;
AND_expression          :   equality_expression
                        |   AND_expression symbol_and equality_expression
                        ;
exclusive_OR_expression :   AND_expression
                        |   exclusive_OR_expression symbol_xor AND_expression 
                        ;
inclusive_OR_expression :   exclusive_OR_expression
                        |   inclusive_OR_expression symbol_oneor exclusive_OR_expression
                        ;
logical_AND_expression  :   inclusive_OR_expression
                        |   logical_AND_expression symbol_doubleand inclusive_OR_expression
                        ;
logical_OR_expression   :   logical_AND_expression
                        |   logical_OR_expression symbol_doubleor logical_AND_expression     
                        ;
conditional_expression  :   logical_OR_expression
                        |   logical_OR_expression symbol_question expression symbol_colon conditional_expression
                        ;
assignment_expression   :   conditional_expression
                        |   unary_expression assignment_operator assignment_expression
assignment_operator     :   symbol_equal
                        |   symbol_muleq
                        |   symbol_diveq
                        |   symbol_modeq
                        |   symbol_pluseq
                        |   symbol_minuseq
                        |   symbol_leftshifteq
                        |   symbol_rightshifteq
                        |   symbol_andeq
                        |   symbol_xoreq
                        |   symbol_oreq
                        ;
expression              :   assignment_expression
                        |   expression symbol_comma assignment_expression
                        ;
constant_expression     :   conditional_expression 

declaration_list_opt    :   declaration_list
                        |
                        ;

block_item_list_opt     :   block_item_list
                        |
                        ;
expression_opt          :   expression
                        |
                        ;

init_declarator_list_opt:   init_declarator_list
                        |
                        ;
declaration_specifiers_opt:     declaration_specifiers
                        |
                        ;

specifier_qualifier_list_opt    :   specifier_qualifier_list
                                |
                                ;
identifier_opt          :   identifier
                        |
                        ;
pointer_opt             :   pointer
                        |
                        ;
type_qualifier_list_opt :   type_qualifier_list
                        |
                        ;
assignment_expression_opt:  assignment_expression
                        |
                        ;
identifier_list_opt     :   identifier_list
                        |
                        ;
designation_opt         :   designation
                        |
                        ;
argument_expression_list_opt: argument_expression_list
                        |
                        ;






/*statement   :   expression
            ;

expression  :   expression '+' term
            |   expression '-' term
            |   term
            ;

term        :   term '*' factor
            |   term '/' factor
            |   factor
            ;

factor      :'(''+'')'
            | '-' factor
            | NUMBER
            ;*/

%%
void yyerror(char *s){

    printf("%s\n",s);
}

int main()
{
    yyparse();
}