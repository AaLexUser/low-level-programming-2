#ifndef AST_H
#define AST_H

/* interface to the lexer */
extern int yylineno; /* from lexer */
extern int yyparse(void);


typedef enum ntype {
    /* keywords */
    NT_FOR, NT_RETURN, NT_FILTER, NT_INSERT,
    NT_UPDATE, NT_REMOVE, NT_CREATE, NT_DROP,
    NT_PAIR,

    /* variable types */
    NT_INTEGER, NT_FLOAT, NT_STRING, NT_BOOLEAN,

    /* comparison ops */
    NT_EQ, NT_NEQ, NT_LT, NT_LTE, NT_GT, NT_GTE,
    NT_AND, NT_OR,

    /* values */
    NT_INTVAL, NT_FLOATVAL, NT_STRINGVAL, NT_BOOLVAL
} ntype_t;

struct ast {
    ntype_t nodetype;
    struct ast *l;
    struct ast *r;
};

struct nint {
    ntype_t nodetype;
    int value;
};

struct nfloat {
    ntype_t nodetype;
    float value;
};

struct nstring {
    ntype_t nodetype;
    char* value;
};

struct for_ast {
    ntype_t nodetype;
    char* var; 
    char* tabname;
    struct ast* action;
};

struct insert_ast {
    ntype_t nodetype;
    char* tabname;
    struct ast* values;
};

struct remove_ast {
    ntype_t nodetype;
    char* var;
    char* tabname;
};

struct pair_ast {
    ntype_t nodetype;
    char* key;
    struct ast* value;
    struct pair_ast* next;
};

struct condition_ast {
    ntype_t nodetype;
    struct ast* l;
    struct ast* r;
};

struct variable_ast {
    ntype_t nodetype;
    char* name;
};



struct ast*
newast(ntype_t nodetype, struct ast* l, struct ast* r);

struct ast*
newint(int value);

struct ast*
newfloat(float value);

struct ast*
newstring(char* value);

struct ast*
newbool(int value);

struct ast*
newfor(char* var, char* tabname, struct ast* action);







#endif