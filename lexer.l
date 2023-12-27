%option noyywrap nodefault yylineno caseless
%{
#include "ast.h"

extern YYSTYPE yylval;
int oldstate;
%}

%x COMMENT

%%

    /* keywords */
for         { return FOR; }
return      { return RETURN; }
filter      { return FILTER; }
insert      { return INSERT; }
update      { return UPDATE; }
remove      { return REMOVE; }

in          { return IN; }
into        { return INTO; }

create      { return CREATE; }
drop        { return DROP; }

int         { return INTEGER; }
float       { return FLOAT; }
string      { return STRING; }
bool        { return BOOLEAN; }

    /* numbers */
-[0-9]+      { yylval.ival = atoi(yytext); return INTVAL; }

-?[0-9]+"."[0-9]*               |
-?"."[0-9]+                     |
-?[0-9]+E[-+]?[0-9]+            |
-?[0-9]+"."[0-9]*E[-+]?[0-9]+   |
-?"."[0-9]+E[-+]?[0-9]+         { yylval.fval = atof(yytext); return FLOATVAL; }

    /* booleans */
true        { yylval.ival = 1; return BOOLVAL; }
false       { yylval.ival = 0; return BOOLVAL; }

    /* strings */
'(\\.|''|[^'\n])*'              |
\"(\\.|\"\"|[^"\n])*\"          { yylval.sval = strdup(yytext); return STRINGVAL; }

'(\\.|[^'\n])*$                 |
\"(\\.|[^"\n])*$                { yyerror("unterminated string %s", yytext); }

    /* operators */
[(){}:,;]        { return yytext[0]; }

"&&"            { return AND; }
"||"            { return OR; }

"<"             { yylval.subtok = 1; return CMP; }
">"             { yylval.subtok = 2; return CMP; }
"!="            { yylval.subtok = 3; return CMP; }
"=="            { yylval.subtok = 4; return CMP; }
"<="            { yylval.subtok = 5; return CMP; }
">="            { yylval.subtok = 6; return CMP; }

    /* names */
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.sval = strdup(yytext); return NAME; }
`[^`/\\.\n]+`           { 
                            yylval.sval = strdup(yytext + 1);
                            yylval.sval[yyleng-2] = 0;
                            return NAME; 
                        }
`[^`\n]*$               { yyerror("unterminated quoted name %s", yytext); }

    /* comments */

"/*"                    { oldstate = YY_START; BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(oldstate); }
<COMMENT>.|\n           { }

    /* whitespace */
[ \t\r\n]+              { }

    /* everything else */
.                       { yyerror("mystery character '%c'", *yytext); }

%%
