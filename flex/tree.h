#ifndef __TREE_H__
#define __TREE_H__

int  yylex   ();
void yyerror (char *);
int yyparse();
int yylineno;
FILE *yyin;
void insert_substring(char*, char*, int);
char* substring(char*, int, int);
typedef struct tree_st {
  char           *var_name;
  char           *var_value;
  struct tree_st *next;
  int type;
} tree_t;

//extern tree_t top, *cur;                                                                  

#endif
