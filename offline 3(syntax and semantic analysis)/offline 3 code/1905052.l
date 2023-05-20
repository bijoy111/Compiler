%option noyywrap
%option lex-compat

%x STRING
%x COMMENT_ML
%x COMMENT_SL

%{

#include<bits/stdc++.h>
#include "symboltable.h"
#include "y.tab.h"
using namespace std;

//ai extern ar maddome nicher 3 line ar variable or file name gulo k .y theke nia asha hoise(akhane visible kra hoise)
extern int errcnt;
extern fstream logout;
extern fstream errorout;

int line_count=1;//atar drkar hoto jdi yylineno use na krtam. jeheto yylineno use krtese so apatoto atar kno drkar nai. but new line paile ata k 1 kre increase kra hsse



//nicher 4 ta variable k string,single comment, multiple comment a use krtese. jdio error_no tar kno drkar chilo nah ai offlien ar jonno.
int error_no=0;
int lin=0;
string strin;
string stt;




//ai error function ar o kno drkar nai apatoto
void error(int line, string symbol, string errorMessage) {
  //errorout<<"Error at line# "<<yylineno<<": "<<errorMessage<<" "<<yytext<<endl;
  //errcnt++;
}

%}

WS [ \t]+ 
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
		cout<<line_count;
		line_count++;
	}



"if"	{ 
			logout<<"Line# "<<yylineno<<": "<<"Token <IF> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"IF");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("IF : if");
			yylval.symbolInfo->set_terminal(1);
			return IF; 
		}
		
"else"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <ELSE> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"ELSE");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("ELSE : else");
			yylval.symbolInfo->set_terminal(1);
			return ELSE;
		}
"for"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <FOR> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"FOR");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("FOR : for");
			yylval.symbolInfo->set_terminal(1);
			return FOR;
		}
"while"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <WHILE> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"WHILE");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("WHILE : while");
			yylval.symbolInfo->set_terminal(1);
			return WHILE;
		}
"do"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <DO> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"DO");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("DO : do");
			yylval.symbolInfo->set_terminal(1);
			return DO;
		}
"break"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <BREAK> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"BREAK");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("BREAK : break");
			yylval.symbolInfo->set_terminal(1);
			return BREAK;
		}
"int"	{
	       	logout<<"Line# "<<yylineno<<": "<<"Token <INT> Lexeme "<<yytext<<" found"<<endl;
		   	yylval.symbolInfo=new SymbolInfo(yytext,"INT");
		   	yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("INT : int");
			yylval.symbolInfo->set_terminal(1);
			return INT;
		}
"char"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <CHAR> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"CHAR");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("CHAR : char");
			yylval.symbolInfo->set_terminal(1);
			return CHAR;
		}
"float"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <FLOAT> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"FLOAT");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("FLOAT : float");
			yylval.symbolInfo->set_terminal(1);
			return FLOAT;
		}
"double" {
			logout<<"Line# "<<yylineno<<": "<<"Token <DOUBLE> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"DOUBLE");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("DOUBLE : double");
			yylval.symbolInfo->set_terminal(1);
			return DOUBLE;
		}
"void"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <VOID> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"VOID");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("VOID : void");
			yylval.symbolInfo->set_terminal(1);
			return VOID;
		}
"return" {
			logout<<"Line# "<<yylineno<<": "<<"Token <RETURN> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"RETURN");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("RETURN : return");
			yylval.symbolInfo->set_terminal(1);
			return RETURN;
		}
"switch" {
			logout<<"Line# "<<yylineno<<": "<<"Token <SWITCH> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"SWITCH");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("SWITCH : switch");
			yylval.symbolInfo->set_terminal(1);
			return SWITCH;
		}
"case"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <CASE> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"CASE");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("CASE : case");
			yylval.symbolInfo->set_terminal(1);
			return CASE;
		}
"default" {
			logout<<"Line# "<<yylineno<<": "<<"Token <DEFAULT> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"DEFAULT");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("DEFAULT : default");
			yylval.symbolInfo->set_terminal(1);
			return DEFAULT;
		}
"continue" {
			logout<<"Line# "<<yylineno<<": "<<"Token <CONTINUE> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"CONTINUE");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("CONTINUE : continue");
			yylval.symbolInfo->set_terminal(1);
			return CONTINUE;
		}






