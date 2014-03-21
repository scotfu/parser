%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"
tree_t top, *cur;
void insert_substring(char *a, char *b, int position)
 {
   char *f, *e;
   int length;
 
   length = strlen(a);
 
   f = substring(a, 1, position - 1 );      
   e = substring(a, position, length-position+1);
 
   strcpy(a, "");
   strcat(a, f);
   free(f);
   strcat(a, b);
   strcat(a, e);
   free(e);
 }
char *substring(char *string, int position, int length) 
 {
   char *pointer;
   int c;
 
   pointer = malloc(length+1);
 
   if( pointer == NULL )
     exit(EXIT_FAILURE);
 
   for( c = 0 ; c < length ; c++ ) 
     *(pointer+c) = *((string+position-1)+c);       
 
   *(pointer+c) = '\0';
 
   return pointer;
 }
%}


%union {char *str; tree_t *t;}

%token<str> QUOTED_STRING COMMENT KEY HOST_NAME_STRING UNQUOTED_STRING INT FLOAT GLOBAL_KEYWORD HOST_KEYWORD EQUAL LEFT RIGHT NULL_
%type <t> global_conf host_confs key_value_pairs host_conf key_value
%%

conf: global_conf host_confs {}
;

global_conf:
GLOBAL_KEYWORD {$1 = (tree_t *)malloc(sizeof(tree_t));cur->next=$1;cur=cur->next;cur->var_name="GLOBAL";cur->var_value="";cur->type=265;}LEFT key_value_pairs RIGHT
;

host_confs : /* empty */ 
| host_confs host_conf  {}
	    ;
host_conf :  
HOST_KEYWORD HOST_NAME_STRING {$1 = (tree_t *)malloc(sizeof(tree_t));cur->next=$1;cur=cur->next;cur->var_name="HOST";cur->var_value=$2;cur->type=266} LEFT key_value_pairs RIGHT
;

key_value_pairs : key_value  {cur->next = $1; cur = cur->next;}
|key_value_pairs key_value  {cur->next = $2; cur = cur->next;}
|/* empty */ 		 ;

key_value : KEY EQUAL INT {$$ = (tree_t *)malloc(sizeof(tree_t));
  $$->var_name=$1; $$->var_value=$3; $$->next=0;cur->type=263;
                   }
|KEY EQUAL FLOAT { $$ = (tree_t *)malloc(sizeof(tree_t));
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;cur->type=264
                     }
|KEY EQUAL QUOTED_STRING {$$ = (tree_t *)malloc(sizeof(tree_t));
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;cur->type=258
                   }
|KEY EQUAL UNQUOTED_STRING {$$ = (tree_t *)malloc(sizeof(tree_t));
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;cur->type=262
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
	    cur = top.next; // The first node was a dummy node representing the <prog> production.    
	    //track the global settings
	    char tmp_g_conf[1000];
	    while(cur){
	    if(cur->var_name== "GLOBAL"){
	      printf("%s:\n",cur->var_name);}
	    else if(cur->var_name=="HOST"){
	      printf("%s %s:\n",cur->var_name,cur->var_value);
	      break;}
	    else{
	      strcat(tmp_g_conf,cur->var_name);
	      	      printf("%s,\n",cur->var_name);
	      }
	    cur= cur->next;
	    }
	    //	        printf("this is gloal conf name:%s",tmp_g_conf);

	    cur = top.next; // The first node was a dummy node representing the <prog> production.    
	    int global_flag = 0;

	    //  char *tmp_tag="I::";
	    //  insert_substring($1,tmp_tag,1);

	    while(cur){
	    if(cur->var_name== "GLOBAL"){
	      printf("%s:\n",cur->var_name);}
	    else if(cur->var_name=="HOST"){
	      global_flag = 1; //done
	      printf("%s %s:\n",cur->var_name,cur->var_value);}
	    else{
		  char *output;
		  strcat(output,cur->var_name);
		  strcat(output,":");
		  strcat(output,cur->var_value);
		  //add F,I,S,Q
		  switch(cur->type){
		  case 263:
		    insert_substring(output, "I::",1);
		    break;
		  case 258:
		    insert_substring(output, "Q::",1);
		    break;
		  case 262:
		    insert_substring(output, "S::",1);
		    break;
		  case 264:
		    insert_substring(output, "F::",1);
		    break;
		  default:
		    ;
		  }
		  //whether o
		  if(strstr(tmp_g_conf,cur->var_name)){
		    if(global_flag){
		      insert_substring(output,"O",5);
		  }
		  printf("%s",output);
	    }
	    cur= cur->next;
	    }

	    return 0;
}


void yyerror(char *s)
{
  fprintf(stderr,"%d: %s\n", yylineno, s);
}
