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
    def __init__(self,type,value=None,lineno=-1):
        self.type = type
        self.value = value
        self.lineno = lineno
        self.c1 = None
        self.c2 = None
        self.c3 = None
        self.c4 = None
        self.c5 = None
        self.c6 = None

    def error_handler(self):
        pass
        
    def get_node(self,nodes=[]):
#        print str(self.type) + self.value
#        print 'this is children of this node'

        if self.type in [GLOBAL_KEYWORD, HOST_KEYWORD, HOST_NAME, KEY, STRING, INT, FLOAT, EQUAL, QUOTED_STRING, RIGHT, SEMI, LEFT]:
            nodes.append(self)
        if self.type == ERROR:
            while nodes and nodes[-1].type != RIGHT:
                nodes.pop(-1)
            return     
        if self.c1:
            self.c1.get_node(nodes)
        if self.c2:
            self.c2.get_node(nodes)
        if self.c3:
            self.c3.get_node(nodes)
        if self.c4:
            self.c4.get_node(nodes)
        if self.c5:
            self.c5.get_node(nodes)
        if self.c6:
            self.c6.get_node(nodes)
            
    def __repr__(self):
        return str(self.type) + ':' +str(self.value)+ ':' + str(self.lineno)

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
            elif ord(self.data_str[n]) > 127:#only ascii
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
        return val

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
                self.tokens.append(Node(QUOTED_STRING,val,self.lineno))
            elif self.data_str[0] == '#':#take care of comments, \n extracted from comments
                self.comment()
                self.tokens.append(Node(COMMENT,'comment',self.lineno))
            elif self.data_str[0] == '=':#equal sign
                self.data_str = self.data_str[1:]
                val = '='
                self.tokens.append(Node(EQUAL,val,self.lineno))
            elif self.data_str[0] == '{':#right
                self.data_str = self.data_str[1:]
                val = '{'
                self.tokens.append(Node(LEFT,val,self.lineno))
            elif self.data_str[0] == '}':#left
                self.data_str = self.data_str[1:]
                val = '}'
                self.tokens.append(Node(RIGHT,val,self.lineno))
            elif self.data_str[0] == ';':#semicolon
                self.data_str = self.data_str[1:]
                val = ';'
                self.tokens.append(Node(SEMI,val,self.lineno))
            elif self.data_str[0] == '\n':#new line
                self.data_str = self.data_str[1:]
                val = '\n'
                self.tokens.append(Node(NEW_LINE,val,self.lineno))
                self.lineno += 1
            elif self.data_str[0] == ' ':#space bug?
                self.data_str = self.data_str[1:]
            elif self.data_str[0].isalpha() or self.data_str[0].isdigit() or (self.data_str[0] in ['+','-','_','.','/']):#any other self.data_string,etc.key,value,host,gloal,signed number
                val = self.data_str[0]
                self.data_str = self.data_str[1:]
                while len(self.data_str):
                    if self.data_str[0] not in [' ','{','}',';','=','\n','#']:
                        val += self.data_str[0]
                        self.data_str = self.data_str[1:]
                    else:
                        self.tokens.append(Node(STRING,val,self.lineno))
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
    except (FlexException, IllegalException, NullException):
        print 'E:L:%d'%tokenizer.lineno
        
