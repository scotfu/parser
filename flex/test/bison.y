%{
#include <stdio.h>
#include <stdlib.h>
#include "tree.h"
  tree_t top, *cur;
  %}

%union {char *str; tree_t *t;}
%token<str> QUOTED_STRING COMMENT GLOBAL_KEYWORD HOST_KEYWORD KEY FLOAT INT HOST_NAME_STRING UNQUOTED_STRING
%token EQ END SEMI LEFT RIGHT EQUAL NEW_LINE NULL_
%type<t> conf global_conf host_confs key_value_pairs host_conf key_value key value m_string

%%
conf: global_conf host_confs

global_conf: GLOBAL_KEYWORD LEFT key_value_pairs RIGHT SEMI
            |GLOBAL_KEYWORD LEFT key_value_pairs RIGHT
host_confs : /* empty */
            | host_confs host conf

host_conf : HOST_KEYWORD HOST_NAME_STRING LEFT key_value_pairs RIGHT  
           |HOST_KEYWORD HOST_NAME_STRING LEFT key_value_pairs RIGHT SEMI  
           |HOST_KEYWORD HOST_NAME_STRING LEFT key_value_pairs NEW_LINE RIGHT SEMI
           |HOST_KEYWORD HOST_NAME_STRING LEFT key_value_pairs NEW_LINE RIGHT

key_value_pairs : /* empty */
                  |key_value NEW_LINE  {cur->next = $1; cur = cur->next;
                             printf("Assign %s to %s!\n", cur->var_value, cur->var_name}
                  |key_value_pairs key_value

key_value : KEY EQUAL value 


value: INT { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}
      |FLOAT { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}
      |m_string

m_string: QUOTED_STRING { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}
       |UNQUOTED_STRING { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}
       |HOST_NAME_STRING { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}
       |KEY { $$ = (tree_t *)malloc(sizeof(tree_t)); $$->var_value=$1;$$->next=0;}


%%
int main() {
  top.next = 0;
  cur      = &top;
  yyparse();
  printf("Let's walk the tree again:\n");
  cur = top.next; // The first node was a dummy node representing the <prog> production.    
  while (cur) {
    printf("%s: %s\n", cur->var_name, cur->var_value);
    cur = cur->next;
  }
}

void yyerror (char *s) {
  printf ("%s\n", s);
}
