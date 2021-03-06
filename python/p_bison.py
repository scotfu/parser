#!/usr/bin/env python
import re
import sys
import os

from p_flex import Tokenizer, Node, FlexException, NullException, IllegalException
from constants import *


class PException(Exception):
    pass

def errorRecovery(func):
    def func_wrapper(node, curnode):
        try:
            func(node, curnode)
        except:
            curnode.type = ERROR
            raise
    return func_wrapper         


class Parser:
    def parse(self,tokens):
        self.tokens = tokens
        self.global_keys = []
        self.root = Node(N_CONF)
        self.conf(self.root)


    def print_tree(self):
        out =[]
        self.root.get_node(out)
        thisnodeout =[]
        for node in out:
            if node.type == GLOBAL_KEYWORD:
                thisnodeout.append('GLOBAL:\n')
            if node.type == HOST_KEYWORD:
                thisnodeout.append('HOST ')
            if node.type == HOST_NAME:
                thisnodeout.append(node.value +':\n')
            if node.type == KEY:
                thisnodeout.append(node.value)
            if node.type == STRING:
                thisnodeout.append(node.value+'\n')
            if node.type == INT:
                thisnodeout.append(node.value+'\n')
            if node.type == FLOAT:
                thisnodeout.append(node.value+'\n')
            if node.type == EQUAL:
                thisnodeout.append(':')
            if node.type == QUOTED_STRING:
                thisnodeout.append(node.value + '\n')
        sys.stdout.write(''.join(thisnodeout))
        
    def consume_token(self):
        top = self.tokens[0]
        self.tokens = self.tokens[1:]
        return top

    def conf(self, curnode):
        # Derive <global>
        curnode.c1 = Node(N_GLOBAL)
        self.global_conf(curnode.c1)
        # Derive <hosts>
        curnode.c2 = Node(N_HOSTS)
        self.host_confs(curnode.c2)

    def clean_newline(self):
        while self.tokens and (self.tokens[0].type == NEW_LINE):
            self.consume_token()

    @errorRecovery    
    def global_conf(self, curnode):
        global_flag = True

        self.clean_newline()
        if self.tokens and (self.tokens[0].type == STRING) and (self.tokens[0].value == 'global'):
            self.consume_token()
            curnode.c1 = Node(GLOBAL_KEYWORD,'GLOBAL')
        else:
            #print "Expected a 'global' name and didn't get it!"
            raise PException,self.tokens[0].lineno

        self.clean_newline()
        if  self.tokens and self.tokens[0].type == LEFT:
            curnode.c2 = self.consume_token()
        else:
            #print "Expected an { sign and didn't get it!"
            raise PException,self.tokens[0].lineno

        self.clean_newline()
        curnode.c3 = Node(KV_PAIRS)
        self.key_value_pairs(curnode.c3,global_flag)
        
        self.clean_newline()
        if self.tokens and self.tokens[0].type == RIGHT:
            curnode.c4 = self.consume_token()
        else:
            #print "Expected an } sign and didn't get it!"
            raise PException,self.tokens[0].lineno

        self.clean_newline()
        if self.tokens and self.tokens[0].type == SEMI:#optional,so no else
            curnode.c5 = self.consume_token()
