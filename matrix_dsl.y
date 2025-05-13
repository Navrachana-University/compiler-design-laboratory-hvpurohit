%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
extern char *yytext;
int yylex(void);
void yyerror(const char *s);

typedef struct {
    char *id;
    int values[2][2];
} Matrix;

Matrix symtab[100];
int symtab_index = 0;
int temp_counter = 0;

char* new_temp() {
    char *temp = malloc(32);
    if (!temp) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    sprintf(temp, "t%d", ++temp_counter);
    return temp;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s at or near '%.10s'\n", s, yytext);
}

void print_matrix(Matrix m) {
    printf("[%d, %d; %d, %d]", m.values[0][0], m.values[0][1],
                               m.values[1][0], m.values[1][1]);
}

Matrix matrix_add(Matrix m1, Matrix m2) {
    Matrix res;
    for (int i = 0; i < 2; i++)
        for (int j = 0; j < 2; j++)
            res.values[i][j] = m1.values[i][j] + m2.values[i][j];
    return res;
}

Matrix matrix_scalar_mul(Matrix m, int s) {
    Matrix res;
    for (int i = 0; i < 2; i++)
        for (int j = 0; j < 2; j++)
            res.values[i][j] = m.values[i][j] * s;
    return res;
}

Matrix matrix_transpose(Matrix m) {
    Matrix res;
    for (int i = 0; i < 2; i++)
        for (int j = 0; j < 2; j++)
            res.values[i][j] = m.values[j][i];
    return res;
}

Matrix get_matrix_by_id(const char *id) {
    for (int i = 0; i < symtab_index; i++)
        if (strcmp(symtab[i].id, id) == 0)
            return symtab[i];

    Matrix empty;
    empty.id = NULL;
    for (int i = 0; i < 2; i++)
        for (int j = 0; j < 2; j++)
            empty.values[i][j] = 0;
    return empty;
}
%}

%union {
    int num;
    char *id;
}

%token MAT PRINT ADD MUL EMUL ASSIGN SEMI COMMA LBRACK RBRACK LPAREN RPAREN
%token <num> NUM
%token <id> ID
%token TRANSPOSE

%type <id> expr
%type <num> number

%%

program:
    stmt_list { printf("// TAC Generation Complete\n"); }
;

stmt_list:
    stmt stmt_list
    | /* empty */
;

stmt:
      matrix_decl
    | matrix_op
    | print_stmt
;

matrix_decl:
    MAT ID ASSIGN LBRACK number COMMA number SEMI number COMMA number RBRACK SEMI {
        int a = $5;
        int b = $7;
        int c = $9;
        int d = $11;

        symtab[symtab_index].id = strdup($2);
        symtab[symtab_index].values[0][0] = a;
        symtab[symtab_index].values[0][1] = b;
        symtab[symtab_index].values[1][0] = c;
        symtab[symtab_index].values[1][1] = d;

        printf("// Matrix %s = ", $2);
        print_matrix(symtab[symtab_index]);
        printf(" declared\n");

        symtab_index++;
    }
;

matrix_op:
    MAT ID ASSIGN expr SEMI {
        printf("%s = %s\n", $2, $4);

        Matrix temp_result = get_matrix_by_id($4);

        symtab[symtab_index].id = strdup($2);
        symtab[symtab_index].values[0][0] = temp_result.values[0][0];
        symtab[symtab_index].values[0][1] = temp_result.values[0][1];
        symtab[symtab_index].values[1][0] = temp_result.values[1][0];
        symtab[symtab_index].values[1][1] = temp_result.values[1][1];
        symtab_index++;
    }
;

expr:
      ID ADD ID {
        $$ = new_temp();
        Matrix m1 = get_matrix_by_id($1);
        Matrix m2 = get_matrix_by_id($3);
        Matrix res = matrix_add(m1, m2);

        symtab[symtab_index].id = strdup($$);
        symtab[symtab_index].values[0][0] = res.values[0][0];
        symtab[symtab_index].values[0][1] = res.values[0][1];
        symtab[symtab_index].values[1][0] = res.values[1][0];
        symtab[symtab_index].values[1][1] = res.values[1][1];
        symtab_index++;

        printf("%s = %s + %s\n", $$, $1, $3);
    }
    | NUM MUL ID {
        $$ = new_temp();
        Matrix m = get_matrix_by_id($3);
        Matrix res = matrix_scalar_mul(m, $1);

        symtab[symtab_index].id = strdup($$);
        symtab[symtab_index].values[0][0] = res.values[0][0];
        symtab[symtab_index].values[0][1] = res.values[0][1];
        symtab[symtab_index].values[1][0] = res.values[1][0];
        symtab[symtab_index].values[1][1] = res.values[1][1];
        symtab_index++;

        printf("%s = %d * %s\n", $$, $1, $3);
    }
    | ID MUL NUM {
        $$ = new_temp();
        Matrix m = get_matrix_by_id($1);
        Matrix res = matrix_scalar_mul(m, $3);

        symtab[symtab_index].id = strdup($$);
        symtab[symtab_index].values[0][0] = res.values[0][0];
        symtab[symtab_index].values[0][1] = res.values[0][1];
        symtab[symtab_index].values[1][0] = res.values[1][0];
        symtab[symtab_index].values[1][1] = res.values[1][1];
        symtab_index++;

        printf("%s = %s * %d\n", $$, $1, $3);
    }
    | TRANSPOSE LPAREN ID RPAREN {
        $$ = new_temp();
        Matrix m = get_matrix_by_id($3);
        Matrix res = matrix_transpose(m);

        symtab[symtab_index].id = strdup($$);
        symtab[symtab_index].values[0][0] = res.values[0][0];
        symtab[symtab_index].values[0][1] = res.values[0][1];
        symtab[symtab_index].values[1][0] = res.values[1][0];
        symtab[symtab_index].values[1][1] = res.values[1][1];
        symtab_index++;

        printf("%s = transpose %s\n", $$, $3);
    }
    | LPAREN expr RPAREN {
        $$ = $2;
    }
;

print_stmt:
    PRINT LPAREN ID RPAREN SEMI {
        Matrix m = get_matrix_by_id($3);
        printf("PRINT %s = ", $3);
        print_matrix(m);
        printf("\n");
    }
;

number:
    NUM { $$ = $1; }
;

%%

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Error opening file");
            return 1;
        }
        yyin = file;
    }
    yyparse();
    if (argc > 1 && yyin != stdin) {
        fclose(yyin);
    }
    return 0;
}
