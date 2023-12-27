#include "cprint.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

void print_indent(FILE* stream, int level)
{
    char* indent = malloc(sizeof(char) * (level*2 + 1));
    memset(indent, '  ', level*2+1);
    indent[level*2] = '\0';
    fprintf(stream, "%s", indent);
    free(indent);

}

void print_node(FILE* stream, int level, char* string, ...)
{
    va_list args;
    va_start(args, string);
    print_indent(stream, level);
    vfprintf(stream, string, args);
    va_end(args);
}

void print_remove(FILE* stream, struct ast* ast, int level)
{
    if (!ast) {
        yyerror("ast is null");
        exit(0);
    }
    struct remove_ast* removeast = (struct remove_ast*)ast;
    print_node(stream, level, "remove:\n");
    print_node(stream, level+1, "table: %s\n", removeast->tabname);
    print_node(stream, level+1, "variable: %s\n", removeast->var);
    print_node(stream, level, "}\n");
}