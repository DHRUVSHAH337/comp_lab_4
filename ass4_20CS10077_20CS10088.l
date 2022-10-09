%{
 #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
%}




ID                          [a-zA-Z_][a-zA-Z0-9_]*

NON_ZERO_DIGIT              [1-9]
ZERO_INCLUDING_DIGIT        [0-9]
INT_CONSTANT                {NON_ZERO_DIGIT}{ZERO_INCLUDING_DIGIT}*|"0"

DECIMAL                     {ZERO_INCLUDING_DIGIT}*\.{ZERO_INCLUDING_DIGIT}+|{ZERO_INCLUDING_DIGIT}+\.
EXPONENTIAL                 ("E"|"e")("+"|"-")?{INT_CONSTANT}
FLOAT_CONSTANT              ({DECIMAL}|{ZERO_INCLUDING_DIGIT}{ZERO_INCLUDING_DIGIT}*)?{EXPONENTIAL}|{DECIMAL}

enumeration_constant        {IDENTIFIER}

ESCAPE_SEQ                  "\\\'"|"\\a"|"\\\""|"\\?"|"\\\\"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"
C_CHAR                      [^\n\\\']|{ESCAPE_SEQ}
C_CHAR_SEQ                  {C_CHAR}+
CHARACTER_CONSTANT          \'{C_CHAR_SEQ}\'

S_CHAR                      [^\n\\\"]|{ESCAPE_SEQ}
S_CHAR_SEQ                  {S_CHAR}+
STRING                      \"{S_CHAR_SEQ}?*\"


WS                          [ \t\n]

%x comment

%%
"auto"					{return keyword_auto; }
"enum"					{return keyword_enum; }
"restrict"				{return keyword_restrict; }
"unsigned"				{return keyword_unsigned; }
"break"					{return keyword_break; }
"extern"				{return keyword_extern; }
"return"				{return keyword_return; }
"void"					{return keyword_void; }
"case"					{return keyword_case; }
"float"					{return keyword_float; }
"short"					{return keyword_short; }
"volatile"				{return keyword_volatile; }
"char"					{return keyword_char; }
"for"					{return keyword_for; }
"signed"				{return keyword_signed; }
"while"					{return keyword_while; }
"const"					{return keyword_const; }
"goto"					{return keyword_goto; }
"sizeof"				{return	keyword_sizeof; }
"_Bool"					{return	keyword__Bool; }
"continue"				{return	keyword_continue; }
"if"					{return keyword_if; }
"static"				{return keyword_static; }
"_Complex"				{return keyword__Complex; }
"default"				{return keyword_default; }
"inline"				{return keyword_inline; }
"struct"				{return keyword_struct; }
"_Imaginary"			{return keyword__Imaginary; }
"do"					{return keyword_do; }
"int"					{return keyword_int; }
"switch"				{return keyword_switch; }
"double"				{return keyword_double; }
"long"					{return keyword_long; }
"typedef"				{return keyword_typedef; }
"else"					{return keyword_else; }
"register"				{return keyword_register; }
"union"					{return keyword_union; }

"["					    {return symbol_open_square_bracket; }
"]"					    {return symbol_closed_square_bracket; }
"("					    {return symbol_open_bracket; }
")"					    {return symbol_closed_bracket; }
"{"					    {return symbol_open_curly_bracket; }
"}"					    {return symbol_closed_curly_bracket; }
"\."					{return symbol_dot; }
"->"					{return symbol_dash_greater; }
"++"					{return symbol_double_plus; }
"--"					{return symbol_double_minus; }
"&"					    {return symbol_and; }
"*"					    {return symbol_star; }
"+"					    {return symbol_plus; }
"-"					    {return symbol_minus; }
"~"					    {return symbol_tilda; }
"!"					    {return symbol_exclamation; }
"/"					    {return symbol_divide; }
"%"					    {return symbol_modulo; }
"<<"					{return symbol_leftshift; }
">>"					{return symbol_rightshift; }
"<"					    {return symbol_less; }
">"					    {return symbol_greater; }
"<="					{return symbol_lesseq; }
">="					{return symbol_greatereq; }
"=="					{return symbol_doubleeq; }
"!="					{return symbol_noteq; }
"^"					    {return symbol_xor; }
"|"					    {return symbol_oneor; }
"&&"					{return symbol_doubleand; }
"||"					{return symbol_doubleor; }
"?"					    {return symbol_question; }
":"					    {return symbol_colon; }
";"					    {return symbol_semi_colon; }
"..."					{return symbol_threedot; }
"="					    {return symbol_equal; }
"*="					{return symbol_muleq; }
"/="					{return symbol_diveq; }
"%="					{return symbol_modeq; }
"+="					{return symbol_pluseq; }
"-="					{return symbol_minuseq; }
"<<="					{return symbol_leftshifteq; }
">>="					{return symbol_rightshifteq; }
"&="					{return symbol_andeq; }
"^="					{return symbol_xoreq; }
"|="					{return symbol_oreq; }
","					    {return symbol_comma; }
"#"					    {return symbol_hash; }

{ID}                    { return identifier; }

{INT_CONSTANT}          { return constant; }
{FLOAT_CONSTANT}        { return constant; }
{CHARACTER_CONSTANT}	 { return constant; }

{STRING}		 { return string_constant; }





"/*"					{BEGIN(comment);}
<comment>[^*\n]*
<comment>"*"+[^*/\n]*
<comment>\n
<comment>"*"+"/"		{BEGIN(INITIAL);}
\/\/(.)*		 {  }
{WS}			 {  }
.				 { return -1;}
%%

int yywrap(void){
	return (1);
}
