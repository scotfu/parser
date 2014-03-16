%{
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()
int linenum = 0;
%}
%%
#.*\n           {cout<<"found comment"<<yytext<<endl;}  
global          {cout<<"found global"<<yytext<<endl;}
host            {cout<<"found host"<<yytext<<endl;}
[a-zA-Z0-9_\-]+[.a-zA-Z0-9_\-]+     {cout<<"found a host name"<<yytext<<endl;}
[ \t]         ;
[0-9]+\.[0-9]+  { cout << "Found a floating-point number:" << yytext << endl; }
[0-9]+          { cout << "Found an integer:" << yytext << endl; }
[a-zA-Z0-9]+    { cout << "Found a string: " << yytext << endl; }
;               { cout << "Found a semicolon: " << yytext << endl; }
{               { cout << "Found a right bracket: " << yytext << endl; }
}               { cout << "Found a left bracket: " << yytext << endl; }
=               { cout << "Found a equal sign: " << yytext << endl; }
\n              { linenum++; }

%%
main(int argc, char **argv) {
// lex through the input:

FILE *tmpfile = fopen(argv[1],"r");
if(!tmpfile){
cout<<"ERR:F:\n"<<endl;
return -1;    
}
yyin = tmpfile;
yylex();
{ cout << "# of lines is: " << linenum << endl; }
}