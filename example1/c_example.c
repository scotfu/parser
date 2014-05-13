/*
 * The C program is fairly similar to Python, and I've tried to make this listing
 * track with the Python one as much as possible.
 * 
 * Of course, there are major differences, including:
 *   - Obviously, C doesn't have classes, but we use similar data structures.
 *   - We have to do our own memory allocation.  
 *   - It is much easier to read tokens when the parser needs them, instead of
 *     all at once.  The parser's reference to the token stream gets updated
 *     by the tokenizer.
 *   - switch() statements!
 *   - No exception handling, so we bail on our first hard error.
 *   - The use of explicit references.
 * 
 */
#include <stdio.h>   // For definition of printf()
#include <stdlib.h>  // For definition of exit()
#include <string.h>  // For definition of memcpy()
#include <ctype.h>   // For definition of isalpha()
#include <stdio.h>   // For FILE *, fread, stdin

typedef enum { T_ASSIGN, T_PROG, T_EQ, T_VAR, T_INT, T_END, T_EOF} type_t;

typedef struct node_st {
  type_t          type;
  char           *value;
  struct node_st *b1, *b2, *b3;
} node_t;

typedef struct {
  node_t *top_token;
  char   *input;
} state_t;

node_t *prog  (state_t *s);
node_t *assign(state_t *s);


void bail(const char *s) {
  printf("Fatal error: %s\n", s);
  exit(0); /* Don't worry about deallocating memory since we errored. */
}

void print_node(const node_t *n, unsigned int level) {
  int i;

  if (!n) return;

  if (level) {
    for (i=0;i<level-1;i++) { printf("     "); }
    printf ("  |- ");
  }

  switch (n->type) {
  case T_ASSIGN: printf("<assign>\n"); break;
  case T_PROG:   printf("<prog>\n"); break;
  case T_EQ:     printf("=\n"); break;
  case T_END:    printf("END\n"); break;
  case T_VAR:    printf("VAR (%s)\n", n->value); break;
  case T_INT:    printf("INT (%s)\n", n->value); break;
  default:
    bail("Invalid node type!");
  }
  level++;
  print_node(n->b1, level);
  print_node(n->b2, level);
  print_node(n->b3, level);
}

node_t *new_node() {
  node_t *ret = (node_t *)malloc(sizeof(node_t));
  ret->type   = 0;
  ret->value  = 0;
  ret->b1     = ret->b2 = ret->b3 = 0;

  return ret;
}

void free_node(node_t *n) {
  if(!n) return;
  free_node(n->b1); free_node(n->b2); free_node(n->b3);
  if (n->value) free(n->value);
  free(n);
}

/* Tokenizes a single token, updating top_token in the parse state,
 * and advances the input accordingly.
 */

void load_next_token(state_t *state) {
  char   *p;
  size_t  len;

  state->top_token = new_node();
  
  p = state->input;
  while (1) {
    switch(*p++) {
    case '\0': /* The null-terminator for the string */
      --p /* Don't advance */; state->top_token->type = T_EOF;
      return;
    case ' ': case '\t': case '\n':
      state->input++; // Move the start of the input.
      continue; // Keep looking till the first non-space.
    case '0': case '1': case '2': case '3': case '4': 
    case '5': case '6': case '7': case '8': case '9':
      while (*p && (*p >= '0' && *p <= '9')) p++;
      len                     = p-state->input;
      state->top_token->type  = T_INT;
      state->top_token->value = (char *)malloc(len+1);
      memcpy(state->top_token->value, state->input, len);
      state->top_token->value[len] = 0;
      break;  // p now points to the first char of the next token.
    case '=':
      state->top_token->type  = T_EQ;
      break;
    case 'E':
      if (*p == 'N' && *(p+1) == 'D' && !isalpha(*(p+2))) {
	state->top_token->type = T_END;
	p+=2;
	break;
      } /* Otherwise, it's not the END token so it's a regular E */
    case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'g':
    case 'h': case 'i': case 'j': case 'k': case 'l': case 'm': case 'n':
    case 'o': case 'p': case 'q': case 'r': case 's': case 't': case 'u':
    case 'v': case 'w': case 'x': case 'y': case 'z': case 'A': case 'B':
    case 'C': case 'D': case 'F': case 'G': case 'H': case 'I': case 'J': 
    case 'K': case 'L': case 'M': case 'N': case 'O': case 'P': case 'Q': 
    case 'R': case 'S': case 'T': case 'U': case 'V': case 'W': case 'X': 
    case 'Y': case 'Z':
      while (*p && ((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z'))) p++;
      len                     = p-state->input;
      state->top_token->type  = T_VAR;
      state->top_token->value = (char *)malloc(len+1);
      memcpy(state->top_token->value, state->input, len);
      state->top_token->value[len] = 0;
      break;
    default:
      printf ("Warning: invalid character, %c\n", *p++);
      continue;
    }
    break;
  }
  state->input = p;
  return;
}

int cur_type(state_t *s) {
  return s->top_token->type;
}

node_t *consume(state_t *s) {
  node_t *ret = s->top_token;

  load_next_token(s);
  return ret;
}

node_t *parse(char *input) {
  state_t parse_state;

  parse_state.input = input;
  load_next_token(&parse_state);

  return prog(&parse_state);
}

node_t *prog(state_t *s) {
  node_t *ret = new_node();
  ret->type = T_PROG;
  switch (cur_type(s)) {
  case T_EOF:
    bail("Unexpected end of file.");
  case T_END:
    ret->b1 = consume(s);
    if (cur_type(s) != T_EOF) {
      bail("Tokens after END!");
    }
    break;
  case T_VAR:
    ret->b1 = assign(s);
    ret->b2 = prog(s);
    break;
  default:
    bail("Unexpected token.");
  }
  return ret;
}

node_t *assign(state_t *s) {
  node_t *ret = new_node();
  ret->type = T_ASSIGN;
  if (cur_type(s) != T_VAR) {
    bail("Expected variable.");
  }
  ret->b1 = consume(s);
  if (cur_type(s) != T_EQ) {
    bail("Expected '='.");
  }
  ret->b2 = consume(s);
  if (cur_type(s) != T_INT) {
    bail("Expected number.");
  }
  ret->b3 = consume(s);
  return ret;
}

void find_assignments(const node_t *n) {
  if (!n)
    return;
  switch (n->type) {
  case T_ASSIGN:
    printf("Assign %s to %s\n", n->b1->value, n->b3->value);
    return;
  default:
    find_assignments(n->b1);
    find_assignments(n->b2);  // n->b2 and n->b3 won't have assignments actually.
    find_assignments(n->b3);
  }
}

#ifndef BUFSIZE
#define BUFSIZE 1024
#endif

char *read_all_of_stdin() {
  char  *ret = (char *)malloc(BUFSIZE);
  size_t total_len = 0, new_len;

  /* This is an assignment as an expression, folks! */
  while ((new_len = fread(ret+total_len, 1, BUFSIZE, stdin))) {

    total_len += new_len;
    ret = (char *)realloc(ret, total_len + BUFSIZE); /* Grow the buffer. */
  }

  return ret;
}

int main (const int argc, const char **argv) {
  char *input  = read_all_of_stdin();
  node_t *tree = parse(input);
  print_node(tree, 0);
  printf ("Okay, now let's look at the assignments:\n");
  find_assignments(tree);
  free_node(tree);
  free(input);
}
