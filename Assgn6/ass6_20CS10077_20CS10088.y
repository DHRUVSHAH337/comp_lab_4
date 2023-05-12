%{
#include <iostream>
#include "ass6_20CS10077_20CS10088_translator.h"
using namespace std;
extern int yylex();
extern int yyparse();
extern int line_count;
extern char* yytext; 
extern int nextinstr; 
extern quad_array quadList;
extern symbol_table global_symbol_table; 
extern symbol_table* present_symbol_table;
extern string varType;      // Used for storing the last encountered type
extern vector<string> string_storage;
int strCount = 0;
void yyerror(char *s);
%}

%union {
    string* string_type;      // storing strings
    char char_type;        // storing char values
    int int_type;           // storing int values
    float float_type;       // storing floating point values
    void *pointer_type;

   
    char u_operator;       // unary operators

    
    data_type data_types;
    declaration* declar_type;
    vector<declaration*> *dec_list;
    expression* Expression;       // For an expression
    param* prm; 
    vector<param*> *prmList; 
}

/* all types of constants  */
%token<string_type> string_constant
%token<char_type> char_constant
%token<int_type> integer_constant
%token<float_type> float_constant

/* identifier assigned with the class symbol as an entry to the symbol table */
%token<string_type> identifier


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

%token invalid_token

%type<Expression>
	    expression
        primary_expression 
        multiplicative_expression
        additive_expression
        shift_expression
        relational_expression
        equality_expression
        AND_expression
        exclusive_OR_expression
        inclusive_OR_expression
        logical_AND_expression
        logical_OR_expression
        conditional_expression
        assignment_expression
        postfix_expression
        unary_expression
        cast_expression
        expression_statement
        statement
        compound_statement
        selection_statement
        iteration_statement
        labeled_statement 
        jump_statement
        block_item
        block_item_list
        initializer
        M
        N

%type<int_type>pointer

%type<u_operator> symbol_unary_operator

%type <declar_type> direct_declarator initializer_list init_declarator declarator function_prototype
%type <data_types> type_specifier declaration_specifiers
%type <dec_list> init_declarator_list
%type <prm> parameter_declaration
%type <prmList> parameter_list parameter_type_list parameter_type_list_opt argument_expression_list argument_expression_list_opt

%right THEN keyword_else

%%
/*External definitions*/

translation_unit        :   external_declaration
                            { 
                                //printf("Line: %d,\t translation_unit :--> external_declaration\n",line_count); 
                            }
                        |   translation_unit external_declaration
                            { 
                                //printf("Line: %d,\t translation_unit :--> translation_unit external_declaration\n",line_count); 
                            }
                        ;
external_declaration    :   function_definition
                            { 
                                //printf("Line: %d,\t external_declaration :--> function_definition\n",line_count); 
                            }
                        |   declaration
                            { 
                                //printf("Line: %d,\t external_declaration :--> declaration\n",line_count); 
                            }
                        ;
function_definition     :   declaration_specifiers declarator declaration_list compound_statement
                            {
                                //printf("Line: %d,\t function_definition :--> declaration_specifiers declarator declaration_list compound_statement\n",line_count); 
                            }
                        |   function_prototype compound_statement
                            {
                                //printf("Line: %d,\t function_definition :--> function_prototype compound_statement\n",line_count); 
                                present_symbol_table = &global_symbol_table;                     // coming back to the global symbol table after the function definition
                                emit($1->name, "", "", FUNC_END);
                            }
                        ;

function_prototype      :   declaration_specifiers declarator       // setting the function details 
                            {
                                data_type currType = $1;
                                int currSize = -1;
                                if(currType == data_type_char)
                                    currSize = size_of_character;
                                if(currType == data_type_integer)
                                    currSize = size_of_integer;
                                if(currType == data_type_float)
                                    currSize = size_of_float;
                                declaration* currDec = $2;
                                symbol* sym = global_symbol_table.lookup(currDec->name);
                                if(currDec->type == data_type_function) {
                                    symbol* retval = sym->nestedTable->lookup("RETVAL", currType, currDec->pointers);   // Create entry for return value
                                    sym->size = 0;
                                    sym->initVal = NULL;
                                }
                                $$ = $2;
                            }
                        ;

declaration_list        :   declaration
                            {
                                //printf("Line: %d,\t declaration_list :--> declaration\n",line_count);
                            }
                            | declaration_list declaration
                            {
                                //printf("Line: %d,\t declaration_list :--> declaration_list declaration\n",line_count);
                            }
                        ;
/* Statement  */

statement               :   labeled_statement
                            { 
                                //printf("Line: %d,\t statement :--> labeled_statement\n",line_count); 
                            }
                        |   compound_statement
                            { 
                                //printf("Line: %d,\t statement :--> compound_statement\n",line_count);
                                // $$ = $1; // setting the statement to the $1, compound statement
                            }
                        |   expression_statement
                            { 
                                //printf("Line: %d,\t statement :--> expression_statement\n",line_count);
                                // $$ = new statement();           
                                // $$->nextlist = $1->nextlist;    
                                // setting the present statement's nextlist as the $1's nextlist
                            }
                        |   selection_statement
                            { 
                                //printf("Line: %d,\t statement :--> selection_statement\n",line_count);
                                // $$ = $1; // setting the statement to the $1, selection_statement
                            }
                        |   iteration_statement
                            { 
                                //printf("Line: %d,\t statement :--> iteration_statement\n",line_count);
                                // $$ = $1; // setting the statement to the $1, iteration_statement
                            }
                        |   jump_statement
                            { 
                                //printf("Line: %d,\t statement :--> jump_statement\n",line_count);
                                // $$ = $1; // setting the statement to the $1, jump_statement
                            }
                        ;
labeled_statement       :   identifier symbol_colon statement
                            { 
                                //printf("Line: %d,\t labeled_statement :--> identifier symbol_colon statement\n",line_count); 
                            }
                        |   keyword_case constant_expression symbol_colon statement
                            { 
                                //printf("Line: %d,\t labeled_statement :--> keyword_case constant_expression symbol_colon statement\n",line_count); 
                            }
                        |   keyword_default symbol_colon statement
                            { 
                                //printf("Line: %d,\t labeled_statement :--> keyword_default symbol_colon statement\n",line_count); 
                            }
                        ;

compound_statement      :   symbol_open_curly_bracket block_item_list symbol_closed_curly_bracket 
                            { 
                                //printf("Line: %d,\t compound_statement :--> symbol_open_curly_bracket  block_item_list symbol_closed_curly_bracket\n",line_count);
                                $$ = $2;
                            }
                        |   symbol_open_curly_bracket symbol_closed_curly_bracket 
                            { 
                                //printf("Line: %d,\t compound_statement :--> symbol_open_curly_bracket symbol_closed_curly_bracket\n",line_count);
                            }
                        ;

block_item_list         :   block_item
                            { 
                                //printf("Line: %d,\t block_item_list :--> block_item\n",line_count);
                                $$ = $1; // assigning the block_item to block_item_list
                                backpatch($1->nextlist, nextinstr); // backpatching the next instruction to the present block item list
                            }
                        |   block_item_list M block_item
                            { 
                                //printf("Line: %d,\t block_item_list :--> block_item_list M block_item\n",line_count);
                                // Augmentations done "M" so that backpatching of $1 list can be done
                                $$ = new expression();
                                backpatch($1->nextlist, $2->instr);    // setting the next instruction (block_item) for the block_item_list
                                $$->nextlist = $3->nextlist;            // whole next is next of the block_item
                            }
                        ;
block_item              :   declaration
                            { 
                                //printf("Line: %d,\t block_item :--> declaration\n",line_count);
                               $$ = new expression();   // creating a new expression to store the delcaration in block_item
                            }
                        |   statement
                            { 
                                //printf("Line: %d,\t block_item :--> statement\n",line_count);
                            }
                        ;

expression_statement    :   expression symbol_semi_colon
                            { 
                                //printf("Line: %d,\t expression_statement :--> expression symbol_semi_colon\n",line_count);
                                // $$ = $1; // assignment
                            }
                        |   symbol_semi_colon
                            {
                                //printf("Line: %d,\t expres$$ = $1;expression_statement :--> symbol_semi_colon\n",line_count);
                                $$ = new expression(); // generating a new assignment
                            }
                        ;

