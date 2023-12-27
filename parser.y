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
%token <sval> NAME STRINGVAL
%token <ival> INTVAL FLOATVAL BOOLVAL

    /* operators and precedence levels */
%left ','
%left OR
%left AND
%left IN CMP


    /* keywords */
%token FOR RETURN FILTER INSERT UPDATE REMOVE WITH INTO


%token EOL

%type <ast> stmt_list stmt 
%type <ast> remove_stmt return_stmt
%type <ast> filter_stmt insert_stmt update_stmt for_stmt
%type <ast> condition constant variable
%type <ast> document pairs pair
%locations
%start query
%parse-param { struct ast *root; }
%define parse.error verbose

%%
stmt_list: stmt ';'
    |  EOL stmt_list stmt ';'    { $$ = $2; }
    ;

stmt: filter_stmt
    |  insert_stmt
    |  update_stmt
    |  remove_stmt
    |  return_stmt
    |  for_stmt
    ;

for_stmt: FOR NAME IN NAME stmt_list    {
                                            $$ = newfor($2, $4, $5);
                                            *root = $$;
                                        }
    ;

filter_stmt: FILTER condition           { $$ = newfilter($2); }
    ;

condition: '(' condition ')'            { $$ = $2; }
    | condition AND condition           { $$ = newand($1, $3); }
    | condition OR condition            { $$ = newor($1, $3); }
    | constant CMP constant             { $$ = newcmp($1, $2, $3); }
    | constant IN constant              { $$ = newin($1, $3); }
    ;

constant: INTVAL                         { $$ = newint($1); }
        | FLOATVAL                       { $$ = newfloat($1); }
        | BOOLVAL                        { $$ = newbool($1); }
        | STRINGVAL                      { $$ = newstring($1); }
        | variable                       { $$ = $1; }
        ;

variable: NAME                          { $$ = newvar($1); }
        | NAME '.' NAME                 { $$ = newvar($1); $$->right = newvar($3); }
        ;

remove_stmt: REMOVE NAME IN NAME        { $$ = newremove($2, $4); }
    ;

insert_stmt: INSERT document INTO NAME  { $$ = newinsert($2, $4); }
    ;

update_stmt: UPDATE document IN NAME
        | UPDATE NAME WITH document IN NAME 
        ;
return_stmt: RETURN constant             { $$ = newreturn($2); }
        |    RETURN document             { $$ = newreturn($2); }
    ;

document: '{' pairs '}'                  { $$ = $2; }
        ;
pairs: pair
    | pairs ',' pair                     { $$ = $3;}
    ;

pair: NAME ':' constant                  { $$ = newpair($1, $3); }

%%

void
yyerror(char *s, ...)
{
    va_list ap;
    va_start(ap, s);

    if(yylloc.first_line)
        fprintf(stderr, "%d.%d-%d.%d: error: ", 
        yylloc.first_line, yylloc.first_column, yylloc.last_line, yylloc.last_column);
    vfprintf(stderr, s, ap);
    fprintf(stderr, "\n");
}
