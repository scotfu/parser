%{
#include "example.h"
#include "bison-example.tab.h"
%}

%option noyywrap
digit   [0-9]

%%
"END"      { return END; }
{digit}+   { yylval.str=strdup(yytext); return INT; }
"="        {return  EQ; }
[a-zA-Z]+  { yylval.str=strdup(yytext); return VARIABLE; }
[ \n\t]+   {} /* Ignore white space. */
.          {printf("Unrecognized character: %c\n", yytext[0]);}
%%