selection_statement     :   keyword_if symbol_open_bracket expression N symbol_closed_bracket M statement N %prec THEN
                            { 
                                //printf("Line: %d,\t selection_statement :--> keyword_if symbol_open_bracket expression symbol_closed_bracket statement\n",line_count);
                                /*
                                Augmented according to the slides
                                setting the truelist and false list for the expression and backpatching
                                */
                                backpatch($4->nextlist, nextinstr);       // backpatching nextlist of N as nextinstr                  
                                convertIntToBool($3);                       // converting the expression to boolean                                   
                                $$ = new expression();                       // creating a new statement for the whole                                  
                                backpatch($3->truelist, $6->instr);                // backpatching the truelist to M1                            
                                $7->nextlist = merge($8->nextlist, $7->nextlist);   // merging the nextlists for the whole selection_statement
                                $$->nextlist = merge($3->falselist, $7->nextlist);
                            }
                        |   keyword_if symbol_open_bracket expression N symbol_closed_bracket M statement N keyword_else M statement N
                            { 
                                //printf("Line: %d,\t selection_statement :--> keyword_if symbol_open_bracket expression symbol_closed_bracket statement keyword_else statement\n",line_count);
                                // Augmented for the control flow of the instructions as shown in the slides and class
                                backpatch($4->nextlist, nextinstr);                   // backpatching nextlist of N as nextinstr   
                                convertIntToBool($3);                                   // converting the expression to boolean
                                $$ = new expression();                                   // creating a new expression for the whole
                                backpatch($3->truelist, $6->instr);                            // backpatching the truelist to M1
                                backpatch($3->falselist, $10->instr);                          // backpatching the falselist to M2

                                // merging all the nextlists
                                $$->nextlist = merge($7->nextlist, $8->nextlist);       
                                $$->nextlist = merge($$->nextlist, $11->nextlist);
                                $$->nextlist = merge($$->nextlist, $12->nextlist);
                            }
                        |   keyword_switch symbol_open_bracket expression symbol_closed_bracket statement
                            { 
                                //printf("Line: %d,\t selection_statement :--> keyword_switch symbol_open_bracket expression symbol_closed_bracket statement\n",line_count); 
                            }
                        ;

iteration_statement     :   keyword_while M symbol_open_bracket expression N symbol_closed_bracket M statement
                            { 
                                //printf("Line: %d,\t iteration_statement :--> keyword_while symbol_open_bracket expression symbol_closed_bracket statement\n",line_count);
                                 /*
                                   This has been augmented with M so that we can set the control flow of the statements for the while loop
                                */
                                $$ = new expression();                                               // creating a new expression
                                emit("", "", "", GOTO);
                                backpatch(makelist(nextinstr - 1), $2->instr);
                                backpatch($5->nextlist, nextinstr);
                                convertIntToBool($4);                                               // converting it to boolean
                                backpatch($8->nextlist, $2->instr);                                        // after statement go back to starting M1 to check the condition
                                backpatch($4->truelist, $7->instr);                                        // if the expression is true then we go to M2
                            }
                        |   keyword_do M statement M keyword_while symbol_open_bracket expression N symbol_closed_bracket symbol_semi_colon
                            { 
                                //printf("Line: %d,\t iteration_statement :--> keyword_do statement keyword_while symbol_open_bracket expression symbol_closed_bracket symbol_semi_colon\n",line_count);
                                /*
                                   This has been augmented with M so that we can set the control flow of the statements for the do ... while loop
                                */
                                $$ = new expression();                                               // creating a new expression
                                backpatch($8->nextlist, nextinstr);
                                convertIntToBool($7);                                               // converting it to boolean
                                backpatch($7->truelist, $2->instr);                                        // if the expression is true then we go to M2
                                backpatch($3->nextlist, $4->instr);                                        // after statement go back to M2
                                $$->nextlist = $7->falselist;                                       // if we get false then we have to exit the iteration_statement
                            }
                        |   keyword_for symbol_open_bracket expression_statement M expression_statement N M expression N symbol_closed_bracket M statement
                            { 
                                //printf("Line: %d,\t iteration_statement :--> keyword_for symbol_open_bracket expression_statement symbol_semi_colon expression_statement symbol_semi_colon expression_statement symbol_closed_bracket statement\n",line_count);
                                /*
                                    This has been augmented with M so that we can set the control flow of the statements for the do ... while loop
                                */
                                $$ = new expression();                                  // create a new expression
                                emit("", "", "", GOTO);
                                $12->nextlist = merge($12->nextlist, makelist(nextinstr - 1)); 
                                convertIntToBool($5);                   // conversion from int to bool
                                backpatch($12->nextlist, $7->instr); // go to start of the loop
                                backpatch($9->nextlist, $4->instr);         
                                backpatch($6->nextlist, nextinstr);
                                backpatch($5->truelist, $11->instr);    // if the condition is true the go to the last M 
                                $$->nextlist = $5->falselist;           // go to next only if the conditionis false

                                /*if the expression is true then we go to M3
                                /* after the third expression we have to go to condition check
                                /* after statement we have to go to M2 for third expression
                                /* Emitting the goto for that
                                /* if we get false then we have to exit the iteration_statement*/
                            }
                        |   keyword_for symbol_open_bracket declaration expression_opt symbol_semi_colon expression_opt symbol_closed_bracket statement
                            { 
                                //printf("Line: %d,\t iteration_statement :--> keyword_for symbol_open_bracket declaration expression_opt symbol_semi_colon expression_opt symbol_closed_bracket statement\n",line_count); 
                            }
                        ;
jump_statement          :   keyword_goto identifier symbol_semi_colon
                            { 
                                //printf("Line: %d,\t jump_statement :--> keyword_goto identifier symbol_semi_colon\n",line_count); 
                            }
                        |   keyword_continue symbol_semi_colon
                            { 
                                //printf("Line: %d,\t jump_statement :--> keyword_continue symbol_semi_colon\n",line_count);
                                // $$ = new statement(); 
                            }
                        |   keyword_break symbol_semi_colon
                            { 
                                //printf("Line: %d,\t jump_statement :--> keyword_break symbol_semi_colon\n",line_count);
                                // $$ = new statement(); 
                            }
                        |   keyword_return expression symbol_semi_colon
                            { 
                                //printf("Line: %d,\t jump_statement :--> keyword_return expression symbol_semi_colon\n",line_count);
                                if(present_symbol_table->lookup("RETVAL")->type.type == present_symbol_table->lookup($2->loc)->type.type) 
                                {
                                    emit($2->loc, "", "", RETURN);          // returning the expression as the type is not void     
                                }
                                $$ = new expression();
                                
                            }
                        |   keyword_return symbol_semi_colon
                            {
                                if(present_symbol_table->lookup("RETVAL")->type.type == data_type_void) 
                                {
                                    emit("", "", "", RETURN);           // returning nothing as it is of void
                                }
                                $$ = new expression();
                            }
                        ;

/*  Declarations */

declaration             :   declaration_specifiers init_declarator_list symbol_semi_colon
                            { 
                                //printf("Line: %d,\t declaration :--> declaration_specifiers init_declarator_list_opt symbol_semi_colon\n",line_count);
                                data_type currType = $1;
                                int currSize = -1;
                                // setting the size
                                if(currType == data_type_integer)
                                    currSize = size_of_integer;
                                else if(currType == data_type_char)
                                    currSize = size_of_character;
                                else if(currType == data_type_float)
                                    currSize = size_of_float;
                                
                                vector<declaration*> decs = *($2);
                                
                                for(vector<declaration*>::iterator it = decs.begin(); it != decs.end(); it++) {
                                    declaration* currDec = *it;
                                    if(currDec->type == data_type_function) {
                                        present_symbol_table = &global_symbol_table;
                                        emit(currDec->name, "", "", FUNC_END);
                                        symbol* one = present_symbol_table->lookup(currDec->name);        // adding the function to the symbol table
                                        symbol* two = one->nestedTable->lookup("RETVAL", currType, currDec->pointers);
                                        one->size = 0;
                                        one->initVal = NULL;
                                        continue;
                                    }

                                    symbol* three = present_symbol_table->lookup(currDec->name, currType);        // for the variables, create an entry in the symbol table
                                    three->nestedTable = NULL;
                                    if(currDec->li == vector<int>() && currDec->pointers == 0) {
                                        three->type.type = currType;
                                        three->size = currSize;
                                        if(currDec->initVal != NULL) {
                                            string rval = currDec->initVal->loc;
                                            emit(three->name, rval, "", ASSIGN);
                                            three->initVal = present_symbol_table->lookup(rval)->initVal;
                                        }
                                        else
                                            three->initVal = NULL;
                                    }
                                    else if(currDec->li != vector<int>()) {         // array types
                                        three->type.type = data_type_array;
                                        three->type.nextType = currType;
                                        three->type.dimension_vector = currDec->li;
                                        vector<int> temp = three->type.dimension_vector;
                                        int sz = currSize;
                                        for(int i = 0; i < (int)temp.size(); i++)
                                            sz *= temp[i];
                                        present_symbol_table->offset += sz;
                                        three->size = sz;
                                        present_symbol_table->offset -= 4;
                                    }
                                    else if(currDec->pointers != 0) {               // pointer types
                                        three->type.type = data_type_pointer;
                                        three->type.nextType = currType;
                                        three->type.pointers = currDec->pointers;
                                        present_symbol_table->offset += (size_of_pointer - currSize);
                                        three->size = size_of_pointer;
                                    }
                                } 
                            }
                        |   declaration_specifiers symbol_semi_colon
                            {
                                //printf("Line: %d,\t declaration :--> declaration_specifiers symbol_semi_colon\n",line_count);
                            }
                        ;
