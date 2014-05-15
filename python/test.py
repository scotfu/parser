#! /usr/bin/env python

class Person:
    def  __init__(self, age=None, name=None):
        self.age = age
        self.name = name
    
    def getName(self):
        return self.name
        
    def getAge(self):
        return self.age
        
    def setAge(self,age):
        self.age = age
    def setName(self, name):
        self.name = name
                    
test_age = 10;
test_name = "Tom"
P = Person()
P.setAge(test_name);             # works just fine
P.setName(test_age);            #works just fine
a = "Hello, your name is " + P.getName()  #Gotcha you, unexpected type error
# TypeError: cannot concatenate 'str' and 'int' objects