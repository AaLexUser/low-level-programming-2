/*
* Parser for aql
*/
%{
#include "ast.h"
#include <stdlib.h>
%}

%union {
    int ival;
    double fval;
    char *sval;
    struct ast *ast;
    int subtok;
}
    /* names and literal values */
%token <sval> NAME STRING
%token <ival> INTVAL FLOATVAL BOOLVAL

    /* operators and precedence levels */
%left ','
%left OR
%left AND
%left IN CMP


    /* keywords */
%token FOR RETURN FILTER INSERT UPDATE REMOVE CREATE DROP

%token EOL

%type <ast> stmt_list stmt exp 
%type <ast> remove_stmt create_stmt drop_stmt return_stmt
%type <ast> filter_stmt insert_stmt update_stmt for_stmt
%locations
%start query
%define parse.error verbose

%%
stmt_list: stmt ';'
    |  stmt_list stmt ';'       { $$ = $2; }
    ;

stmt: filter_stmt
    |  insert_stmt
    |  update_stmt
    |  remove_stmt
    |  create_stmt
    |  drop_stmt
    |  return_stmt
    |  for_stmt
    ;

for_stmt: FOR NAME IN NAME
    {
        $$ = mkastnode(A_FOR, $2, $4, NULL, NULL, NULL);
    }
    ;

%%
