#!/usr/bin/env python
import re
import sys
import os

from p_flex import Tokenizer, Node, FlexException, NullException, IllegalException
from constants import *

# comments are skipped,just leave \n
class Parser:
    def parse(self,tokens):
        self.tokens = tokens
        self.global_keys = []
        self.root = Node(N_CONF)
        self.conf(self.root)


    def print_tree(self):
        out =[]
        self.root.print_node(out)
        sys.stdout.write(''.join(out))

    def consume_token(self):
        top = self.tokens[0]
        self.tokens = self.tokens[1:]
        return top

    def conf(self, curnode):
		# Derive <global>
        curnode.c1 = Node(N_GLOBAL,'global')
        self.global_conf(curnode.c1)
        # Derive <hosts>
        curnode.c2 = Node(N_HOSTS)
        self.host_confs(curnode.c2)

    def global_conf(self, curnode):
        global_flag = True
    	while self.tokens[0].type == NEW_LINE:
    		self.consume_token()

        if self.tokens[0].type == STRING and self.tokens[0].value == 'global':
            self.consume_token()
            curnode.c1 = Node(GLOBAL_KEYWORD,'GLOBAL')
        else:
            print "Expected a 'global' name and didn't get it!"
            raise Exception

        if not len(self.tokens):
            print "Premature end of file, expected ="
            raise Exception

        if self.tokens[0].type == LEFT:
            curnode.c2 = self.consume_token()
        else:
            print "Expected an { sign and didn't get it!"
            raise Exception

        curnode.c3 = Node(KV_PAIRS)
        self.key_value_pairs(curnode.c3,global_flag)


        if self.tokens[0].type == RIGHT:
            curnode.c4 = self.consume_token()
        else:
            print "Expected an } sign and didn't get it!"
            raise Exception
        if self.tokens[0].type == SEMI:
            curnode.c5 = self.consume_token()
        
        print "gobal is done"


    def host_confs(self, curnode):
        if not len(self.tokens):
            return
        while self.tokens[0].type == NEW_LINE:
            self.consume_token()
            if not len(self.tokens):
                return
        curnode.c1 = Node(N_HOST)
        self.host_conf(curnode.c1)
        curnode.c2 = Node(N_HOSTS)
        self.host_confs(curnode.c2)


        
    def host_conf(self, curnode):

        while self.tokens[0].type == NEW_LINE:
    		self.consume_token()

        if self.tokens[0].type == STRING and self.tokens[0].value == 'host':
            self.consume_token()
            curnode.c1 = Node(HOST_KEYWORD,'HOST')
        else:
            print "Expected a 'host' name and didn't get it!"
            raise Exception
        if not len(self.tokens):
            print "Premature end of file, expected ="
            raise Exception

    	if self.tokens[0].type == STRING and re.search(r'^[a-zA-Z_0-9\._\-]*$',self.tokens[0].value):
            curnode.c2 = Node(HOST_NAME,self.consume_token().value)
            
        if self.tokens[0].type == LEFT:
            curnode.c3 = self.consume_token()
        else:
            print "Expected an { sign and didn't get it!"
            raise Exception

        curnode.c4 = Node(KV_PAIRS,'A PAIR')
        self.key_value_pairs(curnode.c3)


        if self.tokens[0].type == RIGHT:
            curnode.c5 = self.consume_token()
        else:
            print "Expected an } sign and didn't get it!"
            raise Exception
        if self.tokens[0].type == SEMI:
            curnode.c6 = self.consume_token()
        
        print "host is done"
        
    def key_value_pairs(self, curnode,global_flag=False):
    	while self.tokens[0].type == NEW_LINE:
    		self.consume_token()
        if self.tokens[0].type == RIGHT:
            return
        else:
            curnode.c1 = Node(KV_PAIR)
            self.key_value_pair(curnode.c1,global_flag)
            curnode.c2 = Node(KV_PAIRS)
            self.key_value_pairs(curnode.c2,global_flag)

    #a broad string, then narrow down and check here
    def key_value_pair(self, curnode,global_flag=False):
    	#skip all the pre new line
    	while self.tokens[0].type == NEW_LINE:
    		self.consume_token()
    	if self.tokens[0].type == STRING and re.search(r'^[a-zA-Z_][a-zA-Z_0-9]*$',self.tokens[0].value):#key
            curnode.c1 = Node(KEY,self.consume_token().value)
            if global_flag:
                self.global_keys.append(curnode.c1.value)
            if self.tokens[0].type == EQUAL:
                curnode.c2 = self.consume_token()	
                if self.tokens[0].type == STRING:
                    if re.search(r'^[0-9]*$', self.tokens[0].value):
                        node_type = INT
                        prefix = 'I::'
                    elif re.search(r'^[0-9]+\.[0-9]*$', self.tokens[0].value):
                        node_type = FLOAT
                        prefix = 'F::'
                    elif re.search(r'^[a-zA-Z/][a-z-A-Z0-9\-/\._]*$', self.tokens[0].value):
                        node_type = STRING
                        prefix = 'S::'
                    else:
                        print 'Illegal Value',self.tokens[0]
                        raise Exception
                    curnode.c3 = Node(node_type, self.consume_token().value)
                elif self.tokens[0].type == QUOTED_STRING:
                    curnode.c3 = self.consume_token()
                    prefix = 'Q::'
                else:
    				raise Exception
                #overwite
                if curnode.c1.value in self.global_keys and not global_flag:
                    prefix = prefix[:2] +'O' + prefix[2:]
                curnode.c1.value = '    ' + prefix + curnode.c1.value

            else:
    			raise Exception
    				
    	elif self.tokens[0].type == RIGHT :
    		return 

        else:
            print "Expected a pair and didn't get it!"
            raise Exception

        if not len(self.tokens):
            print "Premature end of file, expected ="
            raise Exception

def remove_comments(tokens):
    return [token for token in tokens if token.type != COMMENT]
            
if __name__ == '__main__':
    file_name = 'test.cfg'
    if len(sys.argv) > 1:
        file_name = sys.argv[1]
    if not os.path.isfile(file_name):
        print 'ERR:F:\n'
        exit()

    data = open(file_name).read()
    import pprint
    try:
        tokenizer = Tokenizer(data)
        tokenizer.tokenize()
    except FlexException:
        print 'E:L:%d'%tokenizer.lineno
    except IllegalException:
        print 'E:L:%d'%tokenizer.lineno
    
    p = Parser()
    tokens = remove_comments(tokenizer.tokens)
    print tokens
    p.parse(tokens)
    p.print_tree()
