#ifndef YYTOKENTYPE                                                                         
# define YYTOKENTYPE                                                                        
/* Put the tokens into the symbol table, so that GDB and other debuggers                 
   know about them.  */                                                                  
enum yytokentype {                                                                       
  QUOTED_STRING = 258,
  COMMENT = 259,
  GLOBAL_KEYWORD= 259,
  HOST_KEYWORD= 260,
  KEY= 261,
  FLOAT= 262,
  INT= 263,
  HOST_NAME_STRING= 264,
  UNQUOTED_STRING=265,
  SEMI=266,
  LEFT=267,
  RIGHT=268,
  EQUAL=269,
  NEW_LINE=270,
};                                                                                       
#endif 

#define QUOTED_STRING 258
#define COMMENT 259
#define GLOBAL_KEYWORD 259
#define HOST_KEYWORD 260
#define KEY 261
#define FLOAT 262
#define INT 263
#define HOST_NAME_STRING 264
#define UNQUOTED_STRING 265
#define SEMI 266
#define LEFT 267
#define RIGHT 268
#define EQUAL 269
#define NEW_LINE 270
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
/* Line 1529 of yacc.c.  */
#line 63 "bison.tab.h"
  YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

