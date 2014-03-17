%{
#include <stdio.h>
#include <stdlib.h>
#include "tree.h"
  tree_t top, *cur;
  %}

%union {char *str; tree_t *t;}
%token<str> VARIABLE INT
%token EQ END
%type<t> assign

%%
prog:
assign prog { cur->next = $1; cur = cur->next;
  printf("Assign %s to %s!\n", cur->var_value, cur->var_name);
}
| error { printf("Error before we saw a variable name.\n"); exit(0); }
| END     {};

assign:
VARIABLE EQ INT { $$ = (tree_t *)malloc(sizeof(tree_t));
  $$->var_name=$1; $$->var_value=$3; $$->next=0;
}
| VARIABLE error EQ INT { printf("Error after a variable name.\n"); exit(0);}
| VARIABLE EQ error INT { printf("Error after equals sign.\n"); exit(0);}

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
