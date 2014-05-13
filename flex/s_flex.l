%{

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
%option yylineno
%%


\"(?:\\.|[^"\\])*\"      { printf("Token value: >>%s<<\n", yytext); return QUOTED_STRING;}
#[^\n]*                    { printf("Token value: >>%s<<\n", yytext); return COMMENT;}  
\n                    { printf("Token value: >>newline<<\n"); return NEW_LINE;}  
"global"                 { printf("Token value: >>%s<<\n", yytext); return GLOBAL_KEYWORD;}  
"host"                   { printf("Token value: >>%s<<\n", yytext); return HOST_KEYWORD;}
[_a-zA-Z][a-zA-Z0-9_]*   { printf("Token value: >>%s<<\n", yytext);  return KEY;}
[0-9]+\.[0-9]+           { printf("Token value: >>%s<<\n", yytext);  return FLOAT;}  
[0-9]+                   { printf("Token value: >>%s<<\n", yytext);  return INT;}  
[a-zA-Z0-9\.\-_]+        { printf("Token value: >>%s<<\n", yytext);  return HOST_NAME_STRING;}  
[a-zA-Z_/][a-zA-Z0-9\.\-_/]+  { printf("Token value: >>%s<<\n", yytext);  return UNQUOTED_STRING;}  
";"                   { printf("Token value: >>%s<<\n", yytext);return SEMI;}  
"{"                   { printf("Token value: >>%s<<\n", yytext); return LEFT;}  
"}"                   { printf("Token value: >>%s<<\n", yytext); return RIGHT;}  
"="                   { printf("Token value: >>%s<<\n", yytext);return EQUAL;}  
"\\0x00"            { printf("Token value: >>%s<<\n", yytext);return NULL_;}     
" "                 {}
.                    {printf("Found wft:%s",yytext);}  
%%


int main(int argc, char **argv) {
  int n;
  char *file_name = "test.cfg";
  if(argc>1){file_name = argv[1];}
  FILE *tmpfile = fopen(file_name,"r");
           if(!tmpfile)
	      {

		printf("ERR:F:\n");
		return -1;    
	      }

    yyin = tmpfile;
  while(1) {
    n = yylex();
    printf("Token type: %d\n", n);
    if (!n) /* End of file */                                                                                                                                                            
      return 0;
  }
}
