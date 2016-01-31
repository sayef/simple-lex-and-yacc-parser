%{
#include<stdio.h>
#include<string.h>


extern FILE *yyin;
extern int lineNum;


int ErrorRecovered = 0;
char message[100];

char idflag[50][50];
int nModId  = 0;

struct QUAD{
	char operation[10];
	char arg1[20];
	char arg2[20];
	char result[10];
}quads[100];

int Q = 0, T = 0;
int L = 0;
int LABEL_STACK[100];
int LABEL_STACK_TOP=0;

void LABEL_STACK_push(int l){

	LABEL_STACK[LABEL_STACK_TOP++] = l;
}


char STMT_STACK[100][100];
int STACK_TOP = 0;



void STMT_STACK_push(char str[100]){

	strcpy(STMT_STACK[STACK_TOP++], str);
}

struct ST{
	char symbol[100];
	float value;
}SYMBOL_TABLE[100];
int total_symbol=0;

float GET_SYMBOL_VALUE( char symbol[100]){
	int i;
	for(i=0;i<total_symbol;i++){
		if(strcmp(symbol,SYMBOL_TABLE[i].symbol)==0){			
			return SYMBOL_TABLE[i].value;
		}
	}
	strcpy(SYMBOL_TABLE[total_symbol].symbol, symbol);
	SYMBOL_TABLE[total_symbol].value = 0;
	total_symbol++;
    return 0;
}
void SET_SYMBOL_VALUE(char symbol[100], float value){

	int i;
	for(i=0;i<total_symbol;i++){
		if(strcmp(symbol,SYMBOL_TABLE[i].symbol)==0){
			SYMBOL_TABLE[i].value = value;
			return;
		}
	}
	
 }

float  CALCULATE(float x, float y, char operation[5] ){


	if(strcmp(operation,"*")==0) return x*y;
	if(strcmp(operation,"/")==0) return x/y;
	if(strcmp(operation,"%")==0) return ((int)x) % ((int)y);
	if(strcmp(operation,"&&")==0) return x&&y;
	
	
	if(strcmp(operation,"+")==0) return x+y;
	if(strcmp(operation,"-")==0) return x-y;
	if(strcmp(operation,"||")==0) return x||y;

	if(strcmp(operation,"==")==0) return  x ==y;		
	if(strcmp(operation,"!=")==0) return x != y;		
	if(strcmp(operation,">=")==0) return x >= y;		
	if(strcmp(operation,"<=")==0) return x <= y;		
	if(strcmp(operation,">")==0)  return x > y;		
	if(strcmp(operation,"<")==0)  return x < y;	
	
}



int IF_NO=1;


%}


%union{
  float      	VALUE;
  char        	STRING[100];
}

%start Start
%token ID NUM RELOP ADDOP MULOP ASSIGN NOT SQRBO SQRBC STRBO STRBC END NEWLINE CURBO CURBC IF ELSE WHILE

%type <VALUE> NUM 
%type <STRING> ID RELOP ADDOP MULOP ASSIGN Factor Term Simple_expression Expression Variable


%% 				
		
Start			: Stmt_list
				{
					int i;
					for(i=0;i<STACK_TOP;i++){
						printf("\r%s\n", STMT_STACK[i]);
					}
					
				};			
				
Stmt_list 		: Stmt 
				{							
						strcpy(message, "Missing expression!");
				}
				
				| Stmt_list  Stmt 
				 
				{
						strcpy(message,"It's not the last line of the file!");
				};

