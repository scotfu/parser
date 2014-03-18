#ifndef __TREE_H__
#define __TREE_H__

int  yylex   ();
void yyerror (char *);
int yyparse();
FILE *yyin;

typedef struct tree_st {
  char           *var_name;
  char           *var_value;
  struct tree_st *next;
} tree_t;

//extern tree_t top, *cur;                                                                  

#endif
