%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

void yyerror(char *);

char identifier[50][50];
int total_id = 0;
extern YYSTYPE yylval;
int lineNum = 0;

%}
digit  [0-9]
letter [a-zA-Z]
mulop	[*/%]
addop	[+-]


%%{
"if" {
		return IF;
	}
"else" {
		return ELSE;
		}
"while" {return WHILE;}

"for" { yyerror("Reserved Word for");}
"repeat" { yyerror("Reserved Word repeat");}
"until" { yyerror("Reserved Word until");}
"return" { yyerror("Reserved Word return");}
"main" { yyerror("Reserved Word main");}
{letter}({letter}|{digit}|"_")({letter}|{digit}|"_")({letter}|{digit}|"_")({letter}|{digit}|"_")({letter}|{digit}|"_")+ {

/*yyerror("Identifier greater than 5 characters");*/

}
	
{letter}({letter}|{digit}|"_")?({letter}|{digit}|"_")?({letter}|{digit}|"_")?({letter}|{digit}|"_")?		{
	    int i;
	    int flag=0; 
	    for (i = 0; i<total_id; i++) {
		if (strcmp(identifier[i], yytext)==0)
		 {
		     flag=1;
		     break;
		 }
	    }
	    //yylval.STRING = malloc(strlen(yytext)+1);
		strcpy(yylval.STRING, yytext);

		
			 
	    if(flag==0)	
	     {
			if(total_id==0) puts("");
			//printf("\r%s\n", yylval.string);
			//token_number = total_id;
			strcpy(identifier[total_id++],yylval.STRING);
		
	     } 
		return ID;
		
    }


{digit}+|({digit}+("."){digit}+)   	{ yylval.VALUE = atof(yytext); return NUM;} 
"=="|">="|"<="|">"|"<"|"!="	{

								strcpy(yylval.STRING, yytext);
								return RELOP;
							}
{addop}|("||") 				{

								strcpy(yylval.STRING, yytext);
								return ADDOP;
							}
{mulop}|("&&") 				{

								strncpy(yylval.STRING, yytext, strlen(yytext));
								return MULOP;
							}
"="					{return ASSIGN;}
";"					{return END;}
"!"					{return NOT;}
"["					{return SQRBO;}
"]"					{return SQRBC;}
"("					{return STRBO;}
")"					{return STRBC;}
"{"					{return CURBO;}
"}"					{return CURBC;}
"\n"				{lineNum++;}
[._]+				{yyerror("Invalid character");}
[ \t]+;
%%


