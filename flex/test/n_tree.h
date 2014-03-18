struct tree {
  int n;
  char *name;
  char *value;
  struct t *children;
  struct t *next;
}

tree insert()
