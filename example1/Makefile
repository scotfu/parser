CC=cc
TARGETS=example flex-only c-only

all: $(TARGETS)

example: bison-example.tab.o lex.yy.o
	$(CC) -o  example bison-example.tab.o lex.yy.o

bison-example.tab.o: example.h bison-example.y
	bison -d bison-example.y
	$(CC) -c bison-example.tab.c

lex.yy.o: example.h bison-example.tab.h flex-example.f
	flex flex-example.f
	$(CC) -c lex.yy.c

flex-only: standalone-lexer.f
	flex standalone-lexer.f
	$(CC) -o flex-only lex.yy.c

c-only: c_example.c
	$(CC) -o c-only c_example.c

clean:
	-rm *.o *~ bison-example.tab.c bison-example.tab.h lex.yy.c $(TARGETS)
