cd parser
lex subc.l
yacc -d subc.y
gcc lex.yy.c y.tab.c -o subc
./subc

