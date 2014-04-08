#!/usr/bin/env python
import os
import sys
import re


from constants import *





class FlexException(Exception):
    pass

class NullException(Exception):
    pass

class IllegalException(Exception):
    pass

class Node:
    def __init__(self,type,value=None):
        self.type = type
        self.value = value
        self.c1 = None
        self.c2 = None
        self.c3 = None
        self.c4 = None
        self.c5 = None
        self.c6 = None

    def print_node(self,thisnodeout=[]):
#        print str(self.type) + self.value
#        print 'this is children of this node'

        if self.type == GLOBAL_KEYWORD:
            thisnodeout.append('GLOBAL:\n')
        if self.type == HOST_KEYWORD:
            thisnodeout.append('HOST ')
        if self.type == HOST_NAME:
            thisnodeout.append(self.value +':\n')
        if self.type == KEY:
            thisnodeout.append(self.value)
        if self.type == STRING:
            thisnodeout.append(self.value+'\n')
        if self.type == INT:
            thisnodeout.append(self.value+'\n')
        if self.type == FLOAT:
            thisnodeout.append(self.value+'\n')
        if self.type == EQUAL:
            thisnodeout.append(':')
        if self.type == QUOTED_STRING:
            thisnodeout.append(self.value + '\n')


        if self.c1:
            self.c1.print_node(thisnodeout)
        if self.c2:
            self.c2.print_node(thisnodeout)
        if self.c3:
            self.c3.print_node(thisnodeout)
        if self.c4:
            self.c4.print_node(thisnodeout)
        if self.c5:
            self.c5.print_node(thisnodeout)
        if self.c6:
            self.c6.print_node(thisnodeout)
            
    def __repr__(self):
        return str(self.type) + ':' +str(self.value)

class Tokenizer:
    def __init__(self,data_str):
        self.data_str = data_str
        self.lineno = 1
        self.tokens = []    

    def quoted_string(self): # "" are needed
        n = 1
        while True:
            if self.data_str[n] == '\n':
                raise FlexException
            elif self.data_str[n] != '"':
                n += 1
            else:
                if self.data_str[n-1] == '\\':
                    n += 1
                else:
                    n += 1
                    val = self.data_str[:n]
                    break
        self.data_str = self.data_str[n:]
        return '""'+val+'""'        

    def comment(self):
        while self.data_str[0] != '\n':
            self.data_str = self.data_str[1:]
            
    def tokenize(self):
        if '\0' in self.data_str:
            raise NullException
        while len(self.data_str):
            val = ''
            if self.data_str[0] == '"':#take care of quoted self.data_strings
                val = self.quoted_string()
                self.tokens.append(Node(QUOTED_STRING,val))
            elif self.data_str[0] == '#':#take care of comments, \n extracted from comments
                self.comment()
                self.tokens.append(Node(COMMENT,'comment'))
            elif self.data_str[0] == '=':#equal sign
                self.data_str = self.data_str[1:]
                val = '='
                self.tokens.append(Node(EQUAL,val))
            elif self.data_str[0] == '{':#right
                self.data_str = self.data_str[1:]
                val = '{'
                self.tokens.append(Node(LEFT,val))
            elif self.data_str[0] == '}':#left
                self.data_str = self.data_str[1:]
                val = '}'
                self.tokens.append(Node(RIGHT,val))
            elif self.data_str[0] == ';':#semicolon
                self.data_str = self.data_str[1:]
                val = ';'
                self.tokens.append(Node(SEMI,val))
            elif self.data_str[0] == '\n':#new line
                self.data_str = self.data_str[1:]
                val = '\n'
                self.lineno += 1
                self.tokens.append(Node(NEW_LINE,val))
            elif self.data_str[0] == ' ':#space bug?
                self.data_str = self.data_str[1:]
            elif self.data_str[0].isalpha() or self.data_str[0].isdigit() or (self.data_str[0] in ['-','_','.','/']):#any other self.data_string,etc.key,value,host,gloal
                val = self.data_str[0]
                self.data_str = self.data_str[1:]
                while len(self.data_str):
                    if self.data_str[0] not in [' ','{','}',';','=','\n']:
                        val += self.data_str[0]
                        self.data_str = self.data_str[1:]
                    else:
                        self.tokens.append(Node(STRING,val))
                        break
            else:
                raise IllegalException
                #print 'Warning, invalide characters',self.data_str[0],self.lineno
                #self.data_str = self.data_str[1:]

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
        
