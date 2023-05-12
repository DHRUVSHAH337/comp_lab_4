ROLL=ass6_20CS10077_20CS10088

assgen: lex.yy.o y.tab.o $(ROLL)_translator.o $(ROLL)_target_translator.o
	g++ lex.yy.o y.tab.o $(ROLL)_translator.o $(ROLL)_target_translator.o -lfl -o assgen

$(ROLL)_target_translator.o: $(ROLL)_target_translator.cxx
	g++ -c $(ROLL)_target_translator.cxx

$(ROLL)_translator.o: $(ROLL)_translator.h $(ROLL)_translator.cxx
	g++ -c $(ROLL)_translator.h
	g++ -c $(ROLL)_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

y.tab.o: y.tab.c
	g++ -c y.tab.c

lex.yy.c: $(ROLL).l y.tab.h $(ROLL)_translator.h
	flex $(ROLL).l

y.tab.c y.tab.h: $(ROLL).y
	bison -Wconflicts-sr -dty --report=all $(ROLL).y

lib$(ROLL).a: $(ROLL)_lib.o
	ar -rcs lib$(ROLL).a $(ROLL)_lib.o

$(ROLL)_lib.o: $(ROLL)_lib.c myl.h
	gcc -c $(ROLL)_lib.c

$(ROLL)_lib.c:
	touch $(ROLL)_lib.c

test1:lib$(ROLL).a assgen
	./assgen 1 < ass6_20CS10077_20CS10088_test1.c > ass6_20CS10077_20CS10088__quads1.out
	gcc ass6_20CS10077_20CS10088_1.s -L. -lass6_20CS10077_20CS10088 -no-pie -o output

test2:lib$(ROLL).a assgen
	./assgen 2 < ass6_20CS10077_20CS10088_test2.c > ass6_20CS10077_20CS10088__quads2.out
	gcc ass6_20CS10077_20CS10088_2.s -L. -lass6_20CS10077_20CS10088 -no-pie -o output

test3:lib$(ROLL).a assgen
	./assgen 3 < ass6_20CS10077_20CS10088_test3.c > ass6_20CS10077_20CS10088__quads3.out
	gcc ass6_20CS10077_20CS10088_3.s -L. -lass6_20CS10077_20CS10088 -no-pie -o output

test4:lib$(ROLL).a assgen
	./assgen 4 < ass6_20CS10077_20CS10088_test4.c > ass6_20CS10077_20CS10088__quads4.out
	gcc ass6_20CS10077_20CS10088_4.s -L. -lass6_20CS10077_20CS10088 -no-pie -o output

test5:lib$(ROLL).a assgen
	./assgen 5 < ass6_20CS10077_20CS10088_test5.c > ass6_20CS10077_20CS10088__quads5.out
	gcc ass6_20CS10077_20CS10088_5.s -L. -lass6_20CS10077_20CS10088 -no-pie -o output


clean:
	rm -f lex.yy.c *.tab.c *.tab.h *.output *.o *.s *.a *.out *.gch assgen output