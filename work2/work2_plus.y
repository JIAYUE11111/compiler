%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include <string.h>
#ifndef YYSTYPE
#define YYSTYPE char*
#endif
char digit[20];
char id[20];
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

//TODO:给每个符号定义一个单词类别
%token ADD MINUS
%token MUL DIV
%token LPAREN RPAREN
%token NUMBER
%token ID


%left ADD MINUS
%left MUL DIV
%right UMINUS         

%%
lines   :       lines expr ';' { printf("%s\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   {$$=(char*)malloc(strlen($1) + strlen($3) + 4);sprintf($$,"%s %s +",$1,$3);free($1);free($3);}
        |       expr MINUS expr  {$$=(char*)malloc(strlen($1) + strlen($3) + 4);sprintf($$,"%s %s -",$1,$3);free($1);free($3);}
        |       expr MUL expr  {$$=(char*)malloc(strlen($1) + strlen($3) + 4);sprintf($$,"%s %s *",$1,$3);free($1);free($3);}
        |       expr DIV expr  {$$=(char*)malloc(strlen($1) + strlen($3) + 4);sprintf($$,"%s %s /",$1,$3);free($1);free($3);}
        |       LPAREN expr RPAREN {$$=(char*)malloc(strlen($2)+1);strcpy($$,$2);free($2);}
        |       MINUS expr %prec UMINUS   {$$=(char*)malloc(strlen($2)+5);sprintf($$,"%s neg",$2);free($2);}
        |       NUMBER  {$$=(char*)malloc(strlen($1)+1);strcpy($$,$1);}
        |       ID {$$=(char*)malloc(strlen($1)+1);strcpy($$,$1);}
        ;
%%

// programs section

int yylex()
{
    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            continue;
        }else if(isdigit(t)){
            //TODO:解析多位数字返回数字类型
            char *p=digit;
            while(isdigit(t)&&p-digit<20-1)
            {
                *(p++)=t;
                t=getchar();
            }
            *p = '\0';
            yylval = digit;
            ungetc(t,stdin);
            return NUMBER;
        }
        else if ((t >= 'a' && t <= 'z') || (t >= 'A' && t <= 'Z') || (t == '_'))
        {
            char *q=id;
            while((t >= 'a' && t <= 'z') || (t >= 'A' && t <= 'Z') || (t == '_')||(t<='9'&&t>='0'))
            {
                *(q++)=t;
                t=getchar();
            }
            *q='\0';
            yylval=id;
            ungetc(t,stdin);
            return ID;
        }
        else if(t=='+'){
            return ADD;
        }else if(t=='-'){
            return MINUS;
        }//TODO:识别其他符号
        else if(t=='*'){
            return MUL;
        }
        else if(t=='/'){
            return DIV;
        }
        else if(t=='(')
        {
            return LPAREN;
        }
        else if(t==')')
        {
            return RPAREN;
        }
        else{
            return t;
        }
    }
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}