#        self.global_conf_num = 1 TO BE DELETED
        #print 'global is done'

    def host_confs(self, curnode):
        self.clean_newline()
        if not len(self.tokens):
            return
        curnode.c1 = Node(N_HOST)
        self.host_conf(curnode.c1)
        curnode.c2 = Node(N_HOSTS)
        self.host_confs(curnode.c2)


    @errorRecovery
    def host_conf(self, curnode):
        self.clean_newline()

        if  self.tokens and (self.tokens[0].type == STRING) and (self.tokens[0].value == 'host'):
            self.consume_token()
            curnode.c1 = Node(HOST_KEYWORD,'HOST')
        else:
            #print "Expected a 'host' name and didn't get it!"
            raise PException,self.tokens[0].lineno

        self.clean_newline()
        if self.tokens and self.tokens[0].type == STRING and re.search(r'^[a-zA-Z_0-9\._\-]*$',self.tokens[0].value):
            curnode.c2 = Node(HOST_NAME,self.consume_token().value)
        else:
            #print 'No host name'
            raise PException,self.tokens[0].lineno

        self.clean_newline()            
        if self.tokens and self.tokens[0].type == LEFT:
            curnode.c3 = self.consume_token()
        else:
            #print "Expected an { sign and didn't get it!"
            raise PException,self.tokens[0].lineno


        self.clean_newline()
        curnode.c4 = Node(KV_PAIRS,'A PAIR')
        self.key_value_pairs(curnode.c3)


        self.clean_newline()
        if self.tokens and self.tokens[0].type == RIGHT:
            curnode.c5 = self.consume_token()
        else:
            #print "Expected an } sign and didn't get it!"
            raise PException,self.tokens[0].lineno

        self.clean_newline()            
        if self.tokens and self.tokens[0].type == SEMI:
            curnode.c6 = self.consume_token()
        #print "host is done"
        
    def key_value_pairs(self, curnode,global_flag=False):#todo better logic
        self.clean_newline()
        if not len(self.tokens):
            return

        if self.tokens and self.tokens[0].type == RIGHT:
            return
        else:#bugs here
            curnode.c1 = Node(KV_PAIR)
            self.key_value_pair(curnode.c1,global_flag)
            curnode.c2 = Node(KV_PAIRS)
            self.key_value_pairs(curnode.c2,global_flag)

    #a broad string, then narrow down and check here
    def key_value_pair(self, curnode,global_flag=False):
    	#skip all the pre new line
        done = False
        self.clean_newline()

    	if  self.tokens and self.tokens[0].type == STRING and re.search(r'^[a-zA-Z_][a-zA-Z_0-9]*$',self.tokens[0].value):#key
            curnode.c1 = Node(KEY,self.consume_token().value)
            if global_flag:
                self.global_keys.append(curnode.c1.value)
            if self.tokens and self.tokens[0].type == EQUAL:
                curnode.c2 = self.consume_token()	
                if  self.tokens and self.tokens[0].type == STRING:
                    if re.search(r'^[+-]?[0-9]+$', self.tokens[0].value):
                        node_type = INT
                        prefix = 'I::'
                    elif re.search(r'^[+-]?[0-9]+\.[0-9]*$', self.tokens[0].value):
                        node_type = FLOAT
                        prefix = 'F::'
                    elif re.search(r'^[a-zA-Z/][a-z-A-Z0-9\-/\._]*$', self.tokens[0].value):
                        node_type = STRING
                        prefix = 'S::'
                    else:
                        #print 'Illegal String Value',self.tokens[0].lineno
                        raise PException,self.tokens[0].lineno
                    curnode.c3 = Node(node_type, self.consume_token().value)
                elif self.tokens and self.tokens[0].type == QUOTED_STRING:
                    curnode.c3 = self.consume_token()
                    curnode.c3.value = format_quoted_string(curnode.c3.value)
                    prefix = 'Q::'
                else:
                    #print 'Illegal Value',self.tokens[0]
                    raise PException,self.tokens[0].lineno
                #overwite
                if curnode.c1.value in self.global_keys and not global_flag:
                    prefix = prefix[:2] +'O' + prefix[2:]
                curnode.c1.value = '    ' + prefix + curnode.c1.value

            else:
                raise PException,self.tokens[0].lineno

            if self.tokens:
                if self.tokens[0].type == NEW_LINE:
                    self.consume_token()
                elif self.tokens[0].type == RIGHT:
                    pass
                else:
                    #print 'No newline or }'
                    raise PException,self.tokens[0].lineno
            else:
                raise PException
    	elif self.tokens[0].type == RIGHT :
    		return 

        else:
            #print "Expected a pair and didn't get it!"
            raise PException,self.tokens[0].lineno


def remove_comments(tokens):
    return [token for token in tokens if token.type != COMMENT]

def format_quoted_string(string):
    out =[]
    length = len(string)
    i = 0
    while i < length-1:
        if string[i] == '\\':
            i += 1
            if string[i] == 'n':
                out.append('\12')
            elif string[i] == 'r':
                out.append('\15')
            else:
                out.append(string[i])
        else:
            out.append(string[i])
        i += 1
    return '""' + ''.join(out) + '"""'    


def run():
    file_name = 'test.cfg'
    error = ''
    if len(sys.argv) > 1:
        file_name = sys.argv[1]
    if not os.path.isfile(file_name):
        sys.stdout.write('ERR:F:\n')
        exit()
    data = open(file_name).read()
    try:
        tokenizer = Tokenizer(data)
        tokenizer.tokenize()
    except (FlexException, IllegalException, NullException):
        sys.stdout.write('ERR:L:%d\n'%tokenizer.lineno)
        exit()
    except IndexError:
        sys.stdout.write('ERR:L:%d\n'%tokenizer.lineno)
        exit()
    try:    
        p = Parser()
        tokens = remove_comments(tokenizer.tokens)
        last_line = tokens[-1].lineno
        p.parse(tokens)
    except PException,e:
        error = 'ERR:P:{0}\n'.format(e)#bugs?
    except IndexError:
        error = 'ERR:P:{0}\n'.format(last_line)
    finally:
        p.print_tree()
        sys.stdout.write(error)
if __name__ == '__main__':
    run()