{DIGIT}+ 	{ 
				logout<<"Line# "<<yylineno<<": "<<"Token <CONST_INT> Lexeme "<<yytext<<" found"<<endl;
				yylval.symbolInfo=new SymbolInfo(yytext,"CONST_INT");
				yylval.symbolInfo->set_startLine(yylineno);
		   		yylval.symbolInfo->set_endLine(yylineno);
		   		yylval.symbolInfo->set_productionRule("CONST_INT : "+string(yytext));
				yylval.symbolInfo->set_terminal(1);
				return CONST_INT;
				
			}
{FLOAT_LITERAL} {

				logout<<"Line# "<<yylineno<<": "<<"Token <CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl;
				yylval.symbolInfo=new SymbolInfo(yytext,"CONST_FLOAT");
				yylval.symbolInfo->set_startLine(yylineno);
		   		yylval.symbolInfo->set_endLine(yylineno);
		   		yylval.symbolInfo->set_productionRule("CONST_FLOAT : "+string(yytext));
				yylval.symbolInfo->set_terminal(1);
				return CONST_FLOAT;
				
			}

{CHAR_WRONG} {
	
	error(yylineno,yytext,"UNFINISHED_CONST_CHAR");
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
						
						logout<<"Line# "<<yylineno<<": "<<"Token <CONST_CHAR> Lexeme %c found\n",yylineno,sc;
						yylval.symbolInfo=new SymbolInfo(yytext,"CONST_CHAR");
						yylval.symbolInfo->set_startLine(yylineno);
		   				yylval.symbolInfo->set_endLine(yylineno);
		   				yylval.symbolInfo->set_productionRule("CONST_CHAR : "+string(yytext));
						yylval.symbolInfo->set_terminal(1);
						return CONST_CHAR;


						
				}
				else
				{
				
				logout<<"Line# "<<yylineno<<": "<<"Token <CONST_CHAR> Lexeme %c found\n",yylineno,yytext[1];
				yylval.symbolInfo=new SymbolInfo(yytext,"CONST_CHAR");
				yylval.symbolInfo->set_startLine(yylineno);
		   		yylval.symbolInfo->set_endLine(yylineno);
		   		//yylval.symbolInfo->set_productionRule("CONST_CHAR : "+string(yytext[1]));
				return CONST_CHAR;
				}



				
				
			}


"+"|"-"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <ADDOP> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"ADDOP");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("ADDOP : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return ADDOP;
		}

"*"|"/"|"%"	{
				logout<<"Line# "<<yylineno<<": "<<"Token <MULOP> Lexeme "<<yytext<<" found"<<endl;
				yylval.symbolInfo=new SymbolInfo(yytext,"MULOP");
				yylval.symbolInfo->set_startLine(yylineno);
		   		yylval.symbolInfo->set_endLine(yylineno);
		  		yylval.symbolInfo->set_productionRule("MULOP : "+string(yytext));
				yylval.symbolInfo->set_terminal(1);
				return MULOP;
		}
"++" {
				logout<<"Line# "<<yylineno<<": "<<"Token <INCOP> Lexeme "<<yytext<<" found"<<endl;
				yylval.symbolInfo=new SymbolInfo(yytext,"INCOP");
				yylval.symbolInfo->set_startLine(yylineno);
		   		yylval.symbolInfo->set_endLine(yylineno);
		   		yylval.symbolInfo->set_productionRule("INCOP : "+string(yytext));
				yylval.symbolInfo->set_terminal(1);
				return INCOP;
		}
"--" {
				logout<<"Line# "<<yylineno<<": "<<"Token <DECOP> Lexeme "<<yytext<<" found"<<endl;
				yylval.symbolInfo=new SymbolInfo(yytext,"DECOP");
				yylval.symbolInfo->set_startLine(yylineno);
		   		yylval.symbolInfo->set_endLine(yylineno);
		   		yylval.symbolInfo->set_productionRule("DECOP : "+string(yytext));
				yylval.symbolInfo->set_terminal(1);
				return DECOP;
		}
"<"|"<="|">"|">="|"=="|"!="	{
			logout<<"Line# "<<yylineno<<": "<<"Token <RELOP> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"RELOP");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("RELOP : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return RELOP;
		}
"="	{
			logout<<"Line# "<<yylineno<<": "<<"Token <ASSIGNOP> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"ASSIGNOP");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("ASSIGNOP : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return ASSIGNOP;
		}
"&&"|"||" {
			logout<<"Line# "<<yylineno<<": "<<"Token <LOGICOP> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"LOGICOP");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("LOGICOP : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return LOGICOP;
		}
"&"|"|"|"^"|"<<"|">>"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <BITOP> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"BITOP");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("BITOP : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return BITOP;
		}
"!" {
			logout<<"Line# "<<yylineno<<": "<<"Token <NOT> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"NOT");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("NOT : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return NOT;
		}
