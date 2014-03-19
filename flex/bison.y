%{
#include <stdio.h>
#include <stdlib.h>
#include "tree.h"
  tree_t top, *cur;

%}

%union {char *str; tree_t *t;}

%token<str> QUOTED_STRING COMMENT KEY HOST_NAME_STRING UNQUOTED_STRING INT FLOAT
%token GLOBAL_KEYWORD HOST_KEYWORD EQUAL SEMI LEFT RIGHT NEW_LINE NULL_
%type <t> global_conf host_confs key_value_pairs host_conf key_value
%%
conf: global_conf host_confs;

global_conf: GLOBAL_KEYWORD LEFT key_value_pairs RIGHT SEMI
            |GLOBAL_KEYWORD LEFT key_value_pairs RIGHT
;

host_confs : /* empty */ {}
            |host_confs host_conf
	    ;
host_conf :  HOST_KEYWORD HOST_NAME_STRING LEFT key_value_pairs RIGHT SEMI
            |HOST_KEYWORD HOST_NAME_STRING LEFT key_value_pairs RIGHT
            ;

key_value_pairs : /* empty */ {}
                 |key_value_pairs NEW_LINE  key_value
		 ;

key_value : KEY EQUAL INT { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}
|KEY EQUAL FLOAT { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}
|KEY EQUAL QUOTED_STRING { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}
|KEY EQUAL UNQUOTED_STRING { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}
|KEY EQUAL HOST_NAME_STRING { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}
|KEY EQUAL KEY { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}
;
%%
	  
int main(int argc, char **argv) {
	    FILE *tmpfile = fopen(argv[1],"r");
	    if(!tmpfile)
	      {
		printf("ERR:F:\n");
		return -1;    
	      }
	    yyin = tmpfile;
	    top.next = 0;
	    cur = &top;
	    yyparse();
	    printf("Let's walk the tree again:\n");
	    cur = top.next; // The first node was a dummy node representing the <prog> production.    
	    //	    while (cur) {
	    //  printf("%s: %s\n", cur->var_name, cur->var_value);
	    //  cur = cur->next;}
	    return 0;
            }


void yyerror(char *s)
{
  fprintf(stderr,"%d: %s\n", yylineno, s);
}