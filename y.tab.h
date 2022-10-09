/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    identifier = 258,
    constant = 259,
    string_constant = 260,
    symbol_colon = 261,
    symbol_closed_curly_bracket = 262,
    symbol_open_curly_bracket = 263,
    symbol_semi_colon = 264,
    symbol_closed_bracket = 265,
    symbol_open_bracket = 266,
    symbol_comma = 267,
    symbol_equal = 268,
    symbol_open_square_bracket = 269,
    symbol_closed_square_bracket = 270,
    symbol_star = 271,
    symbol_threedot = 272,
    symbol_dot = 273,
    symbol_dash_greater = 274,
    symbol_double_plus = 275,
    symbol_double_minus = 276,
    symbol_and = 277,
    symbol_plus = 278,
    symbol_minus = 279,
    symbol_tilda = 280,
    symbol_exclamation = 281,
    symbol_divide = 282,
    symbol_modulo = 283,
    symbol_leftshift = 284,
    symbol_rightshift = 285,
    symbol_less = 286,
    symbol_greater = 287,
    symbol_greatereq = 288,
    symbol_lesseq = 289,
    symbol_doubleeq = 290,
    symbol_noteq = 291,
    symbol_xor = 292,
    symbol_oneor = 293,
    symbol_doubleor = 294,
    symbol_question = 295,
    symbol_doubleand = 296,
    symbol_muleq = 297,
    symbol_diveq = 298,
    symbol_modeq = 299,
    symbol_pluseq = 300,
    symbol_minuseq = 301,
    symbol_leftshifteq = 302,
    symbol_rightshifteq = 303,
    symbol_xoreq = 304,
    symbol_andeq = 305,
    symbol_oreq = 306,
    symbol_hash = 307,
    keyword_if = 308,
    keyword_else = 309,
    keyword_switch = 310,
    keyword_while = 311,
    keyword_do = 312,
    keyword_for = 313,
    keyword_goto = 314,
    keyword_continue = 315,
    keyword_break = 316,
    keyword_return = 317,
    keyword_extern = 318,
    keyword_static = 319,
    keyword_auto = 320,
    keyword_register = 321,
    keyword_void = 322,
    keyword_char = 323,
    keyword_short = 324,
    keyword_int = 325,
    keyword_long = 326,
    keyword_float = 327,
    keyword_double = 328,
    keyword_signed = 329,
    keyword_unsigned = 330,
    keyword__Bool = 331,
    keyword__Complex = 332,
    keyword__Imaginary = 333,
    keyword_enum = 334,
    keyword_const = 335,
    keyword_restrict = 336,
    keyword_volatile = 337,
    keyword_inline = 338,
    keyword_sizeof = 339,
    keyword_default = 340,
    keyword_struct = 341,
    keyword_typedef = 342,
    keyword_union = 343,
    keyword_case = 344,
    enumeration_constant = 345
  };
#endif
/* Tokens.  */
#define identifier 258
#define constant 259
#define string_constant 260
#define symbol_colon 261
#define symbol_closed_curly_bracket 262
#define symbol_open_curly_bracket 263
#define symbol_semi_colon 264
#define symbol_closed_bracket 265
#define symbol_open_bracket 266
#define symbol_comma 267
#define symbol_equal 268
#define symbol_open_square_bracket 269
#define symbol_closed_square_bracket 270
#define symbol_star 271
#define symbol_threedot 272
#define symbol_dot 273
#define symbol_dash_greater 274
#define symbol_double_plus 275
#define symbol_double_minus 276
#define symbol_and 277
#define symbol_plus 278
#define symbol_minus 279
#define symbol_tilda 280
#define symbol_exclamation 281
#define symbol_divide 282
#define symbol_modulo 283
#define symbol_leftshift 284
#define symbol_rightshift 285
#define symbol_less 286
#define symbol_greater 287
#define symbol_greatereq 288
#define symbol_lesseq 289
#define symbol_doubleeq 290
#define symbol_noteq 291
#define symbol_xor 292
#define symbol_oneor 293
#define symbol_doubleor 294
#define symbol_question 295
#define symbol_doubleand 296
#define symbol_muleq 297
#define symbol_diveq 298
#define symbol_modeq 299
#define symbol_pluseq 300
#define symbol_minuseq 301
#define symbol_leftshifteq 302
#define symbol_rightshifteq 303
#define symbol_xoreq 304
#define symbol_andeq 305
#define symbol_oreq 306
#define symbol_hash 307
#define keyword_if 308
#define keyword_else 309
#define keyword_switch 310
#define keyword_while 311
#define keyword_do 312
#define keyword_for 313
#define keyword_goto 314
#define keyword_continue 315
#define keyword_break 316
#define keyword_return 317
#define keyword_extern 318
#define keyword_static 319
#define keyword_auto 320
#define keyword_register 321
#define keyword_void 322
#define keyword_char 323
#define keyword_short 324
#define keyword_int 325
#define keyword_long 326
#define keyword_float 327
#define keyword_double 328
#define keyword_signed 329
#define keyword_unsigned 330
#define keyword__Bool 331
#define keyword__Complex 332
#define keyword__Imaginary 333
#define keyword_enum 334
#define keyword_const 335
#define keyword_restrict 336
#define keyword_volatile 337
#define keyword_inline 338
#define keyword_sizeof 339
#define keyword_default 340
#define keyword_struct 341
#define keyword_typedef 342
#define keyword_union 343
#define keyword_case 344
#define enumeration_constant 345

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
