#!/usr/bin/env python
import os
import sys

#Types for nodes
COMMENT = 1
QUOTED_STRING = 2
STRING = 3
LEFT = 4
RIGHT = 5
SEMI = 6
NEW_LINE = 7
EQUAL = 8



class FlexException(Exception):
    pass

class NullException(Exception):
    pass


class Node:
    def __init__(self,type,value=None):
        self.type = type
        self.value = value

    def __repr__(self):
        return str(self.type) + ':' +str(self.value)

class Tokenizer:
    def __init__(self,data_str):
        self.data_str = data_str
        self.lineno = 1
        self.tokens = []    

    def quoted_string(self): # pass anything start from " "
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
                    val = self.data_str[:n]
                    break
        self.data_str = self.data_str[n+1:]
        return val        

    def comment(self):
        while self.data_str[0] != '\n':
            self.data_str = self.data_str[1:]
            
    def tokenize(self):
        if '\0' in self.data_str:
            raise NullException
        while len(self.data_str):
            print len(self.data_str)
            val = ''
            if self.data_str[0] == '"':#take care of quoted self.data_strings
                val = self.quoted_string()
                self.tokens.append(Node(QUOTED_STRING,val))
            elif self.data_str[0] == '#':#take care of comments, \n extracted from comments
                self.comment()
                self.tokens.append(Node(COMMENT))
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
                print 'Warning, invalide characters',self.data_str[0],self.lineno
                self.data_str = self.data_str[1:]

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
        
