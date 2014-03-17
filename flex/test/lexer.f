%{
#include "tree.h"
#include "bison.tab.h"
%}


%%
[ \t]         ;
".*"              {yylval.str=strdup(yytext); return QUOTED_STRING;}    
#.*\n             {yylval.str=strdup(yytext); return COMMENT;}  
global            {yylval.str=strdup(yytext); return GLOBAL_KEYWORD;}  
host              {yylval.str=strdup(yytext); return HOST_KEYWORD;}
[_\-a-zA-Z][[:ascii:]]* {yylval.str=strdup(yytext); return KEY;}
[0-9]+\.[0-9]+    {yylval.str=strdup(yytext); return FLOAT;}  
[0-9]+            {yylval.str=strdup(yytext); return INT;}  
[a-zA-Z0-9\.\-_]+     {yylval.str=strdup(yytext); return HOST_NAME_STRING;}  
[a-zA-Z_][a-zA-Z0-9\.\-_\\/]+  {yylval.str=strdup(yytext); return UNQUOTED_STRING;}  
;                 {yylval.str=strdup(yytext); return SEMI;}  
{                 {yylval.str=strdup(yytext); return LEFT;}  
}                 {yylval.str=strdup(yytext); return RIGHT;}  
=                 {yylval.str=strdup(yytext); return EQUAL;}  
\n                {yylval.str=strdup(yytext); return NEW_LINE;}   
%%