declaration_specifiers  :   storage_class_specifier declaration_specifiers_opt
                            { 
                                //printf("Line: %d,\t declaration_specifiers :--> storage_class_specifier declaration_specifiers_opt\n",line_count); 
                            }
                        |   type_specifier declaration_specifiers_opt
                            { 
                                //printf("Line: %d,\t declaration_specifiers :--> type_specifier declaration_specifiers_opt\n",line_count); 
                            }
                        |   type_qualifier declaration_specifiers_opt
                            { 
                                //printf("Line: %d,\t declaration_specifiers :--> type_qualifier declaration_specifiers_opt\n",line_count); 
                            }
                        |   function_specifier declaration_specifiers_opt
                            { 
                                //printf("Line: %d,\t declaration_specifiers :--> function_specifier declaration_specifiers_opt\n",line_count); 
                            }
                        ;
init_declarator_list    :   init_declarator
                            { 
                                //printf("Line: %d,\t init_declarator_list :--> init_declarator\n",line_count);
                                $$ = new vector<declaration*>;      // vector of declaration
                                $$->push_back($1);                  // adding the init_declarator to it
                            }
                        |   init_declarator_list symbol_comma init_declarator
                            { 
                                //printf("Line: %d,\t init_declarator_list :--> init_declarator_list symbol_comma init_declarator\n",line_count);
                                $1->push_back($3);                  // Add the next init_declarator to the vector of declarations
                                $$ = $1; 
                            }
                        ;
init_declarator         :   declarator
                            { 
                                //printf("Line: %d,\t init_declarator :--> declarator\n",line_count);
                                $$ = $1;
                                $$->initVal = NULL;         // Initializing the NULL value as there is no value provided in the declaration
                            }
                        |   declarator symbol_equal initializer
                            { 
                                //printf("Line: %d,\t init_declarator :--> declarator symbol_equal initializer\n",line_count);
                                $$ = $1;
                                $$->initVal = $3;           // init value sent which is provided
                            }
                        ;
storage_class_specifier :   keyword_extern
                            { 
                                //printf("Line: %d,\t storage_class_specifier :--> keyword_extern\n",line_count); 
                            }
                        |   keyword_static
                            { 
                                //printf("Line: %d,\t storage_class_specifier :--> keyword_static\n",line_count); 
                            }
                        |   keyword_auto
                            { 
                                //printf("Line: %d,\t storage_class_specifier :--> keyword_auto\n",line_count); 
                            }
                        |   keyword_register
                            { 
                                //printf("Line: %d,\t storage_class_specifier :--> keyword_register\n",line_count); 
                            }
                        ;
type_specifier          :   keyword_void
                            { 
                                //printf("Line: %d,\t type_specifier :--> keyword_void\n",line_count);
                                $$ = data_type_void; // setting the data_type as void
                            }
                        |   keyword_char
                            { 
                                //printf("Line: %d,\t type_specifier :--> keyword_char\n",line_count);
                                $$ = data_type_char; // setting the data_type as char
                            }
                        |   keyword_short
                            { 
                                //printf("Line: %d,\t type_specifier :--> keyword_short\n",line_count);

                            }
                        |   keyword_int
                            { 
                                //printf("Line: %d,\t type_specifier :--> keyword_int\n",line_count);
                                $$ = data_type_integer; //setting the data_type as int
                            }
                        |   keyword_long
                            { 
                                //printf("Line: %d,\t type_specifier :--> keyword_long\n",line_count); 
                            }
                        |   keyword_float
                            { 
                                //printf("Line: %d,\t type_specifier :--> keyword_float\n",line_count);
                                $$ = data_type_float; // setting the data_type as float
                            }
                        |   keyword_double
                            {
                                //printf("Line: %d,\t type_specifier :--> keyword_double\n",line_count); 
                            }
                        |   keyword_signed
                            { 
                                //printf("Line: %d,\t type_specifier :--> keyword_signed\n",line_count); 
                            }
                        |   keyword_unsigned
                            { 
                                //printf("Line: %d,\t type_specifier :--> keyword_unsigned\n",line_count); 
                            }
                        |   keyword__Bool
                            { 
                                //printf("Line: %d,\t type_specifier :--> keyword__Bool\n",line_count); 
                            }
                        |   keyword__Complex
                            { 
                                //printf("Line: %d,\t type_specifier :--> keyword__Complex\n",line_count); 
                            }
                        |   keyword__Imaginary
                            { 
                                //printf("Line: %d,\t type_specifier :--> keyword__Imaginary\n",line_count); 
                            }
                        |   enum_specifier
                            { 
                                //printf("Line: %d,\t type_specifier :--> enum_specifier\n",line_count); 
                            }
                        ;
specifier_qualifier_list:   type_specifier specifier_qualifier_list_opt
                            { 
                                //printf("Line: %d,\t specifier_qualifier_list :--> type_specifier specifier_qualifier_list_opt\n",line_count); 
                            }
                        |   type_qualifier specifier_qualifier_list_opt
                            { 
                                //printf("Line: %d,\t specifier_qualifier_list :--> type_qualifier specifier_qualifier_list_opt\n",line_count); 
                            }
                        ;
enum_specifier          :   keyword_enum identifier_opt symbol_open_curly_bracket enumerator_list symbol_closed_curly_bracket
                            { 
                                //printf("Line: %d,\t enum_specifier :--> keyword_enum identifier_opt symbol_open_curly_bracket enumerator_list symbol_closed_curly_bracket\n",line_count); 
                            }
                        |   keyword_enum identifier_opt symbol_open_curly_bracket enumerator_list symbol_comma symbol_closed_curly_bracket
                            { 
                                //printf("Line: %d,\t enum_specifier :--> keyword_enum identifier_opt symbol_open_curly_bracket enumerator_list symbol_comma symbol_closed_curly_bracket\n",line_count); 
                            }
                        |   keyword_enum identifier
                            { 
                                //printf("Line: %d,\t enum_specifier :--> keyword_enum identifier\n",line_count); 
                            }
                        ;
enumerator_list         :   enumerator
                            { 
                                //printf("Line: %d,\t enumerator_list :--> enumerator\n",line_count); 
                            }
                        |   enumerator_list symbol_comma enumerator
                            { 
                                //printf("Line: %d,\t enumerator_list :--> enumerator_list symbol_comma enumerator\n",line_count); 
                            }
                        ;
enumerator              :   enumeration_constant
                            {
                                //printf("Line: %d,\t enumerator :--> enumeration_constant\n",line_count); 
                            }
                        |   enumeration_constant symbol_equal constant_expression
                            { 
                                //printf("Line: %d,\t enumerator :--> enumeration_constant symbol_equal constant_expression\n",line_count); 
                            }
                        ;
enumeration_constant    :   identifier
                            { 
                                //printf("Line: %d,\t enumeration_constant :--> identifier\n",line_count); 
                            }
                        ;
type_qualifier          :   keyword_const
                            { 
                                //printf("Line: %d,\t type_qualifier :--> keyword_const\n",line_count); 
                            }
                        |   keyword_restrict
                            { 
                                //printf("Line: %d,\t type_qualifier :--> keyword_restrict\n",line_count); 
                            }
                        |   keyword_volatile
                            { 
                                //printf("Line: %d,\t type_qualifier :--> keyword_volatile\n",line_count); 
                            }
                        ;
function_specifier      :   keyword_inline
                            { 
                                //printf("Line: %d,\t function_specifier :--> keyword_inline\n",line_count); 
                            }
                        ;
declarator              :   pointer direct_declarator
                            { 
                                //printf("Line: %d,\t declarator :--> pointer_opt direct_declarator\n",line_count);
                                $$ = $2;
                                $$->pointers = $1; 
                            }
                        |   direct_declarator
                            { 
                                //printf("Line: %d,\t declarator :--> direct_declarator\n",line_count);
                                $$ = $1;
                                $$->pointers = 0;
                            }
                        ;

