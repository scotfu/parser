import sys # For sys.stdin

# Our types for both non-terminals and terminals.
T_ASSIGN = 1
T_PROG   = 2
T_EQ     = 3
T_VAR    = 4
T_INT    = 5
T_END    = 6

# The main class below is Parser.
# The parser first calls tokenize() on the input string to generate
# a list of tokens.  We encapsulate the tokens into ParseNode objects that
# the parser will put into the tree, instead of having a seprate token type.
#
# Then, the parser uses the grammar to derive sentences and create a
# parse tree.  The parser raises exceptions when the input string is
# determined to be invalid.
#
# Depending on the production, there can be up to 3 items on the RHS
# Of a rule in this language, so we use 3 "branches" in our tree node data
# type, in left-to-right order until we don't need any more.
#
# There's also code here to walk the tree for assignment nodes, and
# To print the entire tree.  We use them in the first example.

class ParseNode:
    def __init__(self, t, value=None):
        self.type   = t
        self.value  = value
        self.b1     = None
        self.b2     = None
        self.b3     = None
    def __repr__(self):
        return str(self.value)
    def print_node(self, level=0):
        if self.type == T_ASSIGN:
            thisnodeout = "<assign>"
        elif self.type == T_PROG:
            thisnodeout = "<prog>"
        elif self.type == T_EQ:
            thisnodeout = "="
        elif self.type == T_END:
            thisnodeout = "END"
        elif self.type == T_VAR:
            thisnodeout = "VAR (" + self.value + ")"
        elif self.type == T_INT:
            thisnodeout = "INT (" + str(self.value) + ")"
       # This will never happen unless we try to add a new node type            
       # and forget to add an if statement for it here.
        else:
            print "You forgot to add printing code for your new node type!"
            raise Exception
        if level:
            print "     "*(level-1) + "  |- " + thisnodeout
        else:
            print thisnodeout
        if self.b1:
            self.b1.print_node(level+1)
        if self.b2:
            self.b2.print_node(level+1)
        if self.b3:
            self.b3.print_node(level+1)

def tokenize(str):
    tokens = []
    while len(str):
      if str[0] in [' ', '\t', '\n']:
          str = str[1:]
      elif str[0].isalpha():
          val = ''
          while len(str) and str[0].isalpha():
              val += str[0]
              str = str[1:]
          if val == "END":
              tokens.append(ParseNode(T_END))
          else:
              tokens.append(ParseNode(T_VAR, value=val))
      elif str[0].isdigit():
          val = ''
          while len(str) and str[0].isdigit():
              val += str[0]
              str = str[1:]
          tokens.append(ParseNode(T_INT, int(val)))
      elif str[0] == '=':
          tokens.append(ParseNode(T_EQ))
          str = str[1:]
      else:
          print "Warning: invalid character, ", str[0]
          str = str[1:]
    print tokens      
    return tokens

class Parser:
    def parse(self, str):
      self.tokens = tokenize(str)
      self.root = ParseNode(T_PROG)
      self.prog(self.root)

    # When this is called, we return the top token to the caller, 
    # and also remove it from the list.
    def consume_token(self):
      top = self.tokens[0]
      self.tokens = self.tokens[1:]
      return top

    def prog(self, curnode):
        if not len(self.tokens):
            print "Premature end of file, expected assignment or END"
            raise Exception
        # If we see an END token, we derive END,
        # Otherwise we derive <assign> <prog>
        if self.tokens[0].type == T_END:
            curnode.b1 = self.consume_token()
            if len(self.tokens):
                print "Error: END reached, but file keeps going!"
                raise
        else:
            # Derive <assign>
            curnode.b1 = ParseNode(T_ASSIGN)
            self.assign(curnode.b1)
            # Now derive the next <prog>
            curnode.b2 = ParseNode(T_PROG)
            self.prog(curnode.b2)

    def assign(self, curnode):
        # Derive the variable.
        if self.tokens[0].type == T_VAR:
            curnode.b1 = self.consume_token()
        else:
            print "Expected a variable name and didn't get it!"
            raise Exception

        if not len(self.tokens):
            print "Premature end of file, expected ="
            raise Exception
        # Note tokens[0] now points to the EQ (if well-formed) because
        # The call to self.consume_token() took the variable name out of the array.
        if self.tokens[0].type == T_EQ:
            curnode.b2 = self.consume_token()
        else:
            print "Expected an equals sign and didn't get it!"
            raise Exception
        
        if not len(self.tokens):
            print "Premature end of file, expected a number"
            raise Exception

        if self.tokens[0].type == T_INT:
            curnode.b3 = self.consume_token()
        else:
            print "Expected an integer, and didn't get it!"
            raise Exception

    def print_tree(self):
        self.root.print_node()

    def __iter__(self):
        self._iter_state = self.root
        return self

    def next(self):
        if self._iter_state.b1.type == T_END:
            raise StopIteration
        else:
            ret = self._iter_state.b1
            self._iter_state = self._iter_state.b2
            return ret
        
p = Parser()
p.parse(sys.stdin.read())
p.print_tree()

print "Now let's look at each assignment in order by walking the tree:"
for item in p:
    print "Assign", item.b3.value, "to", item.b1.value

