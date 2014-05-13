%{
#define VARIABLE 100
#define EQ       101
#define INT      102
#define END      103
%}

%option noyywrap
digit   [0-9]

%%
"END"      { return END; }
{digit}+   { printf("Token value: >>%s<<\n", yytext); return INT; }
"="        {return  EQ; }
[a-zA-Z]+  { printf("Token value: >>%s<<\n", yytext); return VARIABLE; }
[ \n\t]    {} /* Ignore white space. */
.          {printf("Unrecognized character: %c\n", yytext[0]);}
%%

int main(int argc, char **argv) {
  int n;

  while(1) {
    n = yylex();
    printf("Token type: %d\n", n);
    if (!n) /* End of file */
      return 0;
  }
}
