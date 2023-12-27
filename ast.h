#ifndef AST_H
#define AST_H

typedef enum ntype {
    /* keywords */
    NT_FOR, NT_RETURN, NT_FILTER, NT_INSERT,
    NT_UPDATE, NT_REMOVE, NT_CREATE, NT_DROP,

    /* variable types */
    NT_INTEGER, NT_FLOAT, NT_STRING, NT_BOOLEAN,

    /* comparison ops */
    NT_EQ, NT_NEQ, NT_LT, NT_LTE, NT_GT, NT_GTE,
    NT_AND, NT_OR

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
    char* var; 
    char* tabname;
    struct ast action;
};





#endif