%option noyywrap
%option lex-compat

%x STRING
%x COMMENT_ML
%x COMMENT_SL

%{

#include<bits/stdc++.h>
#include "symboltable.h"
using namespace std;

int line_count=1;
int error_no=0;
int lin=0;
string strin;
string stt;

FILE *logout;
FILE *tokenout;

SymbolTable st(10);
int scope_table=1;

%}

WS [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
FLOAT_LITERAL {DIGIT}*(\.{DIGIT}+)?(E[+-]?{DIGIT}+)?
CHAR_WRONG \'(\\)\'
CHAR_LITERAL \'(.)\'|\'(\\[ntafrbv0'"])\'
ID [_A-Za-z][_A-Za-z0-9]*

%%
{WS}
{NEWLINE} 
	{
		line_count++;
	}



"if"	{
			fprintf(tokenout,"<IF, if>\n");
			fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",yylineno,yytext);
		}
		
"else"	{
			fprintf(tokenout,"<ELSE, else>\n");
			fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",yylineno,yytext);
		}
"for"	{
			fprintf(tokenout,"<FOR, for>\n");
			fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",yylineno,yytext);
		}
"while"	{
			fprintf(tokenout,"<WHILE, while>\n");
			fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",yylineno,yytext);
		}
"do"	{
			fprintf(tokenout,"<DO, do>\n");
			fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",yylineno,yytext);
		}
"break"	{
			fprintf(tokenout,"<BREAK, break>\n");
			fprintf(logout,"Line# %d: Token <BREAK> Lexeme %s found\n",yylineno,yytext);
		}
"int"	{
			fprintf(tokenout,"<INT, int>\n");
			fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",yylineno,yytext);
		}
"char"	{
			fprintf(tokenout,"<CHAR, char>\n");
			fprintf(logout,"Line# %d: Token <CHAR> Lexeme %s found\n",yylineno,yytext);
		}
"float"	{
			fprintf(tokenout,"<FLOAT, float>\n");
			fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",yylineno,yytext);
		}
"double" {
			fprintf(tokenout,"<DOUBLE, double>\n");
			fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme %s found\n",yylineno,yytext);
		}
"void"	{
			fprintf(tokenout,"<VOID, void>\n");
			fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",yylineno,yytext);
		}
"return" {
			fprintf(tokenout,"<RETURN, return>\n");
			fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",yylineno,yytext);
		}
"switch" {
			fprintf(tokenout,"<SWITCH, switch>\n");
			fprintf(logout,"Line# %d: Token <SWITCH> Lexeme %s found\n",yylineno,yytext);
		}
"case"	{
			fprintf(tokenout,"<CASE, case>\n");
			fprintf(logout,"Line# %d: Token <CASE> Lexeme %s found\n",yylineno,yytext);
		}
"default" {
			fprintf(tokenout,"<DEFAULT, default>\n");
			fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme %s found\n",yylineno,yytext);
		}
"continue" {
			fprintf(tokenout,"<CONTINUE, continue>\n");
			fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme %s found\n",yylineno,yytext);
		}

	
{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT, %s>\n",yytext);
				fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",yylineno,yytext);
				
			}
{FLOAT_LITERAL} {
				fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
				fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",yylineno,yytext);
				
			}

{CHAR_WRONG} {
	fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n",yylineno,yytext);
		error_no++;
}
{CHAR_LITERAL}  {
				if(yytext[1]=='\\')
				{

						char sc;
						
						if(yytext[2]=='n')
						{
							sc='\n';
						}
						else if(yytext[2]=='t')
						{
							sc='\t';
						}
						else if(yytext[2]=='a')
						{
							sc='\a';
						}
						else if(yytext[2]=='f')
						{
							sc='\f';
						}
						else if(yytext[2]=='r')
						{
							sc='\r';
						}
						else if(yytext[2]=='b')
						{
							sc='\b';
						}
						else if(yytext[2]=='v')
						{
							sc='\v';
						}
						else if(yytext[2]=='0')
						{
							sc='\0';
						}
						fprintf(tokenout,"<CONST_CHAR,%c>\n",sc);
						fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n",yylineno,sc);


						
				}
				else
				{
				fprintf(tokenout,"<CONST_CHAR, %c>\n",yytext[1]);
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n",yylineno,yytext[1]);
				}
				
				
			}


"+"|"-"	{
			fprintf(tokenout,"<ADDOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",yylineno,yytext);
		}

"*"|"/"|"%"	{
			fprintf(tokenout,"<MULOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",yylineno,yytext);
		}
"++"|"--" {
			fprintf(tokenout,"<INCOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",yylineno,yytext);
		}
"<"|"<="|">"|">="|"=="|"!="	{
			fprintf(tokenout,"<RELOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",yylineno,yytext);
		}
"="	{
			fprintf(tokenout,"<ASSIGNOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",yylineno,yytext);
		}
"&&"|"||" {
			fprintf(tokenout,"<LOGICOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",yylineno,yytext);
		}
"&"|"|"|"^"|"<<"|">>"	{
			fprintf(tokenout,"<BITOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",yylineno,yytext);
		}
"!" {
			fprintf(tokenout,"<NOT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",yylineno,yytext);
		}
"("	{
			fprintf(tokenout,"<LPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",yylineno,yytext);
		}

")"	{
			fprintf(tokenout,"<RPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",yylineno,yytext);
		}	
"{"	{
			fprintf(tokenout,"<LCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",yylineno,yytext);
			scope_table++;
            st.Enter_Scope(scope_table);
		}	
"}"	{
			fprintf(tokenout,"<RCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",yylineno,yytext);
			st.Exit_Scope();
	}
"["	{
			fprintf(tokenout,"<LSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",yylineno,yytext);
		}	
"]"	{
			fprintf(tokenout,"<RSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",yylineno,yytext);
		}
","	{
			fprintf(tokenout,"<COMMA, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",yylineno,yytext);
		}
";"	{
			fprintf(tokenout,"<SEMICOLON, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",yylineno,yytext);
	}



{ID} {
		fprintf(tokenout,"<ID, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",yylineno,yytext);
		int tem=st.Insert(yytext,"ID");
		if(tem==0)
		{
			fprintf(logout,"\t%s already exisits in the current ScopeTable\n",yytext);
		}
		else
		{
		st.Print_All_Scope_Table(logout);
		}
	}



\" {
	lin=0;
	strin="";
	stt=yytext;
	BEGIN(STRING);
}
<STRING>(\\\")(.)*(\\\") {
	string strr=yytext;
	for(int i=0;i<strr.length();i++)
	{
		stt+=strr[i];
	}
	for(int i=1;i<strr.length()-2;i++)
	{
		strin+=strr[i];
	}
	strin+='"';
}
<STRING>\\{NEWLINE} {
	stt+=yytext;
	lin++;
}
<STRING>{NEWLINE} {
	
	stt+=yytext;
	char* stt1=&(stt[0]);
	char* strin1=&(strin[0]);
	fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",yylineno-lin-1,stt1);
	
	error_no++;
	BEGIN(INITIAL);
}
<STRING><<EOF>> {
	stt+=yytext;
	char* stt1=&(stt[0]);
	char* strin1=&(strin[0]);
	fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",yylineno-lin-1,stt1);
	
	error_no++;
	BEGIN(INITIAL);
}
<STRING>\" {
	stt+=yytext;
	char* stt1=&(stt[0]);
	char* strin1=&(strin[0]);
	if(lin==0)
		{
			
			fprintf(tokenout,"<SINGLE LINE STRING, %s>\n",strin1);
			fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n",yylineno-lin,stt1);
		}
		else
		{
			
			fprintf(tokenout,"<MULTI LINE STRING, %s>\n",strin1);
			fprintf(logout,"Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n",yylineno-lin,stt1);
		}
		BEGIN(INITIAL);
}
<STRING>\\n {
	stt+=yytext;
	strin+="\n";
}
<STRING>\\t {
	stt+=yytext;
	strin+="\t";
}
<STRING>\\a {
	stt+=yytext;
	strin+="\a";
}
<STRING>\\f {
	stt+=yytext;
	strin+="\f";
}
<STRING>\\r {
	stt+=yytext;
	strin+="\r";
}
<STRING>\\b {
	stt+=yytext;
	strin+="\b";
}
<STRING>\\v {
	stt+=yytext;
	strin+="\v";
}
<STRING>\\0 {
	stt+=yytext;
	strin+="\0";
}
<STRING>. {
	stt+=yytext;
	strin+=yytext[0];
}



