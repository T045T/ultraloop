all:
	bison -d ultrastar.y
	flex ultrastar.l
	mv lex.yy.c lex.yy.cpp
	mv ultrastar.tab.c ultrastar.tab.cpp
	clang++ ultrastar.tab.cpp lex.yy.cpp -o ultraloop
clean:
	rm lex.yy.cpp ultrastar.tab.*
