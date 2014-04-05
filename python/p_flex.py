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
    
def quoted_string(str): # pass anything start from " "
    n = 1
    while True:
        if str[n] == '\n':
            raise FlexException
        elif str[n] != '"':
            n += 1
        else:
            if str[n-1] == '\\':
                n += 1
            else:
                val = str[:n]
                break
    return str[n+1:],val        

def comment(str):
    while str[0] != '\n':
        str = str[1:]
    return str    

def tokenize(str):
    tokens = []

    # test for null
    if '\0' in str:
        raise NullException
    while len(str):
        val = ''
        if str[0] == '"':#take care of quoted strings
            str, val = quoted_string(str)
            tokens.append(Node(QUOTED_STRING,val))
        elif str[0] == '#':#take care of comments
            str = comment(str)
            tokens.append(Node(COMMENT))
        elif str[0] == '=':#equal sign
            str = str[1:]
            val = '='
            tokens.append(Node(EQUAL,val))
        elif str[0] == '{':#right
            str = str[1:]
            val = '{'
            tokens.append(Node(LEFT,val))
        elif str[0] == '}':#left
            str = str[1:]
            val = '}'
            tokens.append(Node(RIGHT,val))
        elif str[0] == ';':#semicolon
            str = str[1:]
            val = ';'
            tokens.append(Node(SEMI,val))
        elif str[0] == '\n':#new line
            str = str[1:]
            val = '\n'
            tokens.append(Node(NEW_LINE,val))
        elif str[0] == ' ':#space bug?
            str = str[1:]
        elif str[0].isalpha() or str[0].isdigit() or (str[0] in ['-','_','.','/']):#any other string,etc.key,value,host,gloal
            val = str[0]
            str = str[1:]
            while len(str):
                if str[0] not in [' ','{','}',';','=','\n']:
                    val += str[0]
                    str = str[1:]
                else:
                    tokens.append(Node(STRING,val))
                    break
        else:
            print 'Warning, invalide characters',str[0]
            str = str[1:]
    return tokens

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
        pprint.pprint(tokenize(data))
    except FlexException,lineno:
        print 'E:L:%d'%lineno
        