"/*" {
	stt=yytext;
	lin=0;
	BEGIN(COMMENT_ML);
}
<COMMENT_ML>"*/" {
	stt+=yytext;
	char* stt1=&(stt[0]);
	fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n",yylineno-lin,stt1);
	BEGIN(INITIAL);
} 
<COMMENT_ML>[*] {
	stt+=yytext;
	
}
<COMMENT_ML>[^*\n]+ {
	stt+=yytext;
	
}
<COMMENT_ML>{NEWLINE} {
	stt+=yytext;
	lin++;
}
<COMMENT_ML><<EOF>> {
	char* stt1=&(stt[0]);
	fprintf(logout,"Error at line# %d: UNFINISHED_COMMENT %s\n",yylineno-lin-1,stt1);
		
	error_no++;
	BEGIN(INITIAL);
		
}
"//" {
	stt=yytext;
	lin=0;
	BEGIN(COMMENT_SL);
}
<COMMENT_SL>[\n] {
	lin++;
	char* stt1=&(stt[0]);
	fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n",yylineno-lin,stt1);
	BEGIN(INITIAL);
}
<COMMENT_SL>\\[\n] {
		lin++;
		stt+=yytext;
}
<COMMENT_SL>. {
		stt+=yytext;
}
<COMMENT_SL><<EOF>> {
		char* stt1=&(stt[0]);
		fprintf(logout,"Error at line# %d: UNFINISHED_COMMENT %s\n",yylineno-lin-1,stt1);
		
		error_no++;
		BEGIN(INITIAL);
}

{DIGIT}*(\.{DIGIT}+)(\.{DIGIT}*)+ {
		fprintf(logout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n",yylineno,yytext);
		error_no++;
}

{DIGIT}*(E){DIGIT}*(\.{DIGIT}*)+ {
		fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",yylineno,yytext);
		error_no++;
}
[0-9][_A-Za-z0-9]+ {
		fprintf(logout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n",yylineno,yytext);
		error_no++;
}


(\')(.)(.)+(\') {
		fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR %s\n",yylineno,yytext);
		error_no++;
}

(\')(\') {
	fprintf(logout,"Error at line# %d: EMPTY_CONST_CHAR %s\n",yylineno,yytext);
		error_no++;
}

 \'[^\';\n] {
		fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n",yylineno,yytext);
		error_no++;
}

. 			{
		fprintf(logout,"Error at line# %d: UNRECOGNIZED_CHAR %s\n",yylineno,yytext);
		error_no++;
}




%%

int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	st.Print_Current_Scope_Table(logout);
	fprintf(logout,"Total lines: %d\n",yylineno);
	fprintf(logout,"Total errors: %d\n",error_no);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
