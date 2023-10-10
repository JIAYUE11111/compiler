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
#include <string.h>
#include<ctype.h>
#ifndef YYSTYPE
#define YYSTYPE double
#endif
int yylex();
int tag;
double p;
char id[20];//用于存储字符变量名
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
typedef struct{
    char *name;
    double value;
}Symbol;

#define MAX_SYMBOLS 100
Symbol symtable[MAX_SYMBOLS];
int numSymbols=0;

double lookup(const char*name)
{
    for(int i=0;i<numSymbols;i++)
    {
        if(strcmp(name,symtable[i].name)==0)//符号表中存在这个id
        {
            return i;//返回其在符号表中的索引
        }
    }
    return -1;//标记符号表中没有这个值
}

double insert(const char*name)
{
    if(numSymbols<MAX_SYMBOLS)//符号表还有位置可以插入
    {
        symtable[numSymbols].name=strdup(name); 
        symtable[numSymbols].value=0;
        return numSymbols++;
    }
}
%}

//TODO:给每个符号定义一个单词类别
%token ADD MINUS
%token MUL DIV
%token LPAREN RPAREN
%token NUMBER
%token ASSIGN 
%token ID

%right ASSIGN
%left ADD MINUS
%left MUL DIV
%right UMINUS         

%%
lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   { $$=$1+$3; }
        |       expr MINUS expr  { $$=$1-$3; }
        |       expr MUL expr  {$$=$1*$3;}
        |       expr DIV expr  {$$=$1/$3;}
        |       LPAREN expr RPAREN {$$=$2;}
        |       MINUS expr %prec UMINUS   {$$=-$2;}
        |       NUMBER  {$$=$1;}
        |       ID ASSIGN expr{ tag=$1;$$=$3;symtable[tag].value=$3;}
        |       ID {tag=$1;$$=symtable[tag].value;}
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
            yylval=0;
            while(isdigit(t))
            {
                yylval=yylval*10+t-'0';
                t=getchar();
            }
            ungetc(t,stdin);
            return NUMBER;
        }else if ((t >= 'a' && t <= 'z') || (t >= 'A' && t <= 'Z') || (t == '_'))
        {
            char *q=id;
            while((t >= 'a' && t <= 'z') || (t >= 'A' && t <= 'Z') || (t == '_')||(t<='9'&&t>='0'))
            {
                *(q++)=t;
                t=getchar();
            }
            *q='\0';
            //此时变量名被放在了id数组中
            ungetc(t,stdin);
            //找找这个字符串有没有在我的符号表里
             p=lookup(id);
            if(p==-1)//没有这个值
            {
                p=insert(id);
            }
            yylval=p;//这里不像NUMBER直接存值，这里存的index
            return ID;
        }
        else if(t=='=')
        {
            return ASSIGN;
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