direct_declarator       :   identifier
                            { 
                                //printf("Line: %d,\t direct_declarator :--> identifier\n",line_count);
                                $$ = new declaration();         // creating a new declaration
                                $$->name = *($1);               // setting the name
                            }
                        |   symbol_open_bracket declarator symbol_closed_bracket
                            { 
                                //printf("Line: %d,\t direct_declarator :--> symbol_open_bracket declarator symbol_closed_bracket\n",line_count); 
                                // $$ = $2; 
                            }
                        |   direct_declarator symbol_open_square_bracket type_qualifier_list_opt assignment_expression symbol_closed_square_bracket
                            { 
                                //printf("Line: %d,\t direct_declarator :--> direct_declarator symbol_open_square_bracket type_qualifier_list_opt assignment_expression symbol_closed_square_bracket\n",line_count);
                                $1->type = data_type_array;       // for array types set its type
                                $1->nextType = data_type_integer;     // setting the nextType
                                $$ = $1;
                                int index = present_symbol_table->lookup($4->loc)->initVal->i;    // finding the initial val index and adding it into the list
                                $$->li.push_back(index); 
                            }
                        |   direct_declarator symbol_open_square_bracket type_qualifier_list_opt symbol_closed_square_bracket
                            { 
                                //printf("Line: %d,\t direct_declarator :--> direct_declarator symbol_open_square_bracket type_qualifier_list_opt symbol_closed_square_bracket\n",line_count);
                                $1->type = data_type_array;       // setting the type as array type
                                $1->nextType = data_type_integer;     // setting the nextType
                                $$ = $1;
                                $$->li.push_back(0); 
                            }
                        |   direct_declarator symbol_open_square_bracket keyword_static type_qualifier_list_opt assignment_expression symbol_closed_square_bracket
                            { 
                                //printf("Line: %d,\t direct_declarator :--> direct_declarator symbol_open_square_bracket keyword_static type_qualifier_list_opt assignment_expression symbol_closed_square_bracket\n",line_count); 
                            }
                        
                        |   direct_declarator symbol_open_square_bracket type_qualifier_list keyword_static assignment_expression symbol_closed_square_bracket
                            { 
                                //printf("Line: %d,\t direct_declarator :--> direct_declarator symbol_open_square_bracket type_qualifier_list keyword_static assignment_expression symbol_closed_square_bracket\n",line_count); 
                            }
                        
                        |   direct_declarator symbol_open_square_bracket type_qualifier_list_opt symbol_star symbol_closed_square_bracket
                            { 
                                //printf("Line: %d,\t direct_declarator :--> direct_declarator symbol_open_square_bracket type_qualifier_list_opt symbol_star symbol_closed_square_bracket\n",line_count);
                                $1->type = data_type_pointer;     // pointer type
                                $1->nextType = data_type_integer;
                                $$ = $1; 
                            }                        
                        |   direct_declarator symbol_open_bracket parameter_type_list_opt symbol_closed_bracket
                            { 
                                //printf("Line: %d,\t direct_declarator :--> direct_declarator symbol_open_bracket parameter_type_list symbol_closed_bracket\n",line_count); 
                                $$ = $1;
                                $$->type = data_type_function;    // setting the type as function
                                symbol* funcData = present_symbol_table->lookup($$->name, $$->type);
                                symbol_table* funcTable = new symbol_table();
                                funcData->nestedTable = funcTable;
                                vector<param*> paramList = *($3);   // Get the parameter list
                                for(int i = 0; i < (int)paramList.size(); i++) {
                                    param* curParam = paramList[i];
                                    if(curParam->type.type == data_type_array) {         // for parameter as an array
                                        funcTable->lookup(curParam->name, curParam->type.type);
                                        funcTable->lookup(curParam->name)->type.nextType = data_type_integer;
                                        funcTable->lookup(curParam->name)->type.dimension_vector.push_back(0);
                                    }
                                    else if(curParam->type.type == data_type_pointer) {   // for pointer parameter
                                        funcTable->lookup(curParam->name, curParam->type.type);
                                        funcTable->lookup(curParam->name)->type.nextType = data_type_integer;
                                        funcTable->lookup(curParam->name)->type.dimension_vector.push_back(0);
                                    }
                                    else                                        // simple parameter
                                        funcTable->lookup(curParam->name, curParam->type.type);
                                }
                                present_symbol_table = funcTable;         // symbol table is the function symbol table
                                emit($$->name, "", "", FUNC_BEG);
                            }
                        |   direct_declarator symbol_open_bracket identifier_list symbol_closed_bracket
                            { 
                                //printf("Line: %d,\t direct_declarator :--> direct_declarator symbol_open_bracket identifier_list_opt symbol_closed_bracket\n",line_count); 
                            }
                        ;
parameter_type_list_opt :   parameter_type_list
                            {
                                //printf("Line: %d,\t parameter_type_list_opt :--> parameter_type_list\n",line_count);
                            }
                        |
                            {
                                $$ = new vector<param*>;
                            }
                            ;
pointer                 :   symbol_star type_qualifier_list
                            { 
                                //printf("Line: %d,\t pointer :--> symbol_star type_qualifier_list_opt\n",line_count);
                            }
                        |   symbol_star
                            {
                                //printf("Line: %d,\t pointer :--> symbol_star \n",line_count);
                                $$ = 1;
                            }
                        |   symbol_star type_qualifier_list pointer
                            { 
                                //printf("Line: %d,\t pointer :--> symbol_star type_qualifier_list_opt pointer\n",line_count);
                                //  $$ = new symbol_type("ptr", $3); //  Create new new symbol of pointer type
                            }
                        |   symbol_star pointer
                            {
                                $$ = 1 + $2;
                            }
                        ;
type_qualifier_list     :   type_qualifier
                            { 
                                //printf("Line: %d,\t type_qualifier_list :--> type_qualifier\n",line_count); 
                            }
                        |   type_qualifier_list type_qualifier
                            { 
                                //printf("Line: %d,\t type_qualifier_list :--> type_qualifier_list type_qualifier\n",line_count); 
                            }
                        ;
parameter_type_list     :   parameter_list
                            { 
                                //printf("Line: %d,\t parameter_type_list :--> parameter_list\n",line_count); 
                            }
                        |   parameter_list symbol_comma symbol_threedot
                            { 
                                //printf("Line: %d,\t parameter_type_list :--> parameter_list symbol_comma symbol_threedot\n",line_count); 
                            }
                        ;
parameter_list          :   parameter_declaration
                            { 
                                //printf("Line: %d,\t parameter_list :--> parameter_declaration\n",line_count);
                                $$ = new vector<param*>;         // create a new vector of parameters
                                $$->push_back($1);              // Add the parameter to the vector 
                            }
                        |   parameter_list symbol_comma parameter_declaration
                            { 
                                //printf("Line: %d,\t parameter_list :--> parameter_list symbol_comma parameter_declaration\n",line_count);
                                $1->push_back($3);              // Add the parameter to the vector
                                $$ = $1; 
                            }
                        ;
parameter_declaration   :   declaration_specifiers declarator
                            { 
                                //printf("Line: %d,\t parameter_declaration :--> declaration_specifiers declarator\n",line_count);
                                // declaring the attributes of the parameter
                                $$ = new param();
                                $$->name = $2->name;
                                if($2->type == data_type_array) {
                                    $$->type.type = data_type_array;
                                    $$->type.nextType = $1;
                                }
                                else if($2->pc != 0) {
                                    $$->type.type = data_type_pointer;
                                    $$->type.nextType = $1;
                                }
                                else
                                    $$->type.type = $1; 
                            }
                        |   declaration_specifiers
                            { 
                                //printf("Line: %d,\t parameter_declaration :--> declaration_specifiers\n",line_count); 
                            }
                        ;
identifier_list         :   identifier
                            { 
                                //printf("Line: %d,\t identifier_list :--> identifier\n",line_count); 
                            }
                        |   identifier_list symbol_comma identifier
                            { 
                                //printf("Line: %d,\t identifier_list :--> identifier_list symbol_comma identifier\n",line_count); 
                            }
                        ;
type_name               :  specifier_qualifier_list
                            { 
                                //printf("Line: %d,\t type_name :--> specifier_qualifier_list\n",line_count); 
                            }
                        ;
initializer             :   assignment_expression
                            { 
                                //printf("Line: %d,\t initializer :--> assignment_expression\n",line_count);
                                $$ = $1; 
                            }
                        |   symbol_open_curly_bracket initializer_list symbol_closed_curly_bracket
                            { 
                                //printf("Line: %d,\t initializer :--> symbol_open_curly_bracket initializer_list symbol_closed_curly_bracket\n",line_count); 
                            }
                        |   symbol_open_curly_bracket initializer_list symbol_comma symbol_closed_curly_bracket
                            { 
                                //printf("Line: %d,\t initializer :--> symbol_open_curly_bracket initializer_list symbol_comma symbol_closed_curly_bracket\n",line_count); 
                            }
                        ;
initializer_list        :   designation_opt initializer
                            { 
                                //printf("Line: %d,\t initializer_list :--> designation_opt initializer\n",line_count); 
                            }
                        |   initializer_list symbol_comma designation_opt initializer
                            { 
                                //printf("Line: %d,\t initializer_list :--> initializer_list symbol_comma designation_opt initializer\n",line_count); 
                            }
                        ;
designation             :   designator_list symbol_equal
                            { 
                                //printf("Line: %d,\t designation :--> designator_list symbol_equal\n",line_count); 
                            }
                        ;
designator_list         :   designator
                            { 
                                //printf("Line: %d,\t designator_list :--> designator\n",line_count); 
                            }
                        |   designator_list designator
                            { 
                                //printf("Line: %d,\t designator_list :--> designator_list designator\n",line_count); 
                            }
                        ;
designator              :   symbol_open_square_bracket constant_expression symbol_closed_square_bracket
                            { 
                                //printf("Line: %d,\t designator_list :--> designator\n",line_count); 
                            }
                        |   symbol_dot identifier
                            { 
                                //printf("Line: %d,\t designator :--> symbol_dot identifier\n",line_count); 
                            }
                        ;

/*  Expressions   

*/

