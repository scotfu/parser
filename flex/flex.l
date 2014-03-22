%{
#include "tree.h"
#include "bison.tab.h"
%}
%option noyywrap
%option yylineno
%%

[ \t]                   {}
\"(?:\\.|[^"\\])*\"      {yylval.str=strdup(yytext);  return QUOTED_STRING;}
#[^\n]*\n                    {return COMMENT;}  
global                 { return GLOBAL_KEYWORD;}  
host                   { return HOST_KEYWORD;}
[_a-zA-Z][a-zA-Z0-9_]*   { yylval.str=strdup(yytext);  return KEY;}
[0-9]+\.[0-9]+           { yylval.str=strdup(yytext);  return FLOAT;}  
[0-9]+                   { yylval.str=strdup(yytext);  return INT;}  
[a-zA-Z0-9\.\-_]+        { yylval.str=strdup(yytext);  return HOST_NAME_STRING;}  
[a-zA-Z_/][a-zA-Z0-9\.\-_/]+  { yylval.str=strdup(yytext);  return UNQUOTED_STRING;}  
";"                   {return SEMI;}  
\{                   { return LEFT;}  
\}                   { return RIGHT;}  
=                   { return EQUAL;}  
\n                  {}   
.                    {error("ERR:L:%d",yylineno);exit(-1);}  
%%

