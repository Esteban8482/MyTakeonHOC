%{
    #include "hoc.h"
    extern double Pow();
%}
%union {
    double val;
    Symbol *sym;
}
%token <val> NUMBER
%token <sym> VAR BLTIN UNDEF
%type <val> expr asgn
%right '='
%left '+' '-'
%left '*' '/'
%left UNARYMINUS
%right '^'

%%
list:
    | list '\n'
    | list asgn '\n' 
    | list expr '\n'  { printf("\t%.8g\n", $2); }
    | list error '\n' { yyerrok; }
    ;
asgn:   VAR '=' expr { $$ = $1 -> u.val = $3; $1 -> type = VAR;}
    ;
expr:   NUMBER
    | VAR                       {
        if ($1 -> type == UNDEF)
            execerror("undefined variable", $1 -> name);
        $$ = $1 -> u.val;}
    | asgn
    | BLTIN '(' expr ')'        { $$ = (*($1 -> u.ptr))($3); }
    | expr '+' expr             { $$ = $1 + $3; }
    | expr '-' expr             { $$ = $1 - $3; }
    | expr '*' expr             { $$ = $1 * $3; }
    | expr '/' expr             {
        if ($3 == 0.0)
            execerror("division by zero", "");
        else
            $$ = $1 / $3;}
    | '(' expr ')'              { $$ = $2; }
    | '-' expr %prec UNARYMINUS { $$ = -$2; }
    ;
%%

#include <signal.h>
#include <setjmp.h>
#include <stdio.h>
#include <ctype.h>
jmp_buf begin;
char *progname;
int lineno = 1;

main(argc, argv)
    char *argv[];
{
    int fpecatch();

    progname = argv[0];
    setjmp(begin);
    signal(SIGFPE, fpecatch);
    yyparse();
}

execerror(s, t)
    char *s, *t;
{
    warning(s, t);
    longjmp(begin, 0);
}

fpecatch()
{
    execerror("floating point exception", (char *) 0);
}

yylex()
{
    int c;

    while ((c = getchar()) == ' ' || c == '\t')
        ;
    if (c == EOF)
        return 0;
    if (c == '.' || isdigit(c)) {
        ungetc(c, stdin);
        scanf("%lf", &yylval.val);
        return NUMBER;
    }
    if (islower(c)) {
        yylval.index = c - 'a';
        return VAR;
    }
    if (c == '\n')
        lineno++;
    return c;
}

yyerror(s)
    char *s;
{
    warning(s, (char *) 0);
}

warning(s, t)
    char *s, *t;
{
    fprintf(stderr, "%s: %s", progname, s);
    if(t)
        fprintf(stderr, " %s", t);
    fprintf(stderr, " near line %d\n", lineno);
}