primary_expression      :   identifier
                            { 
                                //printf("Line: %d,\t primary_expression :--> identifier\n",line_count);
                                $$ = new expression();
                                string s = *($1);
                                present_symbol_table->lookup(s);
                                $$->loc = s;
                                // create a new expression and then storing it's pointer of the symbol table or the location in the symbol table 
                            }

                        |   integer_constant
                            {
                                //printf("Line: %d,\t primary_expression :--> integer_constant\n",line_count);
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp(data_type_integer);
                                emit($$->loc, $1, ASSIGN);
                                symbol_value* val = new symbol_value();
                                val->setInitVal($1);
                                present_symbol_table->lookup($$->loc)->initVal = val;
                                // create a new expression and then storing it's pointer of the symbol table or the location in the symbol table 
                            }
                        |   float_constant
                            {
                                //printf("Line: %d,\t primary_expression :--> float_constant\n",line_count);
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp(data_type_float);
                                emit($$->loc, $1, ASSIGN);
                                symbol_value* val = new symbol_value();
                                val->setInitVal($1);
                                present_symbol_table->lookup($$->loc)->initVal = val;
                                // create a new expression and then storing it's pointer of the symbol table or the location in the symbol table 
                            }
                        |   char_constant
                            {
                                //printf("Line: %d,\t primary_expression :--> char_constant\n",line_count);
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp(data_type_char);
                                emit($$->loc, $1, ASSIGN);
                                symbol_value* val = new symbol_value();
                                val->setInitVal($1);
                                present_symbol_table->lookup($$->loc)->initVal = val;
                                // create a new expression and then storing it's pointer of the symbol table or the location in the symbol table 
                            }
                        |   string_constant
                            { 
                                //printf("Line: %d,\t primary_expression :--> string_constant\n",line_count); 

                                /*For constants 
                                E.loc = gentemp();
                                here we are assigning the pointer of string to the expression
                                */

                                $$ = new expression();                  // Create new expression
                                $$->loc = ".LC" + to_string(strCount++);
                                string_storage.push_back(*($1));            // Create a new temporary, and store the value in that temporary

                            }
                        |   symbol_open_bracket expression symbol_closed_bracket
                            { 
                                //printf("Line: %d,\t primary_expression :--> symbol_open_bracket expression symbol_closed_bracket\n",line_count); 

                                /*
                                 E.loc = E1.loc;
                                 for paranthesized declarations of Expressions
                                 */
                                 $$ = $2;
                            }
                        ;   
