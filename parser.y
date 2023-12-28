/*
* Parser for aql
*/
%{
#include "ast.h"
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
extern int yylex();
%}

%union {
    int ival;
    double fval;
    char *sval;
    struct ast *ast;
    int subtok;
}
    /* names and literal values */
%token <sval> VARNAME STRINGVAL
%token <ival> INTVAL BOOLVAL
%token <fval> FLOATVAL

    /* operators and precedence levels */
%left ','
%left OR
%left AND
%left <subtok> IN CMP


    /* keywords */
%token FOR RETURN FILTER INSERT UPDATE REMOVE WITH INTO CREATE DROP MERGE

    /* types */
%token<subtok> TYPE

    /* punctuation */


%token EOL YYEOF

%type <ast> for_stmt non_terminal_list
%type <ast> constant 
%type <ast> filter_stmt conditions filter_expr filter_attr_name
%type <ast> return_stmt attr_name return_document return_pairs return_pair merge
%type <ast> terminal query non_terminal
%type <ast> insert_stmt document pairs pair
%type <ast> update_stmt remove_stmt drop_stmt
%type <ast> create_stmt create_pairs create_pair

%locations
%start query
%define parse.error verbose

%%
terminal: return_stmt
    | insert_stmt
    | update_stmt
    | remove_stmt
    | create_stmt
    | drop_stmt
    ;
non_terminal: filter_stmt
    |  for_stmt
    ;

query: terminal                         { $$ = $1; print_ast(stdout, $$, 0); free_ast($$); }
    | for_stmt                          { $$ = $1; print_ast(stdout, $$, 0); free_ast($$);}

for_stmt: FOR VARNAME IN VARNAME terminal YYEOF                     { $$ = newfor($2, $4, NULL, $5); }
    | FOR VARNAME IN VARNAME non_terminal_list terminal YYEOF       { $$ = newfor($2, $4, $5, $6); }
    | FOR VARNAME IN VARNAME non_terminal_list YYEOF                { $$ = newfor($2, $4, $5, NULL); }
    ;

non_terminal_list: non_terminal                             { $$ = newlist($1, NULL);}  
    | non_terminal_list non_terminal                        { $$ = newlist($2, $1);}
    ;

/*---------------filter-----------------*/
filter_stmt: FILTER conditions              { $$ = newfilter($2); }
    ;
conditions: '(' filter_expr ')'             { $$ = newfilter_condition($2, NULL, -1);}
    | filter_expr                           { $$ = newfilter_condition($1, NULL, -1);}
    | filter_expr AND conditions            { $$ = newfilter_condition($1, $3, NT_AND);}
    | filter_expr OR conditions             { $$ = newfilter_condition($1, $3, NT_OR);}
    ;
filter_expr: filter_attr_name CMP constant       { $$ = newfilter_expr($1, $3, $2);}
    | constant IN filter_attr_name              { $$ = newfilter_expr($3, $1, $2);}
    ;

filter_attr_name: VARNAME '.' VARNAME         { $$ = newattr_name($1, $3);}

/*---------------return-----------------*/
return_stmt: RETURN attr_name             { $$ = newreturn($2); }
    |    RETURN return_document           { $$ = newreturn($2); }
    |    RETURN MERGE '(' merge ')'       { $$ = newreturn($4); }

merge: VARNAME ',' VARNAME                { $$ = newmerge($1, $3); }
    ;
attr_name: VARNAME '.' VARNAME         { $$ = newattr_name($1, $3);}
    | VARNAME                          { $$ = newattr_name($1, NULL);}
    ;

return_document: '{' return_pairs '}'               { $$ = $2; }
    ;
return_pairs: return_pair
    | return_pairs ',' return_pair                  { $$ = newlist($3, $1);}
    ;
return_pair: VARNAME ':' attr_name                  { $$ = newpair($1, $3); }


constant: INTVAL                         { $$ = newint($1); }
        | FLOATVAL                       { $$ = newfloat($1); }
        | BOOLVAL                        { $$ = newbool($1); }
        | STRINGVAL                      { $$ = newstring($1); }
        ;

/*---------------insert-----------------*/
insert_stmt: INSERT document INTO VARNAME       { $$ = newinsert($4, $2); }
    ;

document : '{' pairs '}'                        { $$ = $2; }
    ;
pairs: pair                                     { $$ = newlist($1, NULL);}
    | pairs ',' pair                            { $$ = newlist($3, $1);}
    ;
pair: VARNAME ':' constant                      { $$ = newpair($1, $3); }

/*---------------update-----------------*/
update_stmt: UPDATE attr_name WITH document IN VARNAME       { $$ = newupdate($6, $2, $4); }
    ;

/*---------------remove-----------------*/
remove_stmt: REMOVE attr_name IN VARNAME       { $$ = newremove($4, $2); }
    ;
/*---------------create-----------------*/
create_stmt: CREATE VARNAME WITH '{' create_pairs '}'       { $$ = newcreate($2, $5); }
    ;
create_pairs: create_pair                           { $$ = newlist($1, NULL);}
    | create_pairs ',' create_pair                  { $$ = newlist($3, $1);}
    ;
create_pair: VARNAME ':' TYPE                      { $$ = newcreate_pair($1, $3); }
    ;

/*---------------drop-----------------*/
drop_stmt: DROP VARNAME       { $$ = newdrop($2); }
    ;

%%

void
yyerror(const char *s, ...)
{
    va_list ap;
    va_start(ap, s);

    if(yylloc.first_line)
        fprintf(stderr, "%d.%d-%d.%d: error: ", 
        yylloc.first_line, yylloc.first_column, yylloc.last_line, yylloc.last_column);
    vfprintf(stderr, s, ap);
    fprintf(stderr, "\n");
}
