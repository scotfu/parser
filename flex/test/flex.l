%{
#include "tree.h"
#include "bison.tab.h"
#define QUOTED_STRING 258
#define COMMENT 259
#define GLOBAL_KEYWORD 260
#define HOST_KEYWORD 261
#define KEY 262
#define FLOAT 263
#define INT 264
#define HOST_NAME_STRING 265
#define UNQUOTED_STRING 266
#define SEMI 267
#define LEFT 268
#define RIGHT 269
#define EQUAL 270
#define NEW_LINE 271
#define NULL_ 272
%}
%option noyywrap
%%

[ \t]         ;
\"(?:\\.|[^"\\])*\"      {yylval.str=strdup(yytext);  return QUOTED_STRING;}
#.*\n                    { yylval.str=strdup(yytext);  return COMMENT;}  
"global"                 { return GLOBAL_KEYWORD;}  
"host"                   { return HOST_KEYWORD;}
[_a-zA-Z][a-zA-Z0-9_]*   { yylval.str=strdup(yytext);  return KEY;}
[0-9]+\.[0-9]+           { yylval.str=strdup(yytext);  return FLOAT;}  
[0-9]+                   { yylval.str=strdup(yytext);  return INT;}  
[a-zA-Z0-9\.\-_]+        { yylval.str=strdup(yytext);  return HOST_NAME_STRING;}  
[a-zA-Z_/][a-zA-Z0-9\.\-_/]+  { yylval.str=strdup(yytext);  return UNQUOTED_STRING;}  
;                   { return SEMI;}  
"{"                 { return LEFT;}  
"}"                 { return RIGHT;}  
"="                 { return EQUAL;}  
"\n"                { return NEW_LINE;}   
"\\0x00"            { return NULL_;}     
%%