postfix_expression      :   primary_expression
                            { 
                                //printf("Line: %d,\t postfix_expression :--> primary_expression\n",line_count); 
                            }
                        |   postfix_expression symbol_open_square_bracket expression symbol_closed_square_bracket
                            { 
                                //printf("Line: %d,\t postfix_expression :--> postfix_expression symbol_open_square_bracket expression symbol_closed_square_bracket\n",line_count); 
                                symbol_type to = present_symbol_table->lookup($1->loc)->type;      // Store type of the expression
                                string f = "";
                                if(!($1->fold)) {
                                    f = present_symbol_table->gentemp(data_type_integer);                       // generate a new temporary variable
                                    emit(f, 0, ASSIGN);
                                    $1->folder = new string(f);
                                }
                                string temp = present_symbol_table->gentemp(data_type_integer);

                                // Emit the necessary quads
                                emit(temp, $3->loc, "", ASSIGN);
                                emit(temp, temp, "4", MULT);
                                emit(f, temp, "", ASSIGN);
                                $$ = $1;
                            }
                        |   postfix_expression symbol_open_bracket argument_expression_list symbol_closed_bracket
                            { 
                                //printf("Line: %d,\t postfix_expression :--> postfix_expression symbol_open_bracket argument_expression_list_opt symbol_closed_bracket\n",line_count);
                                // it is used for giving parameters to the function calling
                                symbol_table* funcTable = global_symbol_table.lookup($1->loc)->nestedTable;
                                vector<param*> parameters = *($3);                          // get all the parameters
                                vector<symbol*> paramsList = funcTable->symbols;

                                for(int i = 0; i < (int)parameters.size(); i++) {
                                    emit(parameters[i]->name, "", "", PARAM);
                                }

                                data_type retType = funcTable->lookup("RETVAL")->type.type;           // add the entry in the symbol table for returning value
                                if(retType == data_type_void)                                         // If the function returns void
                                    emit($1->loc, (int)parameters.size(), CALL);
                                else {                                                                // If the function returns a value
                                    string retVal = present_symbol_table->gentemp(retType);
                                    emit($1->loc, to_string(parameters.size()), retVal, CALL);
                                    $$ = new expression();
                                    $$->loc = retVal;
                                }
                            }
                        |   postfix_expression symbol_open_bracket symbol_closed_bracket
                            { 
                                //printf("Line: %d,\t postfix_expression :--> postfix_expression symbol_open_bracket argument_expression_list_opt symbol_closed_bracket\n",line_count);
                                // it is used for giving parameters to the function calling
                                symbol_table* funcTable = global_symbol_table.lookup($1->loc)->nestedTable;
                                emit($1->loc, "0", "", CALL);
                            }
                        |   postfix_expression symbol_dot identifier
                            { 
                                //printf("Line: %d,\t postfix_expression :--> postfix_expression symbol_dot identifier\n",line_count); 
                            }
                        |   postfix_expression symbol_dash_greater identifier
                            {
                                //printf("Line: %d,\t postfix_expression :--> postfix_expression symbol_dash_greater identifier\n",line_count); 
                            }
                        |   postfix_expression symbol_double_plus
                            {
                                //printf("Line: %d,\t postfix_expression :--> postfix_expression symbol_double_plus\n",line_count); 
                                $$ = new expression();                                                             // Generate new expression
                                symbol_type t = present_symbol_table->lookup($1->loc)->type;                       // Get the type of the expression and generate a temporary variable
                                if(t.type == data_type_array) {                                                    // If type is array
                                    $$->loc = present_symbol_table->gentemp(present_symbol_table->lookup($1->loc)->type.nextType);
                                    emit($$->loc, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    string temp = present_symbol_table->gentemp(t.nextType);
                                    emit(temp, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    emit(temp, temp, "1", ADD);
                                    emit($1->loc, temp, *($1->folder), ARR_IDX_RES);
                                }
                                else {                                                                             // If type is number
                                    $$->loc = present_symbol_table->gentemp(present_symbol_table->lookup($1->loc)->type.type);
                                    emit($$->loc, $1->loc, "", ASSIGN);                         // Assign the old value 
                                    emit($1->loc, $1->loc, "1", ADD);                           // Increment the value
                                }
                            }
                        |   postfix_expression symbol_double_minus
                            {
                                //printf("Line: %d,\t postfix_expression :--> postfix_expression symbol_double_minus\n",line_count); 
                                $$ = new expression();                                          // Generate new expression
                                $$->loc = present_symbol_table->gentemp(present_symbol_table->lookup($1->loc)->type.type);          
                                symbol_type t = present_symbol_table->lookup($1->loc)->type;                                        // Get the type of the expression and generate a temporary variable
                                if(t.type == data_type_array) {                                                                     // If type is array
                                    $$->loc = present_symbol_table->gentemp(present_symbol_table->lookup($1->loc)->type.nextType);
                                    string temp = present_symbol_table->gentemp(t.nextType);
                                    emit(temp, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    emit($$->loc, temp, "", ASSIGN);
                                    emit(temp, temp, "1", SUB);
                                    emit($1->loc, temp, *($1->folder), ARR_IDX_RES);
                                }
                                else {                                                                                              // If type is number
                                    $$->loc = present_symbol_table->gentemp(present_symbol_table->lookup($1->loc)->type.type);
                                    emit($$->loc, $1->loc, "", ASSIGN);                         // Assign the old value
                                    emit($1->loc, $1->loc, "1", SUB);                           // Decrement the value
                                }
                            }
                        |   symbol_open_bracket type_name symbol_closed_bracket symbol_open_curly_bracket initializer_list symbol_closed_curly_bracket
                            {
                                //printf("Line: %d,\t postfix_expression :--> symbol_open_bracket type_name symbol_closed_bracket symbol_open_curly_bracket initializer_list symbol_closed_curly_bracket\n",line_count); 
                            }
                        |   symbol_open_bracket type_name symbol_closed_bracket symbol_open_curly_bracket initializer_list symbol_comma symbol_closed_curly_bracket
                            {
                                //printf("Line: %d,\t postfix_expression :--> symbol_open_bracket type_name symbol_closed_bracket symbol_open_curly_bracket initializer_list symbol_comma symbol_closed_curly_bracket\n",line_count); 
                            }
                        ;


argument_expression_list:   assignment_expression
                            { 
                                //printf("Line: %d,\t argument_expression_list :--> assignment_expression\n",line_count); 
                                param* first = new param();                 // Create a new parameter
                                first->name = $1->loc;
                                first->type = present_symbol_table->lookup($1->loc)->type;
                                $$ = new vector<param*>;
                                $$->push_back(first);                       // Add the parameter into the list
                            }
                        |   argument_expression_list symbol_comma assignment_expression
                            { 
                                //printf("Line: %d,\t argument_expression_list :--> argument_expression_list symbol_comma assignment_expression\n",line_count);
                                param* next = new param();                  // Create a new parameter
                                next->name = $3->loc;
                                next->type = present_symbol_table->lookup(next->name)->type;
                                $$ = $1;
                                $$->push_back(next);                        // Add the parameter into the list
                            }
                        ;
unary_expression        :   postfix_expression
                            { 
                                //printf("Line: %d,\t unary_expression :--> postfix_expression\n",line_count); 
                                $$ = $1;
                            }
                        |   symbol_double_plus unary_expression
                            { 
                                //printf("Line: %d,\t unary_expression :--> symbol_double_plus unary_expression\n",line_count); 
                                $$ = new expression();                                                  // Generate new expression
                                symbol_type type = present_symbol_table->lookup($2->loc)->type;         // Get the type of the expression and generate a temporary variable
                                if(type.type == data_type_array) {                                      // If type is array
                                    string t = present_symbol_table->gentemp(type.nextType);
                                    emit(t, $2->loc, *($2->folder), ARR_IDX_ARG);
                                    emit(t, t, "1", ADD);
                                    emit($2->loc, t, *($2->folder), ARR_IDX_RES);
                                    $$->loc = present_symbol_table->gentemp(present_symbol_table->lookup($2->loc)->type.nextType);
                                }
                                else {                                                                  // If type is number
                                    emit($2->loc, $2->loc, "1", ADD);                       // Increment the value
                                    $$->loc = present_symbol_table->gentemp(present_symbol_table->lookup($2->loc)->type.type);
                                }
                                $$->loc = present_symbol_table->gentemp(present_symbol_table->lookup($2->loc)->type.type);
                                emit($$->loc, $2->loc, "", ASSIGN);                         // Assign the value
                            }
                        |   symbol_double_minus unary_expression
                            { 
                                //printf("Line: %d,\t unary_expression :--> symbol_double_minus unary_expression\n",line_count); 
                                $$ = new expression();                                                  // Generate new expression
                                symbol_type type = present_symbol_table->lookup($2->loc)->type;         // Get the type of the expression and generate a temporary variable
                                if(type.type == data_type_array) {                                      // If type is array
                                    string t = present_symbol_table->gentemp(type.nextType);
                                    emit(t, $2->loc, *($2->folder), ARR_IDX_ARG);
                                    emit(t, t, "1", SUB);
                                    emit($2->loc, t, *($2->folder), ARR_IDX_RES);
                                    $$->loc = present_symbol_table->gentemp(present_symbol_table->lookup($2->loc)->type.nextType);
                                }
                                else {                                                                  //If type is number
                                    emit($2->loc, $2->loc, "1", SUB);                       // Decrement the value
                                    $$->loc = present_symbol_table->gentemp(present_symbol_table->lookup($2->loc)->type.type);
                                }
                                emit($$->loc, $2->loc, "", ASSIGN);                         // Assign the value
                            }
                        |   symbol_unary_operator cast_expression
                            { 
                                //printf("Line: %d,\t unary_expression :--> symbol_unary_operator cast_expression\n",line_count); 
                                // Case of unary operator
                                switch($1) {
                                    case '&':   // Address
                                        $$ = new expression();
                                        $$->loc = present_symbol_table->gentemp(data_type_pointer);                 // Generate temporary of the same base type
                                        emit($$->loc, $2->loc, "", REFERENCE);          // Emit the quad
                                        break;
                                    case '*':   // De-referencing
                                        $$ = new expression();
                                        $$->loc = present_symbol_table->gentemp(data_type_integer);                     // Generate temporary of the same base type
                                        $$->fold = 1;
                                        $$->folder = new string($2->loc);
                                        emit($$->loc, $2->loc, "", DEREFERENCE);        // Emit the quad
                                        break;
                                    case '-':   // Unary minus
                                        $$ = new expression();
                                        $$->loc = present_symbol_table->gentemp();                        // Generate temporary of the same base type
                                        emit($$->loc, $2->loc, "", U_MINUS);            // Emit the quad
                                        break;
                                    case '!':   // Logical not 
                                        $$ = new expression();
                                        $$->loc = present_symbol_table->gentemp(data_type_integer);                     // Generate temporary of the same base type
                                        int temp = nextinstr + 2;
                                        emit(to_string(temp), $2->loc, "0", GOTO_EQ);   // Emit the quads
                                        temp = nextinstr + 3;
                                        emit(to_string(temp), "", "", GOTO);
                                        emit($$->loc, "1", "", ASSIGN);
                                        temp = nextinstr + 2;
                                        emit(to_string(temp), "", "", GOTO);
                                        emit($$->loc, "0", "", ASSIGN);
                                        break;
                                }
                            }
                        |   keyword_sizeof unary_expression
                            { 
                                //printf("Line: %d,\t unary_expression :--> keyword_sizeof unary_expression\n",line_count); 
                            }
                        |   keyword_sizeof symbol_open_bracket type_name symbol_closed_bracket
                            { 
                                //printf("Line: %d,\t unary_expression :--> keyword_sizeof symbol_open_bracket type_name symbol_closed_bracket\n",line_count); 
                            }
                        ;


symbol_unary_operator   :   symbol_and
                            { 
                                //printf("Line: %d,\t symbol_unary_operator :--> symbol_and\n",line_count);
                                $$ = '&';
                            }
                        |   symbol_star
                            { 
                                //printf("Line: %d,\t symbol_unary_operator :--> symbol_star\n",line_count);
                                $$ = '*';
                            }
                        |   symbol_plus
                            { 
                                //printf("Line: %d,\t symbol_unary_operator :--> symbol_plus\n",line_count);
                               $$ = '+';
                            }
                        |   symbol_minus
                            { 
                                //printf("Line: %d,\t symbol_unary_operator :--> symbol_minus\n",line_count);
                               $$ = '-'; 
                            }
                        |   symbol_tilda
                            { 
                                //printf("Line: %d,\t symbol_unary_operator :--> symbol_tilda\n",line_count);
                               $$ = '~'; 
                            }
                        |   symbol_exclamation
                            { 
                                //printf("Line: %d,\t symbol_unary_operator :--> symbol_exclamation\n",line_count);
                                $$ = '!';
                            }
                        ;
cast_expression         :   unary_expression
                            { 
                                //printf("Line: %d,\t cast_expression :--> unary_expression\n",line_count);
                            }
                        |   symbol_open_bracket type_name symbol_closed_bracket cast_expression
                            { 
                                //printf("Line: %d,\t unary_expression :--> symbol_open_bracket type_name symbol_closed_bracket cast_expression\n",line_count);
                            }
                        ;
multiplicative_expression:  cast_expression
                            { 
                                //printf("Line: %d,\t multiplicative_expression :--> cast_expression\n",line_count);
                                $$ = new expression();                                  // Generate new expression
                                symbol_type tp = present_symbol_table->lookup($1->loc)->type;
                                if(tp.type == data_type_array) {                                  // If the type is an array
                                    string t = present_symbol_table->gentemp(tp.nextType);                // Generate a temporary
                                    if($1->folder != NULL) {
                                        emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);   // Emit the necessary quad
                                        $1->loc = t;
                                        $1->type = tp.nextType;
                                        $$ = $1;
                                    }
                                    else
                                        $$ = $1;        // Simple assignment
                                }
                                else
                                    $$ = $1;            // Simple assignment
                            }
                        |   multiplicative_expression symbol_star cast_expression
                            { 
                                //printf("Line: %d,\t multiplicative_expression :--> multiplicative_expression symbol_star cast_expression\n",line_count);
                                // Indicates multiplication
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand 
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand 
                                if(two->type.type == data_type_array) {             // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {              // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }

                                // Assign the result of the multiplication to the higher data type
                                data_type final = ((one->type.type > two->type.type) ? (one->type.type) : (two->type.type));
                                $$->loc = present_symbol_table->gentemp(final);                       // Store the final result in a temporary
                                emit($$->loc, $1->loc, $3->loc, MULT);
                            }
                        |   multiplicative_expression symbol_divide cast_expression
                            { 
                                //printf("Line: %d,\t multiplicative_expression :--> multiplicative_expression symbol_divide cast_expression\n",line_count);
                                // Indicates division
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }

                                // Assign the result of the division to the higher data type
                                data_type final = ((one->type.type > two->type.type) ? (one->type.type) : (two->type.type));
                                $$->loc = present_symbol_table->gentemp(final);                       // Store the final result in a temporary
                                emit($$->loc, $1->loc, $3->loc, DIV);
                            }
                        |   multiplicative_expression symbol_modulo cast_expression
                            { 
                                //printf("Line: %d,\t multiplicative_expression :--> multiplicative_expression symbol_modulo cast_expression\n",line_count);
                                // Indicates modulo
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }

                                // Assign the result of the modulo to the higher data type
                                data_type final = ((one->type.type > two->type.type) ? (one->type.type) : (two->type.type));
                                $$->loc = present_symbol_table->gentemp(final);                       // Store the final result in a temporary
                                emit($$->loc, $1->loc, $3->loc, MOD);
                            }
                        ;
additive_expression     :   multiplicative_expression
                            { 
                                //printf("Line: %d,\t additive_expression :--> multiplicative_expression\n",line_count); 
                                // $$ = $1;    
                            }
                        |   additive_expression symbol_plus multiplicative_expression
                            { 
                                //printf("Line: %d,\t additive_expression :--> additive_expression symbol_plus multiplicative_expression\n",line_count);
                                // Indicates addition
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }

                                // Assign the result of the addition to the higher data type
                                data_type final = ((one->type.type > two->type.type) ? (one->type.type) : (two->type.type));
                                $$->loc = present_symbol_table->gentemp(final);                       // Store the final result in a temporary
                                emit($$->loc, $1->loc, $3->loc, ADD);
                            }
                        |   additive_expression symbol_minus multiplicative_expression
                            { 
                                //printf("Line: %d,\t additive_expression :--> additive_expression symbol_minus multiplicative_expression\n",line_count);
                                // Indicates subtraction
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }

                                // Assign the result of the subtraction to the higher data type
                                data_type final = ((one->type.type > two->type.type) ? (one->type.type) : (two->type.type));
                                $$->loc = present_symbol_table->gentemp(final);                       // Store the final result in a temporary
                                emit($$->loc, $1->loc, $3->loc, SUB);
                            }
                        ;