Stmt	  		: Variable ASSIGN Expression END 
				{
						char str[100], result[100], num[100]; 
							
						strcpy(num, $3);
						strcpy(result, $1);				
						
						strcpy(quads[Q].operation, $2);
						strcpy(quads[Q].arg1, "");
						strcpy(quads[Q].arg2, num);
						strcpy(quads[Q].result, result);
						Q++;
						
						
						float Num = GET_SYMBOL_VALUE(num);
										
						
						SET_SYMBOL_VALUE(result, Num);					
						
											
						
						sprintf(str, "%s = %s", result, num);
						STMT_STACK_push(str);
		
						
						
						strcpy(message,"Variable or expression missing. Cannot assign anything!");
				}
 
				| IF STRBO Expression STRBC  
				{
				
					char str[100], num[100], label[100]; 
					IF_NO = 1;
										
					strcpy(label, "label"); sprintf(str, "%d", ++L); strcat(label,str);
							
					strcpy(num, $3);
					
					sprintf(str, "if !(%s) goto %s", num,label);
					STMT_STACK_push(str);
							
					
							
				}
				
				CURBO Stmt_list CURBC
				{
		
					char str[100],label[100]; 
					
					strcpy(label, "label"); sprintf(str, "%d", ++L); strcat(label,str);
					sprintf(str, "goto %s", label);					
					STMT_STACK_push(str);
					
					strcpy(label, "label"); sprintf(str, "%d", L-IF_NO); strcat(label,str);
					sprintf(str, "%s:", label);					
					STMT_STACK_push(str);
					
			
				} 
				
				ELSE CURBO Stmt_list CURBC 
				{
					char str[100],label[100];
					strcpy(label, "label"); sprintf(str, "%d", L); strcat(label,str);
					sprintf(str, "%s:", label);					
					STMT_STACK_push(str);
					IF_NO+=2;					
				
				}
				 
				| WHILE 
				{
						char str[100],label[100]; 
						IF_NO = 1;					
						
						strcpy(label, "label"); sprintf(str, "%d", ++L); strcat(label,str);
																			
						sprintf(str, "%s:", label);
						STMT_STACK_push(str);
				}
				STRBO Expression STRBC 
				{
						char str[100], num[100], label[100]; 
						
						
						strcpy(label, "label"); sprintf(str, "%d", ++L); strcat(label,str);
								
						strcpy(num, $4);
						
						sprintf(str, "if %s is false goto %s", num,label);
						STMT_STACK_push(str);
				}
				CURBO Stmt_list CURBC 
				{
						char str[100],label[100];
						strcpy(label, "label"); sprintf(str, "%d", L-IF_NO); strcat(label,str);
						sprintf(str, "goto %s", label);					
						STMT_STACK_push(str);
						
						strcpy(label, "label"); sprintf(str, "%d", L-IF_NO+1); strcat(label,str);
						sprintf(str, "%s:", label);					
						STMT_STACK_push(str);
						IF_NO+=2;		
						
				}
				;

Variable  		: ID 
				{					
						strcpy($$,$1);	
						
						GET_SYMBOL_VALUE($1);
						
										
						strcpy(message,"Expecting something else!");
				}
				;

Expression		: Simple_expression 
				{
													
																	
						strcpy($$,  $1);			
										
						
						strcpy(message,"Missing expression!");
				}
				| Simple_expression RELOP Simple_expression  
				{
					
						char str[100], result[100], num1[100], num2[100]; 
					
											
						strcpy(num1, $1);
						strcpy(num2, $3);
	
						
						sprintf(str, "%s %s %s", num1, $2, num2);

						strcpy($$,  str);
						
						float Num1 = GET_SYMBOL_VALUE(num1);
						float Num2 = GET_SYMBOL_VALUE(num2);
						
						GET_SYMBOL_VALUE(str);
						SET_SYMBOL_VALUE(str, CALCULATE(Num1, Num2, $2));
						
	
						
						
						strcpy(message,"Conditional operation cannot be done");
				}
				;

Simple_expression: Term 
				{
						strcpy($$, $1);
						
						
				}
				| Simple_expression ADDOP Term 
				{
						char str[100], result[100], num1[100], num2[100]; 
						strcpy(result, "T"); sprintf(str, "%d", ++T); strcat(result,str); 
						
											
						strcpy(num1, $1);
						strcpy(num2, $3);
						
						
						strcpy(quads[Q].operation, $2);
						strcpy(quads[Q].arg1, num1);
						strcpy(quads[Q].arg2, num2);
						strcpy(quads[Q].result, result);
						Q++;
						
						float Num1 = GET_SYMBOL_VALUE(num1);
						float Num2 = GET_SYMBOL_VALUE(num2);
						float Result = CALCULATE(Num1, Num2, $2);
					
						//printf("%s %f...\n",result, Result);
						
						GET_SYMBOL_VALUE(result);
						SET_SYMBOL_VALUE(result, Result);
						
						sprintf(str, "%s = %s %s %s", result, num1, $2, num2);
						STMT_STACK_push(str);
						

						strcpy($$, result);
											
						strcpy(message,"Additive operation cannot be done");
				}
				;

