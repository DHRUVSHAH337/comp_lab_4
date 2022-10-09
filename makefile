a.out: lex.yy.o y.tab.o
	gcc lex.yy.o y.tab.o -lfl

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

y.tab.o: y.tab.c
	gcc -c y.tab.c

lex.yy.c: ass4_20CS10077_20CS10088.l y.tab.h
	flex ass4_20CS10077_20CS10088.l

y.tab.c y.tab.h: ass4_20CS10077_20CS10088.y
	bison -dty --report=all ass4_20CS10077_20CS10088.y

clean:
	rm a.out lex.yy.* y.tab.*