shift_expression        :   additive_expression
                            { 
                                //printf("Line: %d,\t shift_expression :--> additive_expression\n",line_count);
                                // $$ = $1;    // Simple assignment
                            }
                        |   shift_expression symbol_leftshift additive_expression
                            { 
                                //printf("Line: %d,\t shift_expression :--> shift_expression symbol_leftshift additive_expression\n",line_count);
                                // Indicates left shift
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }
                                $$->loc = present_symbol_table->gentemp(one->type.type);              // Assign the result of the left shift to the data type of the left operand
                                emit($$->loc, $1->loc, $3->loc, SL);
                            }
                        |   shift_expression symbol_rightshift additive_expression
                            { 
                                //printf("Line: %d,\t shift_expression :--> shift_expression symbol_rightshift additive_expression\n",line_count); 
                                // Indicates right shift
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }
                                $$->loc = present_symbol_table->gentemp(one->type.type);              // Assign the result of the right shift to the data type of the left operand
                                emit($$->loc, $1->loc, $3->loc, SR);
                            }
                        ;

relational_expression   :   shift_expression
                            { 
                                //printf("Line: %d,\t relational_expression :--> shift_expression\n",line_count);
                            }
                        |   relational_expression symbol_less shift_expression
                            { 
                                //printf("Line: %d,\t relational_expression :--> relational_expression symbol_less shift_expression\n",line_count);
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp();
                                $$->type = data_type_bool;                                    // Assign the result of the relational expression to a boolean
                                emit($$->loc, "1", "", ASSIGN);
                                $$->truelist = makelist(nextinstr);                 // Set the truelist to the next instruction
                                emit("", $1->loc, $3->loc, GOTO_LT);                
                                emit($$->loc, "0", "", ASSIGN);
                                $$->falselist = makelist(nextinstr);                // Set the falselist to the next instruction
                                emit("", "", "", GOTO);                             
                            }
                        |   relational_expression symbol_greater shift_expression
                            { 
                                //printf("Line: %d,\t relational_expression :--> relational_expression symbol_greater shift_expression\n",line_count);
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp();
                                $$->type = data_type_bool;                                    // Assign the result of the relational expression to a boolean
                                emit($$->loc, "1", "", ASSIGN);
                                $$->truelist = makelist(nextinstr);                 // Set the truelist to the next instruction
                                emit("", $1->loc, $3->loc, GOTO_GT);                
                                emit($$->loc, "0", "", ASSIGN);
                                $$->falselist = makelist(nextinstr);                // Set the falselist to the next instruction
                                emit("", "", "", GOTO);                             
                            }
                        |   relational_expression symbol_lesseq shift_expression
                            { 
                                //printf("Line: %d,\t relational_expression :--> relational_expression symbol_lesseq shift_expression\n",line_count); 
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp();
                                $$->type = data_type_bool;                                    // Assign the result of the relational expression to a boolean
                                emit($$->loc, "1", "", ASSIGN);
                                $$->truelist = makelist(nextinstr);                 // Set the truelist to the next instruction
                                emit("", $1->loc, $3->loc, GOTO_LTE);               // Emit "if x <= y goto ..."
                                emit($$->loc, "0", "", ASSIGN);
                                $$->falselist = makelist(nextinstr);                // Set the falselist to the next instruction
                                emit("", "", "", GOTO);                             // Emit "goto ..."
                            }
                        |   relational_expression symbol_greatereq shift_expression
                            { 
                                //printf("Line: %d,\t relational_expression :--> relational_expression symbol_greatereq shift_expression\n",line_count);
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp();
                                $$->type = data_type_bool;                                    // Assign the result of the relational expression to a boolean
                                emit($$->loc, "1", "", ASSIGN);
                                $$->truelist = makelist(nextinstr);                 // Set the truelist to the next instruction
                                emit("", $1->loc, $3->loc, GOTO_GTE);               // Emit "if x >= y goto ..."
                                emit($$->loc, "0", "", ASSIGN);
                                $$->falselist = makelist(nextinstr);                // Set the falselist to the next instruction
                                emit("", "", "", GOTO);                             // Emit "goto ..."
                            }
                        ;
equality_expression     :   relational_expression
                            { 
                                //printf("Line: %d,\t equality_expression :--> relational_expression\n",line_count);
                                $$ = new expression();
                                $$ = $1;                // Simple assignment 
                            }
                        |   equality_expression symbol_doubleeq relational_expression
                            { 
                                //printf("Line: %d,\t equality_expression :--> equality_expression symbol_doubleeq relational_expression\n",line_count);
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp();
                                $$->type = data_type_bool;                                    // Assign the result of the relational expression to a boolean
                                emit($$->loc, "1", "", ASSIGN);
                                $$->truelist = makelist(nextinstr);                 // Set the truelist to the next instruction
                                emit("", $1->loc, $3->loc, GOTO_EQ);                // Emit "if x == y goto ..."
                                emit($$->loc, "0", "", ASSIGN);
                                $$->falselist = makelist(nextinstr);                // Set the falselist to the next instruction
                                emit("", "", "", GOTO);                             // Emit "goto ..."
                            }
                        |   equality_expression symbol_noteq relational_expression
                            { 
                                //printf("Line: %d,\t equality_expression :--> equality_expression symbol_noteq relational_expression\n",line_count);
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp();
                                $$->type = data_type_bool;                                    // Assign the result of the relational expression to a boolean
                                emit($$->loc, "1", "", ASSIGN);
                                $$->truelist = makelist(nextinstr);                 // Set the truelist to the next instruction
                                emit("", $1->loc, $3->loc, GOTO_NEQ);               // Emit "if x != y goto ..."
                                emit($$->loc, "0", "", ASSIGN);
                                $$->falselist = makelist(nextinstr);                // Set the falselist to the next instruction
                                emit("", "", "", GOTO);                             // Emit "goto ..."
                            }
                        ;
AND_expression          :   equality_expression
                            { 
                                //printf("Line: %d,\t AND_expression :--> equality_expression\n",line_count);
                            }
                        |   AND_expression symbol_and equality_expression
                            { 
                                //printf("Line: %d,\t AND_expression :--> AND_expression symbol_and equality_expression\n",line_count);
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp();                            // Create a temporary variable to store the result
                                emit($$->loc, $1->loc, $3->loc, BW_AND);            // Emit the quad
                            }
                        ;
exclusive_OR_expression :   AND_expression
                            { 
                                //printf("Line: %d,\t exclusive_OR_expression :--> AND_expression\n",line_count); 
                                $$ = $1;
                            }
                        |   exclusive_OR_expression symbol_xor AND_expression 
                            { 
                                //printf("Line: %d,\t exclusive_OR_expression :--> exclusive_OR_expression symbol_xor AND_expression\n",line_count);
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp();                            // Create a temporary variable to store the result
                                emit($$->loc, $1->loc, $3->loc, BW_XOR);            // Emit the quad
                            }
                        ;
inclusive_OR_expression :   exclusive_OR_expression
                            { 
                                //printf("Line: %d,\t inclusive_OR_expression :--> exclusive_OR_expression\n",line_count);
                                $$ = $1; 
                            }
                        |   inclusive_OR_expression symbol_oneor exclusive_OR_expression
                            { 
                                //printf("Line: %d,\t inclusive_OR_expression :--> inclusive_OR_expression symbol_oneor exclusive_OR_expression\n",line_count);
                                $$ = new expression();
                                symbol* one = present_symbol_table->lookup($1->loc);                  // Get the first operand
                                symbol* two = present_symbol_table->lookup($3->loc);                  // Get the second operand
                                if(two->type.type == data_type_array) {                       // If the second operand is an array
                                    string t = present_symbol_table->gentemp(two->type.nextType);
                                    emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                                    $3->loc = t;
                                    $3->type = two->type.nextType;
                                }
                                if(one->type.type == data_type_array) {                       // If the first operand is an array
                                    string t = present_symbol_table->gentemp(one->type.nextType);
                                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                                    $1->loc = t;
                                    $1->type = one->type.nextType;
                                }
                                $$ = new expression();
                                $$->loc = present_symbol_table->gentemp();                            // Create a temporary variable to store the result
                                emit($$->loc, $1->loc, $3->loc, BW_OR);             // Emit the quad
                            }
                        ;
M                       :  
                            {
                                //printf("Line: %d,\t M :--> epsilon\n",line_count);
                                $$ = new expression();
                                $$->instr = nextinstr;
                            }   
                        ;

