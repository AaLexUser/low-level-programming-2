# Makefile for lab2
CC = gcc
LEX = flex
YACC = bison
CFLAGS = -g -DYYDEBUG=1

PROGRAM = lab2

.PHONY: all clean debug
default: all

all: clean ${PROGRAM}

${PROGRAM}: ast.h parser.tab.c lexer.c
	${CC} -o ${PROGRAM} ast.c parser.tab.c lexer.c

parser.tab.c parser.tab.h: parser.y
	${YACC} -d parser.y

lexer.c: lexer.l
	${LEX} -o lexer.c lexer.l

clean:
	rm -f ${PROGRAM} parser.tab.c parser.tab.h lexer.c

debug: ast.h parser.tab.c lexer.c
	${CC} -o ${PROGRAM} ${CFLAGS} ast.c parser.tab.c lexer.c



