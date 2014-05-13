CC=cc
TARGETS=imp1

all: $(TARGETS)

imp1: bison.tab.o lex.yy.o
	 $(CC) -o imp1 bison.tab.o lex.yy.o

bison.tab.o: tree.h bison.y
	bison -d bison.y
	$(CC) -c bison.tab.c

lex.yy.o: flex.l bison.tab.h tree.h
	flex flex.l
	$(CC) -c lex.yy.c 
flex:	s_flex.l
	flex s_flex.l
	$(CC) -c lex.yy.c s_flex
clean:
	rm *.o bison.tab.c bison.tab.h lex.yy.c $(TARGETS)