N                       : 
                            {
                                //printf("Line: %d,\t M :--> epsilon\n",line_count);
                                $$ = new expression();
                                $$->nextlist = makelist(nextinstr);
                                emit("", "", "", GOTO);
                            }
                        ;

logical_AND_expression  :   inclusive_OR_expression
                            { 
                                //printf("Line: %d,\t logical_AND_expression :--> inclusive_OR_expression\n",line_count);
                                $$ = $1; 
                            }
                        |   logical_AND_expression symbol_doubleand M inclusive_OR_expression
                            { 
                                //printf("Line: %d,\t logical_AND_expression :--> logical_AND_expression symbol_doubleand inclusive_OR_expression\n",line_count);
                                /*
                                    augmented for && operations so that it goes to false directly whenever any one gets false and true only if both are true
                                */
                                backpatch($1->truelist, $3->instr);                     // Backpatching
                                $$->falselist = merge($1->falselist, $4->falselist);    // Generate falselist by merging the falselists of $1 and $4
                                $$->truelist = $4->truelist;                            // Generate truelist from truelist of $4
                                $$->type = data_type_bool;                                        // Set the type of the expression to boolean 
                            }
                        ;
logical_OR_expression   :   logical_AND_expression
                            { 
                                //printf("Line: %d,\t logical_OR_expression :--> logical_AND_expression\n",line_count);
                            }
                        |   logical_OR_expression symbol_doubleor M logical_AND_expression     
                            { 
                                //printf("Line: %d,\t logical_OR_expression :--> logical_OR_expression symbol_doubleor logical_AND_expression\n",line_count);
                                /*
                                    augmented for || operations so that it goes to true directly whenever any one gets true and false only if both are true
                                */
                                backpatch($1->falselist, $3->instr);                    // Backpatching
                                $$->truelist = merge($1->truelist, $4->truelist);       // Generate falselist by merging the falselists of $1 and $4
                                $$->falselist = $4->falselist;                          // Generate truelist from truelist of $4
                                $$->type = data_type_bool;                                        // Set the type of the expression to boolean
                            }
                        ;
conditional_expression  :   logical_OR_expression
                            { 
                                //printf("Line: %d,\t conditional_expression :--> logical_OR_expression\n",line_count);
                                $$ = $1; 
                            }
                        |   logical_OR_expression N symbol_question M expression N symbol_colon M conditional_expression
                            { 
                                //printf("Line: %d,\t conditional_expression :--> logical_OR_expression symbol_question expression symbol_colon conditional_expression\n",line_count);
                                
                                symbol* one = present_symbol_table->lookup($5->loc);
                                $$->loc = present_symbol_table->gentemp(one->type.type);      // Create a temporary for the expression
                                $$->type = one->type.type;
                                emit($$->loc, $9->loc, "", ASSIGN);         // Assign the conditional expression
                                list<int> temp = makelist(nextinstr);
                                emit("", "", "", GOTO);                     // Prevent fall-through
                                backpatch($6->nextlist, nextinstr);         // Backpatch with nextinstr
                                emit($$->loc, $5->loc, "", ASSIGN);
                                temp = merge(temp, makelist(nextinstr));
                                emit("", "", "", GOTO);                     // Prevent fall-through
                                backpatch($2->nextlist, nextinstr);         // Backpatch with nextinstr
                                convertIntToBool($1);                       // Convert the expression to boolean
                                backpatch($1->truelist, $4->instr);         // When $1 is true, control goes to $4 (expression)
                                backpatch($1->falselist, $8->instr);        // When $1 is false, control goes to $8 (conditional_expression)
                                backpatch($2->nextlist, nextinstr);         // Backpatch with nextinstr
                            }
                        ;
assignment_expression   :   conditional_expression
                            { 
                                //printf("Line: %d,\t assignment_expression :--> conditional_expression\n",line_count);
                                // $$ = $1; 
                            }
                        |   unary_expression assignment_operator assignment_expression
                            { 
                                //printf("Line: %d,\t assignment_expression :--> unary_expression assignment_operator assignment_expression\n",line_count);
                                symbol* sym1 = present_symbol_table->lookup($1->loc);         // Get the first operand
                                symbol* sym2 = present_symbol_table->lookup($3->loc);         // Get the second operand
                                if($1->fold == 0) {
                                    if(sym1->type.type != data_type_array)                    // If type is not array
                                        emit($1->loc, $3->loc, "", ASSIGN);
                                    else                                                      // If type is array
                                        emit($1->loc, $3->loc, *($1->folder), ARR_IDX_RES);
                                }
                                else
                                    emit(*($1->folder), $3->loc, "", L_DEREF);
                                $$ = $1;        // Assignment 
                            }
                        ;
assignment_operator     :   symbol_equal
                            { 
                                //printf("Line: %d,\t assignment_operator :--> symbol_equal\n",line_count); 
                            }
                        |   symbol_muleq
                            { 
                                //printf("Line: %d,\t assignment_operator :--> symbol_muleq\n",line_count); 
                            }
                        |   symbol_diveq
                            {
                                 //printf("Line: %d,\t assignment_operator :--> symbol_diveq\n",line_count); 
                            }
                        |   symbol_modeq
                            {
                                 //printf("Line: %d,\t assignment_operator :--> symbol_modeq\n",line_count); 
                            }
                        |   symbol_pluseq
                            {
                                 //printf("Line: %d,\t assignment_operator :--> symbol_pluseq\n",line_count); 
                            }
                        |   symbol_minuseq
                            {
                                 //printf("Line: %d,\t assignment_operator :--> symbol_minuseq\n",line_count); 
                            }
                        |   symbol_leftshifteq
                            {
                                 //printf("Line: %d,\t assignment_operator :--> symbol_leftshifteq\n",line_count); 
                            }
                        |   symbol_rightshifteq
                            {
                                 //printf("Line: %d,\t assignment_operator :--> symbol_rightshifteq\n",line_count); 
                            }
                        |   symbol_andeq
                            {
                                 //printf("Line: %d,\t assignment_operator :--> symbol_andeq\n",line_count); 
                            }
                        |   symbol_xoreq
                            {
                                 //printf("Line: %d,\t assignment_operator :--> symbol_xoreq\n",line_count); 
                            }
                        |   symbol_oreq
                            {
                                 //printf("Line: %d,\t assignment_operator :--> symbol_oreq\n",line_count); 
                            }
                        ;
expression              :   assignment_expression
                            {
                                 //printf("Line: %d,\t expression :--> assignment_expression\n",line_count); 
                                //  $$ = $1;
                            }
                        |   expression symbol_comma assignment_expression
                            {
                                 //printf("Line: %d,\t expression :--> expression symbol_comma assignment_expression\n",line_count);

                            }
                        ;
constant_expression     :   conditional_expression 
                            {
                                 //printf("Line: %d,\t constant_expression :--> conditional_expression\n",line_count); 
                            }
                        ;




expression_opt          :   expression
                            {
                                 //printf("Line: %d,\t expression_opt :--> expression\n",line_count);
                                //  $$ = $1; 
                            }
                        |
                            {
                                 //printf("Line: %d,\t expression_opt :--> epsilon\n",line_count);
                                //  $$ = new expression(); 
                            }
                        ;

declaration_specifiers_opt:     declaration_specifiers
                            { 
                                //printf("Line: %d,\t declaration_specifiers_opt :--> declaration_specifiers\n",line_count); 
                            }
                        |
                            {
                                 //printf("Line: %d,\t declaration_specifiers_opt :--> epsilon\n",line_count); 
                            }
                        ;

specifier_qualifier_list_opt    :   specifier_qualifier_list
                                    { 
                                        //printf("Line: %d,\t specifier_qualifier_list_opt :--> specifier_qualifier_list\n",line_count); 
                                    }
                                |
                                    { 
                                        //printf("Line: %d,\t specifier_qualifier_list_opt :--> epsilon\n",line_count); 
                                    }
                                ;
identifier_opt          :   identifier
                            { 
                                //printf("Line: %d,\t identifier_opt :--> identifier\n",line_count); 
                            }
                        |
                            {
                                //printf("Line: %d,\t identifier_opt :--> epsilon\n",line_count); 
                            }
                        ;
type_qualifier_list_opt :   type_qualifier_list
                            { 
                                //printf("Line: %d,\t type_qualifier_list_opt :--> type_qualifier_list\n",line_count); 
                            }
                        |
                            { 
                                //printf("Line: %d,\t type_qualifier_list_opt :--> epsilon\n",line_count); 
                            }
                        ;
designation_opt         :   designation
                            { 
                                //printf("Line: %d,\t designation_opt :--> designation\n",line_count); 
                            }
                        |
                            { 
                                //printf("Line: %d,\t designation_opt :--> epsilon\n",line_count); 
                            }
                        ;
argument_expression_list_opt: argument_expression_list
                            { 
                                //printf("Line: %d,\t argument_expression_list_opt :--> argument_expression_list\n",line_count); 
                                $$ = $1;
                            }
                        |
                            { 
                                //printf("Line: %d,\t argument_expression_list_opt :--> epsilon\n",line_count); 
                                $$ = 0;
                            }
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

void yyerror(char *s)
{
    printf("Line: %d, %s\n",line_count,s);
}
