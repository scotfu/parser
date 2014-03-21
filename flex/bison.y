%{
#include <stdio.h>
#include <stdlib.h>
#include "tree.h"
tree_t top, *cur;

 struct tree_t* newlink(char *s1, char *s2, tree_t* t3){
                 
   tree_t *tree_t1 = (tree_t *)malloc(sizeof(tree_t)); 
   tree_t *tree_t2 = (tree_t *)malloc(sizeof(tree_t)); 
   tree_t1->var_name = s1;
   tree_t1->next = tree_t2;
   tree_t2->var_name = s2;
   tree_t2->next = t3;
   return tree_t1;
     }

%}

%union {char *str; tree_t *t;}

%token<str> QUOTED_STRING COMMENT KEY HOST_NAME_STRING UNQUOTED_STRING INT FLOAT GLOBAL_KEYWORD HOST_KEYWORD EQUAL LEFT RIGHT NULL_
%type <t> global_conf host_confs key_value_pairs host_conf key_value
%%

conf: global_conf host_confs { printf("CONF\n");}
;

global_conf:
GLOBAL_KEYWORD LEFT key_value_pairs RIGHT { printf("GLOBAL CONF\n");}
;

host_confs : /* empty */ 
| host_confs host_conf  { printf("HOSTS CONF\n");}
	    ;
host_conf :  
HOST_KEYWORD HOST_NAME_STRING LEFT key_value_pairs RIGHT { 
  cur->next = newlink($1, $2, $4) ; cur = cur->next->next->next; 
                   }
;

key_value_pairs : /* empty */ 
|key_value_pairs key_value  {cur->next = $2; cur = cur->next; 
                   }
		 ;

key_value : KEY EQUAL INT {$$ = (tree_t *)malloc(sizeof(tree_t)); 
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;
                   }
|KEY EQUAL FLOAT { $$ = (tree_t *)malloc(sizeof(tree_t)); 
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;
                     }
|KEY EQUAL QUOTED_STRING {$$ = (tree_t *)malloc(sizeof(tree_t)); 
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;
                   }
|KEY EQUAL UNQUOTED_STRING {$$ = (tree_t *)malloc(sizeof(tree_t)); 
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;
                   }
|KEY EQUAL HOST_NAME_STRING {$$ = (tree_t *)malloc(sizeof(tree_t)); 
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;
                   }
|KEY EQUAL KEY {$$ = (tree_t *)malloc(sizeof(tree_t)); 
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;
                   }
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
	    	    while (cur) {
	      printf("%s: %s\n", cur->var_name, cur->var_value);
	      cur = cur->next;}
	    return 0;
            }


void yyerror(char *s)
{
  fprintf(stderr,"%d: %s\n", yylineno, s);
}
