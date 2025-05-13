%{
#include "matrix_dsl.tab.h"
#include <stdlib.h>
#include <string.h>
void yyerror(const char *s);
%}

%option noyywrap

%%
"mat"       { return MAT; }
"print"     { return PRINT; }
"transpose" { return TRANSPOSE; }  // ✅ Added support
"+"         { return ADD; }
"*"         { return MUL; }
".*"        { return EMUL; }
"="         { return ASSIGN; }
";"         { return SEMI; }
","         { return COMMA; }
"["         { return LBRACK; }
"]"         { return RBRACK; }
"("         { return LPAREN; }
")"         { return RPAREN; }
[0-9]+      { yylval.num = atoi(yytext); return NUM; }
[a-zA-Z][a-zA-Z0-9]* { yylval.id = strdup(yytext); return ID; }
[ \t\n]     ;  // skip whitespace
.           { yyerror("Invalid token"); }
%%