Term			: Factor 
				{

						strcpy($$, $1);
						
						
				}
				| Term MULOP Factor 
				{
				
						char str[100], result[100], num1[100], num2[100]; 
						strcpy(result, "T"); sprintf(str, "%d", ++T); strcat(result,str); 
						
											
						strcpy(num1, $1);
						strcpy(num2, $3);
						
						
						strcpy(quads[Q].operation, $2);
						strcpy(quads[Q].arg1, num1);
						strcpy(quads[Q].arg2, num2);
						strcpy(quads[Q].result, result);
						Q++;
						
						
						float Num1 = GET_SYMBOL_VALUE(num1);
						float Num2 = GET_SYMBOL_VALUE(num2);
						float Result = CALCULATE(Num1, Num2, $2);
						
						SET_SYMBOL_VALUE(result, Result);
						
						sprintf(str, "%s = %s %s %s", result, num1, $2, num2);
						STMT_STACK_push(str);

						strcpy($$, result);
						
												
						strcpy(message,"Multiplicative operation cannot be done!");
				}
				; 

Factor			: ID 
				{

						strcpy($$,$1);
						
						GET_SYMBOL_VALUE($1);
						
												
						strcpy(message,"Expecting something else!");
				}
				
				| NUM 
				
				{
						char str[100], result[100], num[100]; 
						strcpy(result, "T"); sprintf(str, "%d", ++T); strcat(result,str); 
						
											
						sprintf(num, "%f", $1);
						
						
						strcpy(quads[Q].operation, "");
						strcpy(quads[Q].arg1, "");
						strcpy(quads[Q].arg2, num);
						strcpy(quads[Q].result, result);
						Q++;
						
						GET_SYMBOL_VALUE(result);
						SET_SYMBOL_VALUE(result, $1);
						
						
						
						sprintf(str, "%s = %s", result, num);
						STMT_STACK_push(str);
						
						strcpy($$,result);				
													
						
						strcpy(message,"Unrecognized number format!");
				
				}
				| STRBO Expression STRBC 
				{
						strcpy(message,"'(' or ')' missing OR expression not found!");
				}
				| NOT Factor 
				{
						char str[100], result[100], num[100]; 
						strcpy(result, "T"); sprintf(str, "%d", ++T); strcat(result,str); 
						
		
						sprintf(num, "%s", $2);
						
						
						strcpy(quads[Q].operation, "!");
						strcpy(quads[Q].arg1, "");
						strcpy(quads[Q].arg2, num);
						strcpy(quads[Q].result, result);
						Q++;
						
						
						sprintf(str, "%s = !%s", result, num);
						STMT_STACK_push(str);

						strcpy($$,result);
						
											
						strcpy(message,"Unrecognized number/ID format!");
				
				}
				; 				
%%





int yywrap()
{
	
        return 1;
} 
  
int main()
{
    yyin=fopen("input.txt","r");
    yyparse();
    fclose(yyin);
    if(ErrorRecovered==0) printf("Success!\n");
    
    printf("\n------Symbol Table & Final Value------\n\n");
    int i;    
    for(i=0;i<total_symbol;i++){
		printf("%s = %f\n", SYMBOL_TABLE[i].symbol, SYMBOL_TABLE[i].value);
	}
    
    return 0;
}


int yyerror(char str[100])
{
				if(ErrorRecovered==0){
					{
					
					
						printf("Error Found @ line #%d: ", lineNum+1);
						if(strcmp(str,"Invalid character")==0 || strcmp(str,"Identifier greater than 5 characters")==0)						
							printf("%s!", str);
						else if(strlen(message))
							printf("%s\n",message);
						else printf("%s\n", str);
					}
					printf("\n");
					ErrorRecovered = 1;

				}
		        
}
 
 
