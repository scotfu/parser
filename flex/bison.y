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
%type <t> global_conf host_confs key_value_pairs host_conf key_value comments
%%

conf: comments global_conf comments host_confs comments {}
|error{exit(-1);}
;

global_conf:
GLOBAL_KEYWORD comments {$1 = (tree_t *)malloc(sizeof(tree_t));cur->next=$1;cur=cur->next;cur->var_name="GLOBAL";cur->var_value="";cur->type=265;} comments LEFT comments key_value_pairs comments RIGHT  comments
;

host_confs : comments host_conf comments
|host_confs host_conf  comments{}
| /* empty */ 

host_conf :  
HOST_KEYWORD  comments HOST_NAME_STRING  comments {$1 = (tree_t *)malloc(sizeof(tree_t));cur->next=$1;cur=cur->next;cur->var_name="HOST";cur->var_value=$3;cur->type=266} LEFT comments key_value_pairs comments RIGHT comments
;

key_value_pairs : key_value comments {cur->next = $1; cur = cur->next;}
|key_value_pairs key_value comments {cur->next = $2; cur = cur->next;}
|/* empty */ 		 ;

key_value : KEY EQUAL INT {$$ = (tree_t *)malloc(sizeof(tree_t));
  $$->var_name=$1; $$->var_value=$3; $$->next=0;$$->type=263;
                   }
|KEY EQUAL FLOAT { $$ = (tree_t *)malloc(sizeof(tree_t));
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;$$->type=264
                     }
|KEY EQUAL QUOTED_STRING {$$ = (tree_t *)malloc(sizeof(tree_t));
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;$$->type=258
                   }
|KEY EQUAL UNQUOTED_STRING {$$ = (tree_t *)malloc(sizeof(tree_t));
                      $$->var_name=$1; $$->var_value=$3; $$->next=0;$$->type=262
                   }
;

comments: /* empty */
         |comments COMMENT

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
	      ;}
	    else if(cur->var_name=="HOST"){
	      break;}
	    else{
	      strcat(tmp_g_conf,cur->var_name);
	    }
	    cur= cur->next;
	    }
	    //printf("this is gloal conf name:%s",tmp_g_conf);

	    cur = top.next; // The first node was a dummy node representing the <prog> production.    


	    //  char *tmp_tag="I::";
	    //  insert_substring($1,tmp_tag,1);
	    int global_flag = 0;
	    while(cur){
	    if(cur->var_name== "GLOBAL"){
	      printf("%s:\n",cur->var_name);
	      }
	    else if(cur->var_name=="HOST"){
	      global_flag = 1; //done
	      printf("%s %s:\n",cur->var_name,cur->var_value);}
	    else{
		  char output[1000]= "    ";
		  strcat(output,cur->var_name);
		  strcat(output,":");
		  strcat(output,cur->var_value);
		  strcat(output,"\n");
		  // printf("%s:%s:%d",cur->var_name,cur->var_value,cur->type);

		  //add F,I,S,Q
		  switch(cur->type){
		  case 263:
		    insert_substring(output, "I::",5);
		    break;
		  case 258:
		    insert_substring(output, "Q::",5);
		    break;
		  case 262:
		    insert_substring(output, "S::",5);
		    break;
		  case 264:
		    insert_substring(output, "F::",5);
		    break;
		  default:
		    ;
		  }
		  
		  //whether o
		  if(strstr(tmp_g_conf,cur->var_name)){
		    if(global_flag){
		      insert_substring(output,"O",7);}
		  }
		  printf("%s",output);

	        }
	    cur= cur->next;
	    }

	    return 0;
}


void yyerror(char *s)
{
  printf("ERR:P:%d\n", yylineno);

}