"("	{
			logout<<"Line# "<<yylineno<<": "<<"Token <LPAREN> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"LPAREN");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("LPAREN : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return LPAREN;
		}

")"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <RPAREN> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"RPAREN");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("RPAREN : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return RPAREN;
		}	
"{"	{	
			//table.Enter_Scope(++scope_table);
			logout<<"Line# "<<yylineno<<": "<<"Token <LCURL> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"LCURL");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("LCURL : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return LCURL;
		}	
"}"	{		
			//table.Print_All_Scope_Table(logout);
			//table.Exit_Scope();
			logout<<"Line# "<<yylineno<<": "<<"Token <RCURL> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"RCURL");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("RCURL : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return RCURL;
	}
"["	{
			logout<<"Line# "<<yylineno<<": "<<"Token <LTHIRD> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"LTHIRD");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("LSQUARE : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return LTHIRD;
		}	
"]"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <RTHIRD> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"RTHIRD");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("RSQUARE : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return RTHIRD;
		}
","	{
			logout<<"Line# "<<yylineno<<": "<<"Token <COMMA> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"COMMA");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("COMMA : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return COMMA;
		}
";"	{
			logout<<"Line# "<<yylineno<<": "<<"Token <SEMICOLON> Lexeme "<<yytext<<" found"<<endl;
			yylval.symbolInfo=new SymbolInfo(yytext,"SEMICOLON");
			yylval.symbolInfo->set_startLine(yylineno);
		   	yylval.symbolInfo->set_endLine(yylineno);
		   	yylval.symbolInfo->set_productionRule("SEMICOLON : "+string(yytext));
			yylval.symbolInfo->set_terminal(1);
			return SEMICOLON;
	}



{ID} {
		logout<<"Line# "<<yylineno<<": "<<"Token <ID> Lexeme "<<yytext<<" found"<<endl;
		yylval.symbolInfo=new SymbolInfo(yytext,"ID");
		yylval.symbolInfo->set_startLine(yylineno);
		yylval.symbolInfo->set_endLine(yylineno);
		yylval.symbolInfo->set_productionRule("ID : "+string(yytext));
		yylval.symbolInfo->set_terminal(1);
		return ID;
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
	error(yylineno,yytext,"UNFINISHED_STRING");
	error_no++;
	BEGIN(INITIAL);
}
<STRING><<EOF>> {
	stt+=yytext;
	char* stt1=&(stt[0]);
	char* strin1=&(strin[0]);
	error(yylineno,yytext,"UNFINISHED_STRING");
	
	error_no++;
	BEGIN(INITIAL);
}
<STRING>\" {
	stt+=yytext;
	char* stt1=&(stt[0]);
	char* strin1=&(strin[0]);
	if(lin==0)
		{
			logout<<"Line# "<<yylineno-lin<<": "<<"Token <SINGLE LINE STRING> Lexeme "<<stt1<<" found"<<endl;
		}
		else
		{
			logout<<"Line# "<<yylineno-lin<<": "<<"Token <MULTI LINE STRING> Lexeme "<<stt1<<" found"<<endl;
		}

	return STRING;
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
	logout<<"Line# "<<yylineno-lin<<": "<<"Token <MULTI LINE COMMENT> Lexeme "<<stt1<<" found"<<endl;
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
	error(yylineno-lin-1, yytext, "Unterminated Comment");
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
	logout<<"Line# "<<yylineno-lin<<": "<<"Token SINGLE LINE COMMENT> Lexeme "<<stt1<<" found"<<endl;
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
		error(yylineno-lin-1, yytext, "Unterminated Comment");
		error_no++;
		BEGIN(INITIAL);
}

{DIGIT}*(\.{DIGIT}+)(\.{DIGIT}*)+ {

		error(yylineno,yytext,"TOO_MANY_DECIMAL_POINTS");
}

{DIGIT}*(E){DIGIT}*(\.{DIGIT}*)+ {
		error(yylineno,yytext,"ILLFORMED_NUMBER");
}
[0-9][_A-Za-z0-9]+ {
		
		error(yylineno,yytext,"INVALID_ID_SUFFIX_NUM_PREFIX");
}


(\')(.)(.)+(\') {
		error(yylineno,yytext,"MULTICHAR_CONST_CHAR");
}

(\')(\') {
	error(yylineno,yytext,"EMPTY_CONST_CHAR");
}

 \'[^\';\n] {
		error(yylineno,yytext,"UNFINISHED_CONST_CHAR");
}

. 			{
		error(yylineno,yytext,"UNRECOGNIZED_CHAR");
}

<<EOF>> {
    return 0;
}


%%