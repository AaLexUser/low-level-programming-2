#include "ast.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>


void print_key_value(const char* key, const char* value, int level)
{
    print_indent(stdout, level);
    printf("%s: %s\n", key, value);
}

struct ast*
newast(ntype_t nodetype, struct ast* l, struct ast* r)
{
    struct ast* ast = malloc(sizeof(struct ast));
    if (!ast) {
        yyerror("out of space");
        exit(0);
    }
    ast->nodetype = nodetype;
    ast->l = l;
    ast->r = r;
    return ast;
}

struct ast*
newint(int value)
{
    struct nint* intast = malloc(sizeof(struct nint));
    if (!intast) {
        yyerror("out of space");
        exit(0);
    }
    intast->nodetype = NT_INTVAL;
    intast->value = value;
    return (struct ast*)intast;
}

struct ast*
newfloat(float value)
{
    struct nfloat* floatast = malloc(sizeof(struct nfloat));
    if (!floatast) {
        yyerror("out of space");
        exit(0);
    }
    floatast->nodetype = NT_FLOATVAL;
    floatast->value = value;
    return (struct ast*)floatast;
}

struct ast*
newstring(char* value)
{
    struct nstring* stringast = malloc(sizeof(struct nstring));
    if (!stringast) {
        yyerror("out of space");
        exit(0);
    }
    stringast->nodetype = NT_STRINGVAL;
    stringast->value = value;
    return (struct ast*)stringast;
}

struct ast*
newbool(int value)
{
    struct nint* boolast = malloc(sizeof(struct nint));
    if (!boolast) {
        yyerror("out of space");
        exit(0);
    }
    boolast->nodetype = NT_BOOLVAL;
    boolast->value = value;
    return (struct ast*)boolast;
}

/*---------------------------for ast -----------------------------*/
struct ast*
newfor(char* var, char* tabname, struct ast* action)
{
    struct for_ast* forast = malloc(sizeof(struct for_ast));
    if (!forast) {
        yyerror("out of space");
        exit(0);
    }
    forast->nodetype = NT_FOR;
    forast->var = var;
    forast->tabname = tabname;
    forast->action = action;
    return (struct ast*)forast;
}

/*---------------------------insert ast -----------------------------*/

struct ast*
newinsrt(char* tabname, struct ast* values)
{
    struct insert_ast* insertast = malloc(sizeof(struct insert_ast));
    if (!insertast) {
        yyerror("out of space");
        exit(0);
    }
    insertast->nodetype = NT_INSERT;
    insertast->tabname = tabname;
    insertast->values = values;
    return (struct ast*)insertast;
}

/*---------------------------remove ast -----------------------------*/
struct ast*
newremove(char* var, char* tabname)
{
    struct remove_ast* removeast = malloc(sizeof(struct remove_ast));
    if (!removeast) {
        yyerror("out of space");
        exit(0);
    }
    removeast->nodetype = NT_REMOVE;
    removeast->var = var;
    removeast->tabname = tabname;
    return (struct ast*)removeast;
}



/*---------------------------pair ast -----------------------------*/

struct ast*
newpair(char* key, struct ast* value, struct ast* next)
{
    struct pair_ast* pairast = malloc(sizeof(struct pair_ast));
    if (!pairast) {
        yyerror("out of space");
        exit(0);
    }
    pairast->nodetype = NT_PAIR;
    pairast->key = key;
    pairast->value = value;
    pairast->next = next;
    return (struct ast*)pairast;
}

void print_ast(FILE* stream, struct ast* ast, int level)
{
    if (!ast) {
        return;
    }
    switch (ast->nodetype) {
        case NT_REMOVE: {
            print_remove(stream, ast, level);
            break;
        }
    }
}  

int main()
{
    printf("> ");
    return yyparse();
}
