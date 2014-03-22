CC=cc
TARGETS=bison

all: $(TARGETS)

bison: bison.tab.o lex.yy.o
	 $(CC) -o bison bison.tab.o lex.yy.o

bison.tab.o: tree.h bison.y
	bison -d bison.y
	$(CC) -c bison.tab.c

lex.yy.o: flex.l bison.tab.h tree.h
	flex flex.l
	$(CC) -c lex.yy.c 

clean:
	rm *.o bison.tab.c bison.tab.h lex.yy.c $(TARGETS)
