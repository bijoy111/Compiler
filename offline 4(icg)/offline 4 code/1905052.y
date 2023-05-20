%{
#include<bits/stdc++.h>
#include "symboltable.h"
using namespace std;

int yylex(void);//it performs lexical analysis on the input. ata muloto .l theke token gulo generate kre ai .y file a nia ashe

extern FILE *yyin;//ata yyin name ar akta global variable k declare krtese jeta muloto input file k point kre
extern int yylineno;//ata c file ar line number gulo janar jonno use kra hoise

SymbolTable table(11);//akta SymbolTable class ar object nea hoise jeta insert,remove,print etc krar jonno use kra hbe
int scope_table=1;//new scope table ar enter krar time a scope table number unique rakhar jonno use kra hoise

int errcnt=0;//error gulo count krar jonno use kra hoise. ata k .l a extern kre global variable for both of these file, banano hoise


int dec_var_cnt=0;//ata use krtese icg ar jonno. ata diye declaration list a total koita variable ase seta count krtese. like int a,b,c; atar jonno dec_var_cnt ar value hbe 3.
fstream errorout;
fstream logout;
fstream parseout;


//fstream dataSegmentout;
fstream codeSegmentout;
fstream asmCodeout;
fstream codeAsmOut;



int labelCnt=0; //it is used for the label count in assembly
string While_label1;
string While_label2;
string FOR_START;
string FOR_END;
string FOR_CON;
string FOR_STMT;
string FOR_LOOP;
int global_var=1;
int funcParam;
int main_func=1;
string rmvSpaces(string s)
{
	int j = 0;
	for(int i=0;i<s.length();i++)
	{
		if (s[i] != ' ')
		{
        	s[j] = s[i];
			j++;
		}
	}
    s[j] = '\0';
    return s;
}


void yyerror(char *s)
{
	//apatoto ata use kra hoi nai
}

int ii=0;//ai variable ta k debug ar jonno use kra hoise. segmentation fault and infinite loop a chole jassilo parse tree. so ota debug krar jonno use kra hoise

void DFS(SymbolInfo* VERTEX, string SPACE) 
{
	if(VERTEX==NULL)
	{
		return;
	}
	int trm=VERTEX->get_terminal();//parse tree ar vertex , leaf kina seta check kra hsse
	if(trm==1)
	{
		parseout << SPACE << VERTEX->get_productionRule()<<"	"<<"<Line: "<<VERTEX->get_startLine()<<">"<<endl;
	}
	else
	{
	parseout << SPACE << VERTEX->get_productionRule()<<" 	"<<"<Line: "<<VERTEX->get_startLine()<<"-"<<VERTEX->get_endLine()<<">"<<endl;
	}
	vector<SymbolInfo*> tmp=VERTEX->get_childList();
	for(int i = 0; i < tmp.size(); i++)
	{
		DFS(tmp[i], SPACE + " ");
	}
	cout<<ii++<<endl;
}


void genFunctionStartAssemblyCode(string name)
{
	funcParam=0;
    codeSegmentout << "\t" << name << " PROC\n";
    if (name == "main")
    {
        codeSegmentout << "\t\tMOV AX, @DATA\n\t\tmov DS, AX\n";
    }
	else
	{
		main_func=0;
		codeSegmentout<<"\t\tPUSH BP"<<endl;
	}
	codeSegmentout<<"\t\tMOV BP, SP\n";
}
void genFunctionEndAssemblyCode(string name)
{
	funcParam=0;
    if (name == "main")
    {
        codeSegmentout << "\t\tMOV AH, 4CH" << endl;
        codeSegmentout << "\t\tINT 21H" << endl;
		codeSegmentout << "\tmain ENDP" << endl;
    }
	else if(name!="main")
	{
		main_func=1;
		codeSegmentout<<"\t\tPOP BP\n";
        codeSegmentout << "\t\tRET\n";
    }
    codeSegmentout << "\t" << name << " ENDP\n\n";
}


void genVariableAssemblyCode(SymbolInfo* tmp)
{
	
	if(global_var==1)
	{

		codeAsmOut << "\t" << tmp->get_name();
        codeAsmOut << " DW " << tmp->get_arraySize();
		if(tmp->get_arraySize()>0)
		{
			codeAsmOut << " DUP(" << 0 << ")"<<endl;
		}
		else
		{
			codeAsmOut << "0"<<endl;
		}	
	}
	else
	{
		if(tmp->get_arraySize()>0)
		{
			codeSegmentout << "\t\tSUB SP, " << (tmp->get_arraySize() * 2) << "\t";			


			//dec_var_cnt+=tmp->get_arraySize();
			//table.set_varCount(tmp->get_arraySize());		
		}
		else
		{
			codeSegmentout << "\t\tSUB SP, 2\t\n";
			if(funcParam!=0)
			{
				table.set_varCount(funcParam);
				funcParam=0;
			}
			table.set_varCount(1);
		}	
	}	
}
void genArrayAssemblyCode(SymbolInfo* tmp,int arrSiz)
{
		codeSegmentout << "\t\tSUB SP, " << (arrSiz * 2) << "\t"<<endl;				
}





%}

%union
{
	SymbolInfo* symbolInfo; 
}

%token <symbolInfo> IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP RELOP LOGICOP INCOP DECOP ASSIGNOP NOT BITOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON LSQUARE RSQUARE CONST_INT CONST_FLOAT CONST_CHAR ID NEWLINE PLUS MINUS ASTERISK NUMBER SLASH STRING

%type <symbolInfo> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments if_condition


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE 

%%
start : program {
	$$=new SymbolInfo($1->get_name(),"start");
	logout<<"start : program "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->set_startLine($1->get_startLine());
		$$->set_endLine(yylineno);
		$$->set_productionRule("start : program");
	}
	DFS($$, "");
};
program : program unit{
	$$=new SymbolInfo($1->get_name()+" "+$2->get_name(),"program");
	logout<<"program : program unit "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->make_child($2);
		$$->set_startLine(min($1->get_startLine(),$2->get_startLine()));
		$$->set_endLine(yylineno);
		$$->set_productionRule("program : program unit");
	}
}
| unit{
	$$=new SymbolInfo($1->get_name(),"program");
	logout<<"program : unit "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->set_startLine($1->get_startLine());
		$$->set_endLine(yylineno);
		$$->set_productionRule("program : unit");
	}
}
;
unit : var_declaration{
	$$=new SymbolInfo($1->get_name(),"unit");
	logout<<"unit : var_declaration  "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->set_startLine($1->get_startLine());
		$$->set_endLine(yylineno);
		$$->set_productionRule("unit : var_declaration");
	}
}
| func_declaration{
	$$=new SymbolInfo($1->get_name(),"unit");
	logout<<"unit : func_declaration "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->set_startLine($1->get_startLine());
		$$->set_endLine(yylineno);
		$$->set_productionRule("unit : func_declaration");
	}
}
| func_definition{
	$$=new SymbolInfo($1->get_name(),"unit");
	logout<<"unit : func_definition  "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->set_startLine($1->get_startLine());
		$$->set_endLine(yylineno);
		$$->set_productionRule("unit : func_definition");
	}
}
;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
{
	SymbolInfo* tmp1=table.Insert($2->get_name(),"ID");//try to insert the function name in the symbol table. it will return null if it is already existed in the symbol table . otherwise it will return the SymbolInfo* type data
	
	string var_type="func_declaration";
	if(tmp1==NULL)
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Multiple declaration of "<<$2->get_name()<<endl;
		var_type="error";
	}
	else
	{
		tmp1->set_dataType("Function");
		tmp1->set_funRetType($1->get_name());
		vector<string> lis;
		stringstream s($4->get_name());
		string tm;
		while(getline(s,tm,','))
		{
			lis.push_back(tm);
		}
		tmp1->set_parList(lis);
	}
	$$=new SymbolInfo($1->get_name()+" "+$2->get_name()+"("+$4->get_name()+");",var_type);
	logout<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->make_child($2);
		$$->make_child($3);
		$$->make_child($4);
		$$->make_child($5);
		$$->make_child($6);
		int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),min($4->get_startLine(),min($5->get_startLine(),$6->get_startLine())))));
		$$->set_startLine(lin);
		$$->set_endLine(yylineno);
		$$->set_productionRule("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
	}
}
| type_specifier ID LPAREN RPAREN SEMICOLON{
	
	SymbolInfo* tmp1=table.Insert($2->get_name(),"ID");
	string var_type="func_declaration";
	if(tmp1==NULL)
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Multiple declaration of "<<$2->get_name()<<endl;
		var_type="error";
	}
	else
	{
		tmp1->set_dataType("Function");
		tmp1->set_funRetType($1->get_name());
	}
	$$=new SymbolInfo($1->get_name()+" "+$2->get_name()+"("+");",var_type);
	logout<<"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->make_child($2);
		$$->make_child($3);
		$$->make_child($4);
		$$->make_child($5);
		int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),min($4->get_startLine(),$5->get_startLine()))));
		$$->set_startLine($1->get_startLine());
		$$->set_endLine(yylineno);
		$$->set_productionRule("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
	}
}
;

func_definition : type_specifier ID LPAREN parameter_list RPAREN
{
	global_var=0;
	genFunctionStartAssemblyCode($2->get_name());


	SymbolInfo* tmp1=table.Look_Up($2->get_name());
	if(tmp1==NULL)
	{
		//table.Print_All_Scope_Table(errorout);
		tmp1= table.Insert($2->get_name(),"ID");
		//table.Print_All_Scope_Table(errorout);
		if(tmp1!=NULL){
		tmp1->set_dataType("Function");
		tmp1->set_funRetType($1->get_name());
		tmp1->set_funDef(1);
		vector<string> lis;
		stringstream s($4->get_name());
		string tm;
		while(getline(s,tm,','))
		{
			lis.push_back(tm);
		}
		tmp1->set_parList(lis);
		//table.Print_All_Scope_Table(errorout);
		table.Enter_Scope(++scope_table);
		//table.Print_All_Scope_Table(errorout);
		for(int i=0;i<lis.size();i++)
		{
			vector<string> var;
			stringstream s(lis[i]);
			string tmm;
			while(getline(s,tmm,' '))
			{
				var.push_back(tmm);
			}
			int dis=0;
			if(var.size()==2)
			{

				string var_name=var[1];
				string var_type=var[0];
				
				int isArray;
				regex tmp6("[_A-Za-z][_A-Za-z0-9]*\[[0-9]+\]");
				if(regex_match(var_name, tmp6)) 
				{
					isArray=1;
				}
				else
				{
					isArray=0;
				} 
				regex regexp("[0-9]+");
				smatch mat;
				regex_search(var_name, mat, regexp);
				string size = "";
				for(auto tm : mat) 
				{
					size += tm;
				}



					SymbolInfo* tmmm=table.Insert(var_name,var_type);
					if(tmmm==NULL)
					{
						errcnt++;
						errorout<<"Line# "<<yylineno<<": "<<"Redefinition of parameter "<<"'"<<var_name<<"'"<<endl;
					}
					if(isArray==1&&tmmm!=NULL)
                	{
						
						tmmm->set_arraySize(stoi(size));
						tmmm->set_dataType(var_type);
						
						//code for icg
						funcParam++;
						tmmm->set_varAsmname("W. [BP+" + to_string(2*funcParam) + "]");
                	}
                	else
                	{
						if(tmmm!=NULL)
						{
						tmmm->set_dataType(var_type);
						//code for icg
						funcParam++;
						//tmmm->set_varAsmname("W. [BP+" + to_string(2*funcParam) + "]");



						
						codeSegmentout<<"\t\tPUSH W. [BP+"<<2*(lis.size()+funcParam)<<"]"<<endl;
						tmmm->set_varAsmname("W. [BP-" + to_string(2*funcParam) + "]");
							

						
						}
               	 	}
					

				
				
			}
			else
			{
				if(dis==0)
				{
					dis=1;
					errcnt++;
					//errorout<<"Line# "<<yylineno<<": "<<(i+1) << "th parameter's name not given in function definition of " <<  $2->get_name()<<endl;
					errorout<<"Line# "<<yylineno<<": "<<"Syntax error at parameter list of function definition"<<endl;
				}
			}
		}
		//table.Print_All_Scope_Table(errorout);
		}
	}
	else
	{
		if(tmp1->get_dataType()=="Function")
		{
			if(tmp1->get_funDef()==1)
			{
				errcnt++;
				errorout<<"Line# "<<yylineno<<": "<<"Redefinition of function "<<"'"<<$2->get_name()<<"'"<<endl;
			}
			else
			{
				vector<string>par_list1=tmp1->get_parList();//declared function ar parameter gulo
				int len1=par_list1.size();

				vector<string>par_list2;//defined function ar parameter gulo
				stringstream s($4->get_name());
				string tm;
				while(getline(s,tm,','))
				{
					par_list2.push_back(tm);
				}
				int len2=par_list2.size();
				if(len1!=len2)
				{
					errcnt++;
					errorout<<"Line# "<<yylineno<<": "<<"Conflicting types for "<<"'"<<$2->get_name()<<"'"<<endl;
				}
				if(tmp1->get_funRetType()!=$1->get_name())
				{
					errcnt++;
					errorout<<"Line# "<<yylineno<<": "<<"Conflicting types for "<<"'"<<$2->get_name()<<"'"<<endl;
				}
				bool bo=table.Remove($2->get_name());
				SymbolInfo* tmt=table.Insert($2->get_name(),$2->get_type());
				if(tmt!=NULL)
				{
				tmt->set_dataType("Function");
				tmt->set_funDef(1);
				tmt->set_funRetType($1->get_name());
				tmt->set_parList(par_list1);
				}
				table.Enter_Scope(++scope_table);
				for(int i=0;i<min(len1,len2);i++)
				{
					string dec=par_list1[i];
					string def=par_list2[i];
					vector<string> dec1;
					vector<string> def1;
					stringstream ss(dec);
					while(getline(ss,tm,' '))
					{
						dec1.push_back(tm);
					}
					stringstream ss1(def);
					while(getline(ss1,tm,' '))
					{
						def1.push_back(tm);
					}
					if((dec1[0]!=def1[0])||(dec1[1]!=def1[1]))
					{
						errcnt++;
						errorout<<"Line# "<<yylineno<<": "<<(i+1) << "th parameter's name not given in function definition of " <<  $2->get_name()<<endl;
					}
					else
					{
						string var_name=def1[1];
						string var_type=def1[0];

						int isArray;
						regex tmp6("[_A-Za-z][_A-Za-z0-9]*\[[0-9]+\]");
						if(regex_match(var_name, tmp6)) 
						{
							isArray=1;
						}
						else
						{
							isArray=0;
						} 
						regex regexp("[0-9]+");
						smatch mat;
						regex_search(var_name, mat, regexp);
						string size = "";
						for(auto tm : mat) 
						{
							size += tm;
						}


						SymbolInfo* tmmm=table.Insert(var_name,var_type);
						if(tmmm==NULL)
						{
							errcnt++;
							errorout<<"Line# "<<yylineno<<": "<<"Redefinition of parameter "<<"'"<<var_name<<"'"<<endl;
						}
						if(isArray==1&&tmmm!=NULL)
						{
							
							tmmm->set_arraySize(stoi(size));
							tmmm->set_dataType(var_type);
							
						}
						else
						{
							if(tmmm!=NULL)
							{
							tmmm->set_dataType(var_type);
							}
						}
					}
				}
			}
		}
		else
		{
			table.Enter_Scope(++scope_table);
			vector<string> lis;
			stringstream s($4->get_name());
			string tm;
			while(getline(s,tm,','))
			{
				lis.push_back(tm);
			}
			for(int i=0;i<lis.size();i++)
			{
				vector<string> var;
				stringstream s(lis[i]);
				string tmm;
				while(getline(s,tmm,' '))
				{
					var.push_back(tmm);
				}
				table.Insert(var[1],"error");
			}
			errcnt++;
			errorout<<"Line# "<<yylineno<<": "<<"'"<<$2->get_name()<<"' redeclared as different kind of symbol"<<endl;
		}		
	}
}
compound_statement{

	genFunctionEndAssemblyCode($2->get_name());



	//table.Print_All_Scope_Table(errorout);
	table.Exit_Scope();
	$$=new SymbolInfo($1->get_name()+" "+$2->get_name()+"("+$4->get_name()+")"+$7->get_name(),"func_definition");
	logout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->make_child($2);
		$$->make_child($3);
		$$->make_child($4);
		$$->make_child($5);
		$$->make_child($7);
		int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),min($4->get_startLine(),min($5->get_startLine(),$7->get_startLine())))));
		$$->set_startLine(lin);
		$$->set_endLine(yylineno);
		$$->set_productionRule("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
	}
}
| type_specifier ID LPAREN RPAREN
{

	global_var=0;
	genFunctionStartAssemblyCode($2->get_name());


	//table.Print_All_Scope_Table(errorout);
	SymbolInfo* tmp1=table.Look_Up($2->get_name());
	if(tmp1==NULL)
	{
		tmp1=table.Insert($2->get_name(),"ID");
		if(tmp1!=NULL)
		{
		tmp1->set_dataType("Function");
		tmp1->set_funRetType($1->get_name());
		tmp1->set_funDef(1);
		table.Enter_Scope(++scope_table);
		}
	}

	else
	{
		if(tmp1->get_dataType()=="Function")
		{
			if(tmp1->get_funDef()==1)
			{
				errcnt++;
				errorout<<"Line# "<<yylineno<<": "<<"Multiple declaration of "<<"'"<<$2->get_name()<<"'"<<" in parameter"<<endl;
			}
			else
			{
				vector<string>par_list1=tmp1->get_parList();
				int len1=par_list1.size();

				vector<string>par_list2;
				stringstream s($4->get_name());
				string tm;
				while(getline(s,tm,','))
				{
					par_list2.push_back(tm);
				}
				int len2=par_list2.size();
				/*if(len1!=len2)
				{
					errcnt++;
					errorout<<"Line# "<<yylineno<<": "<<"Total number of arguments mismatch with declaration in function "<<"'"<<$2->get_name()<<"'"<<endl;
				}*/
				if(tmp1->get_funRetType()!=$1->get_name())
				{
					errcnt++;
					errorout<<"Line# "<<yylineno<<": "<<"Return type mismatch with function declaration in function "<<"'"<<$2->get_name()<<"'"<<endl;
				}
				//bool bo=table.Remove($2->get_name()); jeheto declared var k undeclared dekhassilo oitar error ai karone hssilo
				//SymbolInfo* tmt=table.Insert($2->get_name(),$2->get_type());
				/*if(tmt!=NULL)
				{
				tmt->set_dataType("Function");
				tmt->set_funDef(1);
				tmt->set_funRetType($1->get_name());
				tmt->set_parList(par_list1);
				}*/
				if(tmp1!=NULL)
				{
					tmp1->set_funDef(1);
				}
				table.Enter_Scope(++scope_table);
			}
		}
		else
		{
			table.Enter_Scope(++scope_table);
			errcnt++;
			errorout<<"Line# "<<yylineno<<": "<<"Multiple declaration of "<<$2->get_name()<<endl;
		}
	}
	
}
compound_statement{


	genFunctionEndAssemblyCode($2->get_name());



	//table.Print_All_Scope_Table(logout);
	table.Exit_Scope();
	$$=new SymbolInfo($1->get_name()+" "+$2->get_name()+"("+")"+$6->get_name(),"func_definition");
	logout<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->make_child($2);
		$$->make_child($3);
		$$->make_child($4);
		$$->make_child($6);
		int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),min($4->get_startLine(),$6->get_startLine()))));
		$$->set_startLine(lin);
		$$->set_endLine(yylineno);
		$$->set_productionRule("func_definition : type_specifier ID LPAREN RPAREN compound_statement");
	}
}


;
parameter_list : parameter_list COMMA type_specifier ID{
	$$=new SymbolInfo($1->get_name()+","+$3->get_name()+" "+$4->get_name(),"parameter_list");
	logout<<"parameter_list  : parameter_list COMMA type_specifier ID"<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->make_child($2);
		$$->make_child($3);
		$$->make_child($4);
		int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),$4->get_startLine())));
		$$->set_startLine(lin);
		$$->set_endLine(yylineno);
		$$->set_productionRule("parameter_list : parameter_list COMMA type_specifier ID");
	}
	/*
	genVariableAssemblyCode($4);
	SymbolInfo* tmp=table.Insert($4->get_name(),$3->get_name());
	funcParam++;
	tmp->set_varAsmname("W. [BP+" + to_string(2*funcParam) + "]");
	*/
}
| parameter_list COMMA type_specifier{
	$$=new SymbolInfo($1->get_name()+","+$3->get_name(),"parameter_list");
	logout<<"parameter_list : parameter_list COMMA type_specifier "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->make_child($2);
		$$->make_child($3);
		int lin=min($1->get_startLine(),min($2->get_startLine(),$3->get_startLine()));
		$$->set_startLine(lin);
		$$->set_endLine(yylineno);
		$$->set_productionRule("parameter_list : parameter_list COMMA type_specifier ID");
	}
}
| type_specifier ID{
	$$=new SymbolInfo($1->get_name()+" "+$2->get_name(),"parameter_list");
	logout<<"parameter_list  : type_specifier ID"<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->make_child($2);
		int lin=min($1->get_startLine(),$2->get_startLine());
		$$->set_startLine(lin);
		$$->set_endLine(yylineno);
		$$->set_productionRule("parameter_list : type_specifier ID");
	}
	genVariableAssemblyCode($2);
	SymbolInfo* tmp1=table.Look_Up($2->get_name());
	if(tmp1!=NULL)
	{
		cout<<"not null"<<endl;
	}
	else
	{
		cout<<"null"<<endl;
	}
	/*
	SymbolInfo* tmp=table.Insert($2->get_name(),$1->get_name());
	funcParam++;
	tmp->set_varAsmname("W. [BP+" + to_string(2*funcParam) + "]");
	cout<<"name:"<<tmp->get_name()<<endl;
	cout<<"varAsmname:"<<tmp->get_varAsmname()<<endl;
	*/
}
| type_specifier{
	$$=new SymbolInfo($1->get_name(),"parameter_list");
	logout<<"parameter_list  : type_specifier "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->set_startLine($1->get_startLine());
		$$->set_endLine(yylineno);
		$$->set_productionRule("parameter_list : type_specifier");
	}
}
| type_specifier error{
	yyclearin;
	yyerrok;
	$$=new SymbolInfo($1->get_name(),"error");
	logout<<"parameter_list : type_specifier ID"<<endl;
	logout<<"Error at line no "<<yylineno<<" : syntax error"<<endl;
}
;
compound_statement : LCURL statements RCURL{
	$$=new SymbolInfo("{"+$2->get_name()+"}",$2->get_type());
	table.Print_All_Scope_Table(logout);
	logout<<"compound_statement : LCURL statements RCURL "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->make_child($2);
		$$->make_child($3);
		int lin=min($1->get_startLine(),min($2->get_startLine(),$3->get_startLine()));
		$$->set_startLine(lin);
		$$->set_endLine(yylineno);
		$$->set_productionRule("compound_statement : LCURL statements RCURL");
	}

}
| LCURL RCURL{
	$$=new SymbolInfo("{}","compound_statement");
	table.Print_All_Scope_Table(logout);
	logout<<"compound_statement : LCURL RCURL "<<endl;

	if($$!=NULL)
	{
		$$->make_child($1);
		$$->make_child($2);
		$$->set_startLine(min($1->get_startLine(),$2->get_startLine()));
		$$->set_endLine(yylineno);
		$$->set_productionRule("compound_statement : LCURL RCURL");
	}
}
;
var_declaration : type_specifier declaration_list SEMICOLON{
	$$=new SymbolInfo($1->get_name()+" "+$2->get_name()+";","var_declaration");
	logout<<"var_declaration : type_specifier declaration_list SEMICOLON  "<<endl;
	if($$!=NULL)
	{
		$$->make_child($1);
		$$->make_child($2);
		$$->make_child($3);
		int lin=min($1->get_startLine(),min($2->get_startLine(),$3->get_startLine()));
		$$->set_startLine(lin);
		$$->set_endLine(yylineno);
		$$->set_productionRule("var_declaration : type_specifier declaration_list SEMICOLON");
	}
	if($1->get_name()=="VOID")
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Variable or field '"<<$2->get_name()<<"' declared void"<<endl;
	}
	else
	{
		vector<string> lis;
		stringstream s($2->get_name());
		string tm;
		while(getline(s,tm,','))
		{
			lis.push_back(tm);
		}
		for(string tmp:lis)
		{
			regex tmp1("[_A-Za-z][_A-Za-z0-9]*\[[0-9]+\]");
			if(regex_match(tmp,tmp1))
			{
				//it is an array
				string arr_name="";
				int arr_size;
				for(int i=0;i<tmp.length();i++)
				{
					if(tmp[i]=='[')
					{	
						string tmp2="";
						int j=i+1;
						while(tmp[j]!=']')
						{
							tmp2+=tmp[j];
							j++;
						}
						arr_size=stoi(tmp2);
						break;
					}
					arr_name+=tmp[i];
				}
				SymbolInfo* tmp3=table.Insert(arr_name,$1->get_name());
				if(tmp3==NULL)
				{
					//already exists
					errcnt++;
					errorout<<"Line# "<<yylineno<<": "<<"Conflicting types for'"<<arr_name<<"'"<<endl;
				}
				else
				{
					cout<<arr_size<<endl;
					cout<<$1->get_name()<<endl;
					tmp3->set_dataType($1->get_name());
					tmp3->set_arraySize(arr_size);
					cout<<tmp3->get_arraySize()<<endl;


					//code for icg
					int base_position=2*(table.get_varCount()-dec_var_cnt+1);
					tmp3->set_varAsmname("W. [BP-" + to_string(base_position) + "]");
					tmp3->set_basePosition(base_position);
					if(global_var==1)//global variable
					{
						tmp3->set_global_var(1);
					}
					else
					{
						tmp3->set_global_var(0);
					}
					dec_var_cnt-=arr_size;
				}

			}
			else
			{
				//it is an variable
				SymbolInfo* tmp4=table.Insert(tmp,$1->get_name());
				if(tmp4==NULL)
				{
					//already exists
					errcnt++;
					errorout<<"Line# "<<yylineno<<": "<<"Conflicting types for'"<<tmp<<"'"<<endl;
				}
				else
				{
					tmp4->set_dataType($1->get_name());
					//used fot the icg offline
					//tmp4->set_varAsmname(tmp->get_varAsmname());
					//cout<<tmp->get_varAsmname()<<endl;

					
					tmp4->set_varAsmname("W. [BP-" + to_string(2*(table.get_varCount()-dec_var_cnt+1)) + "]");
					if(global_var==1)//global variable
					{
						tmp4->set_global_var(1);
					}
					else
					{
						tmp4->set_global_var(0);
					}
					dec_var_cnt--;
				}
			}
		}
	}
	dec_var_cnt=0;
}
| error SEMICOLON   {
        yyclearin;
        yyerrok;
        $$ = new SymbolInfo("", "error");
    }
;
type_specifier : INT{
	$$=new SymbolInfo("INT","int");
	logout<<"type_specifier	: INT "<<endl;
	if($$!=NULL)
	{
		$$->make_child($1);
		$$->set_startLine($1->get_startLine());
		$$->set_endLine(yylineno);
		$$->set_productionRule("type_specifier : INT");
	}
}
| FLOAT{
	$$=new SymbolInfo("FLOAT","float");
	logout<<"type_specifier	: FLOAT "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("type_specifier : FLOAT");
}
| VOID{
	$$=new SymbolInfo("VOID","void");
	logout<<"type_specifier	: VOID "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("type_specifier : VOID");
}
;
declaration_list : declaration_list COMMA ID{
	$$=new SymbolInfo($1->get_name()+","+$3->get_name(),$3->get_type());
	logout<<"declaration_list : declaration_list COMMA ID  "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	int lin=min($1->get_startLine(),min($2->get_startLine(),$3->get_startLine()));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("declaration_list : declaration_list COMMA ID");

	genVariableAssemblyCode($3);
	dec_var_cnt++;
}
| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
	$$=new SymbolInfo($1->get_name()+","+$3->get_name()+"["+$5->get_name()+"]","declaration_list");
	logout<<"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	$$->make_child($4);
	$$->make_child($5);
	$$->make_child($6);
	int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),min($4->get_startLine(),min($5->get_startLine(),$6->get_startLine())))));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");

	genArrayAssemblyCode($3,stoi($5->get_name()));
	table.set_varCount(stoi($5->get_name()));
	dec_var_cnt+=stoi($5->get_name());
}
| ID{
	$$=new SymbolInfo($1->get_name(),$1->get_type());
	logout<<"declaration_list : ID "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("declaration_list : ID");
	genVariableAssemblyCode($1);
	dec_var_cnt++;

	//cout<<"h6"<<" "<<$1->get_varAsmname()<<endl;
	//cout<<$1->get_name()<<endl;
	//SymbolInfo* hig=table.Look_Up($1->get_name());
	//if(hig!=NULL){cout<<hig->get_varAsmname()<<endl;}
	//cout<<hig->get_varAsmname()<<endl;
}
| ID LTHIRD CONST_INT RTHIRD{
	$$=new SymbolInfo($1->get_name()+"["+$3->get_name()+"]","ID");
	logout<<"declaration_list : ID LSQUARE CONST_INT RSQUARE "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	$$->make_child($4);
	int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),$4->get_startLine())));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("declaration_list : ID LSQUARE CONST_INT RSQUARE");
	genArrayAssemblyCode($1,stoi($3->get_name()));
	table.set_varCount(stoi($3->get_name()));
	dec_var_cnt+=stoi($3->get_name());

}
|declaration_list error{
	yyclearin;
	yyerrok;
	$$=new SymbolInfo($1->get_name(),"error");
	logout<<"Error at line no "<<yylineno<<" : syntax error"<<endl;
	errorout<<"Line# "<<yylineno<<": "<<"Syntax error at declaration list of variable declaration"<<endl;
}
;
statements : statement{
	$$=new SymbolInfo($1->get_name(),"statement");
	logout<<"statements : statement  "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("statements : statement");
}
| statements statement{
	$$=new SymbolInfo($1->get_name()+" "+$2->get_name(),"statements");
	logout<<"statements : statements statement  "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->set_startLine(min($1->get_startLine(),$2->get_startLine()));
	$$->set_endLine(yylineno);
	$$->set_productionRule("statements : statements statement");
}
;
statement : var_declaration{
	$$=new SymbolInfo($1->get_name(),"statement");
	logout<<"statement : var_declaration "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("statement : var_declaration");
}
| expression_statement{
	$$=new SymbolInfo($1->get_name(),"statement");
	logout<<"statement : expression_statement "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("statement : expression_statement");
	codeSegmentout<<"\t\tPOP AX"<<endl;
}
|{
	scope_table++;
	table.Enter_Scope(scope_table);
}
| compound_statement{
	$$=new SymbolInfo($1->get_name(),"statement");
	logout<<"statement : compound_statement "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("statement : compound_statement");
}
|FOR LPAREN expression_statement{
	FOR_START="@" + string("FOR_START")+"_" + to_string(labelCnt);
	FOR_END="@" + string("FOR_END")+"_" + to_string(labelCnt);
	FOR_STMT="@" + string("FOR_STMT")+"_" + to_string(labelCnt);
	FOR_LOOP="@" + string("FOR_LOOP")+"_" + to_string(labelCnt);
	FOR_CON="@" + string("FOR_CON")+"_" + to_string(labelCnt++);
	codeSegmentout<<"\t\tPOP AX"<<endl;
	codeSegmentout<<"\t\t"<<FOR_CON<<":"<<endl;
} expression_statement{

	codeSegmentout<<"\t\tPOP AX"<<endl;
	codeSegmentout<<"\t\tCMP AX, 0"<<endl;
	codeSegmentout<<"\t\tJE "<<FOR_END<<endl;
	codeSegmentout<<"\t\tJMP "<<FOR_STMT<<endl;
	codeSegmentout<<"\t\t"<<FOR_LOOP<<":"<<endl;
} expression{

	codeSegmentout<<"\t\tPOP AX"<<endl;
	codeSegmentout<<"\t\tJMP "<<FOR_CON<<endl;
	codeSegmentout<<"\t\t"<<FOR_STMT<<":"<<endl;
} RPAREN statement{

	$$=new SymbolInfo($1->get_name()+"("+$3->get_name()+" "+$5->get_name()+" "+$7->get_name()+")"+$10->get_name(),"statement");
	logout<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	$$->make_child($5);
	$$->make_child($7);
	$$->make_child($9);
	$$->make_child($10);
	int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),min($5->get_startLine(),min($7->get_startLine(),min($9->get_startLine(),$10->get_startLine()))))));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");

	codeSegmentout<<"\t\tJMP "<<FOR_LOOP<<endl;
	codeSegmentout<<"\t\t"<<FOR_END<<":"<<endl;
}
| if_condition %prec LOWER_THAN_ELSE {
	codeSegmentout<<"\t\t"+$1->get_label()+":\n";
	$$=new SymbolInfo($1->get_name(),"statement");
	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("statement : if_condition");
	logout<<"statement : if_condition "<<endl;
}
| if_condition ELSE {

	string label = "@" + string("END_ELSE")+"_" + to_string(labelCnt++);
	codeSegmentout<<"\t\tJMP "+label<<endl; 
	codeSegmentout<<"\t\t"+$1->get_label()+":\n";
	$1->set_label(label);
} statement {


	codeSegmentout<<"\t\t"+$1->get_label()+":\n";
	$$=new SymbolInfo($1->get_name()+$2->get_name()+$4->get_name(),"statement");
	logout<<"statement : if_condition ELSE statement "<<endl;
	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($4);
	int lin=min($1->get_startLine(),min($2->get_startLine(),$4->get_startLine()));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("statement : if_condition ELSE statement");
}
|WHILE LPAREN {
	While_label1 = "@" + string("WHILE_LOOP")+"_" + to_string(labelCnt++);
	codeSegmentout<<"\t\t"<<While_label1<<":"<<endl;
} expression RPAREN {

	While_label2="@" + string("END_WHILE_LOOP")+"_" + to_string(labelCnt++);
	codeSegmentout<<"\t\tPOP AX"<<endl;
	codeSegmentout<<"\t\tCMP AX,0"<<endl;
	codeSegmentout<<"\t\tJE "<<While_label2<<endl;
} statement {
	$$=new SymbolInfo($1->get_name()+"("+$4->get_name()+")"+$7->get_name(),"statement");
	logout<<"statement : WHILE LPAREN expression RPAREN statement "<<endl;



	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($4);
	$$->make_child($5);
	$$->make_child($7);
	int lin=min($1->get_startLine(),min($2->get_startLine(),min($4->get_startLine(),min($5->get_startLine(),$7->get_startLine()))));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("statement : WHILE LPAREN expression RPAREN statement");

	codeSegmentout<<"\t\tJMP "<<While_label1<<endl;
	codeSegmentout<<"\t\t"<<While_label2<<":"<<endl;
}
| PRINTLN LPAREN ID RPAREN SEMICOLON{
	$$=new SymbolInfo($1->get_name()+"("+$3->get_name()+")"+";","statement");
	logout<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl;

	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	$$->make_child($4);
	$$->make_child($5);
	int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),min($4->get_startLine(),$5->get_startLine()))));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("statement : PRINTLN LPAREN ID RPAREN SEMICOLON");

	SymbolInfo* tmp=table.Look_Up($3->get_name());
	if(tmp==NULL)
	{
		//the variable which i want to print, is not defined before
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Undeclared variable '"<<$3->get_name()<<"'"<<endl;
	}

	SymbolInfo* tmpp=table.Look_Up($1->get_name());
	if(tmpp==NULL)
	{
		//the variable which i want to print, is not defined before
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Undeclared function '"<<$1->get_name()<<"'"<<endl;
	}


	if(tmp->get_global_var()==1)
	{
		codeSegmentout<<"\t\tMOV BX, "+tmp->get_name()<<endl;
	}
	else
	{
		codeSegmentout<<"\t\tMOV BX, "+tmp->get_varAsmname()<<endl;
	}
	
	codeSegmentout<<"\t\tCALL PRINT_NUM"<<endl;
}
| RETURN expression SEMICOLON{
	$$=new SymbolInfo($1->get_name()+" "+$2->get_name()+";","statement");
	logout<<"statement : RETURN expression SEMICOLON"<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	int lin=min($1->get_startLine(),min($2->get_startLine(),$3->get_startLine()));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("statement : RETURN expression SEMICOLON");


	if(main_func==0)
	{
		codeSegmentout<<"\t\tPOP AX"<<endl;
		codeSegmentout<<"\t\tMOV [BP+4], AX"<<";move value form AX to ret value location"<<endl;
		codeSegmentout<<"\t\tADD SP, "<<to_string(table.get_varCount()*2)<<endl;

	}
}
;
if_condition : IF LPAREN expression RPAREN {
	string label = "@" + string("END_IF")+"_" + to_string(labelCnt++);
	codeSegmentout<<"\t\tPOP AX"<<endl;
	codeSegmentout<<"\t\tCMP AX, 0"<<endl;
	codeSegmentout<<"\t\tJE "+label<<endl;
	$3->set_label(label);
} statement {
	$$=new SymbolInfo($1->get_name()+"("+$3->get_name()+")"+$6->get_name(),"if_condition"); 
	logout<<"statement : IF LPAREN expression RPAREN statement "<<endl;
	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	$$->make_child($4);
	$$->make_child($6);
	int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),min($4->get_startLine(),$6->get_startLine()))));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("if_condition : IF LPAREN expression RPAREN statement");
	$$->set_label($3->get_label());
};
expression_statement : SEMICOLON{
	$$=new SymbolInfo($1->get_name(),"expression_statement");
	logout<<"expression_statement : SEMICOLON "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("expression_statement : SEMICOLON");

	codeSegmentout<<"\t\tPUSH 1"<<endl;

}
| expression SEMICOLON{
	$$=new SymbolInfo($1->get_name()+";","expression_statement");
	logout<<"expression_statement : expression SEMICOLON "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->set_startLine(min($1->get_startLine(),$2->get_startLine()));
	$$->set_endLine(yylineno);
	$$->set_productionRule("expression_statement : expression SEMICOLON");
}
| expression error{
	yyclearin;
	$$=new SymbolInfo("","error");
	
}
;
variable : ID{
	SymbolInfo* tmp=table.Look_Up($1->get_name());
	string var_type=$1->get_type();
	if(tmp==NULL)
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Undeclared variable '"<<$1->get_name()<<"'"<<endl;
		var_type="error";
	}
	else if(tmp->get_arraySize()!=$1->get_arraySize())
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Type mismatch for variable  '"<<$1->get_name()<<"'"<<endl;
		var_type="error";
	}

	$$=new SymbolInfo($1->get_name(),var_type);
	logout<<"variable : ID 	 "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("variable : ID");

	//used for icg offline
	$$->set_varAsmname($1->get_varAsmname());
	cout<<"h1"<<$1->get_varAsmname()<<endl;
	cout<<"h2"<<$$->get_varAsmname()<<endl;
	cout<<"hh"<<tmp->get_name()<<endl;


}
| ID LTHIRD expression RTHIRD{
	SymbolInfo* tmp=table.Look_Up($1->get_name());
	string var_type=$1->get_type();
	if(tmp==NULL)
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Undeclared variable '"<<$1->get_name()<<"'"<<endl;
		var_type="error";
	}
	else
	{
		//it is an array
		if(tmp->get_arraySize()==0)
		{
			errcnt++;
			errorout<<"Line# "<<yylineno<<": "<<"'"<<$1->get_name()<<"'"<<" is not an array"<<endl;
			var_type="error";
		}
		if($3->get_type()!="CONST_INT")
		{
			//the index of the array should be int
			errcnt++;
			errorout<<"Line# "<<yylineno<<": "<<"Array subscript is not an integer"<<endl;
			var_type="error";
		}
		
	}
	$$=new SymbolInfo($1->get_name()+"["+$3->get_name()+"]",var_type);
	logout<<"variable : ID LSQUARE expression RSQUARE "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	$$->make_child($4);
	int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),$4->get_startLine())));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("variable : ID LSQUARE expression RSQUARE");


	codeSegmentout<<"\t\tPOP AX"<<endl;
	codeSegmentout<<"\t\tSHL AX, 1"<<endl;
	codeSegmentout<<"\t\tLEA BX, "+tmp->get_varAsmname()<<endl;
	codeSegmentout<<"\t\tSUB BX, AX"<<endl;
	codeSegmentout<<"\t\tPUSH BX"<<endl;
	$$->set_varAsmname("[BX]");
}
;
expression : logic_expression{
	$$=new SymbolInfo($1->get_name(),$1->get_type());
	//$$=$1;
	logout<<"expression 	: logic_expression	 "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("expression : logic_expression");
}
| variable ASSIGNOP logic_expression{
	string var_type=$1->get_type();
	string tmp1=$1->get_dataType();
	string tmp2=$3->get_dataType();
	if($1->get_type()=="error")
	{
		var_type="error";
	}
	else if($3->get_type()=="error")
	{
		var_type="error";
	}
	else if($3->get_type()=="void_err")
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Void cannot be used in expression "<<endl;
		var_type="error";
	}
	if(tmp1=="float"&&(tmp2=="int"||tmp2=="CONST_INT"))
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Floating point variable take integer value"<<endl;
		var_type="error";
	}
	$$=new SymbolInfo($1->get_name()+"="+$3->get_name(),var_type);
	logout<<"expression : variable ASSIGNOP logic_expression "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	int lin=min($1->get_startLine(),min($2->get_startLine(),$3->get_startLine()));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("expression : variable ASSIGNOP logic_expression");


	
	SymbolInfo* tmpicg=table.Look_Up($1->get_name());
	cout<<"name of array "<<$1->get_name()<<endl;
	if(tmpicg!=NULL)
	{
		if(tmpicg->get_global_var()==1)
		{
			codeSegmentout<<"\t\tPOP AX"<<";load "<< $3->get_name()<<" line no:"<<yylineno<<endl;
			codeSegmentout<<"\t\tMOV "+tmpicg->get_name()+", AX"<<endl;
			codeSegmentout<<"\t\tPUSH AX"<<";save "<< $1->get_name()<<" line no:"<<yylineno<<endl;
		}
		else
		{
			codeSegmentout<<"\t\tPOP AX"<<";load "<< $3->get_name()<<" line no:"<<yylineno<<endl;
			cout<<"hey"<<" "<<tmpicg->get_varAsmname()<<endl;
			codeSegmentout<<"\t\tMOV "+tmpicg->get_varAsmname()+", AX"<<endl;
			codeSegmentout<<"\t\tPUSH AX"<<";save "<< $1->get_name()<<" line no:"<<yylineno<<endl;
		}
	}
	if(tmpicg==NULL)
	{
	codeSegmentout<<"\t\tPOP AX"<<";load "<< $3->get_name()<<" line no:"<<yylineno<<endl;
	codeSegmentout<<"\t\tMOV "+$1->get_varAsmname()+", AX"<<endl;
	codeSegmentout<<"\t\tPUSH AX"<<";save "<< $1->get_name()<<" line no:"<<yylineno<<endl;
	}

}
;
logic_expression : rel_expression{
	$$=new SymbolInfo($1->get_name(),$1->get_type());
	//$$=$1;
	logout<<"logic_expression : rel_expression 	 "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("logic_expression : rel_expression");

}
| rel_expression LOGICOP {



	codeSegmentout<<"\t\tPOP AX"<<";load "<< $1->get_name()<<" line no:"<<yylineno<<endl;
	string tmp;
	if($2->get_name()=="&&")
	{
		tmp="1";
	}
	else 
	{
		tmp="0";
	}
	codeSegmentout<<"\t\tCMP AX, "<<tmp<<endl;
	string label="@L_" + to_string(labelCnt++);
	codeSegmentout<<"\t\tJNE "<<label<<endl;
	$1->set_label(label);

	} rel_expression {
	$$=new SymbolInfo($1->get_name()+$2->get_name()+$4->get_name(),"int");//as the result of logicop operation is integer
	logout<<"logic_expression : rel_expression LOGICOP rel_expression "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($4);
	int lin=min($1->get_startLine(),min($2->get_startLine(),$4->get_startLine()));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("logic_expression : rel_expression LOGICOP rel_expression");



	codeSegmentout<<"\t\tPOP AX"<<";load "<< $4->get_name()<<" line no:"<<yylineno<<endl;
	string tmp1;
	if($2->get_name()=="&&")
	{
		tmp1="1";
	}
	else 
	{
		tmp1="0";
	}
	codeSegmentout<<"\t\tCMP AX, "<<tmp1<<endl;
	codeSegmentout<<"\t\tJNE "<<$1->get_label()<<endl;
	codeSegmentout<<"\t\tPUSH "<<tmp1<<endl;
	string label1="@L_" + to_string(labelCnt++);
	codeSegmentout<<"\t\tJMP "<<label1<<endl;
	codeSegmentout<<$1->get_label()<<":"<<endl;
	string tmp2;
	if($2->get_name()=="&&")
	{
		tmp2="0";
	}
	else 
	{
		tmp2="1";
	}
	codeSegmentout<<"\t\tPUSH "<<tmp2<<endl;
	codeSegmentout<<label1<<":"<<endl;
}
;
rel_expression : simple_expression{
	$$=new SymbolInfo($1->get_name(),$1->get_type());
	logout<<"rel_expression	: simple_expression "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("rel_expression : simple_expression");
}
| simple_expression RELOP simple_expression{
	$$=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(),"int");
	logout<<"rel_expression : simple_expression RELOP simple_expression "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	int lin=min($1->get_startLine(),min($2->get_startLine(),$3->get_startLine()));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("rel_expression : simple_expression RELOP simple_expression");

	//code for icg
	string rel;
	if($2->get_name()=="==")
	{
		rel="JE";
	}
	else if($2->get_name()=="<=")
	{
		rel="JLE";
	}
	else if($2->get_name()==">=")
	{
		rel="JGE";
	}
	else if($2->get_name()=="<")
	{
		rel="JL";
	}
	else if($2->get_name()==">")
	{
		rel="JG";
	}
	else if($2->get_name()=="!=")
	{
		rel="JNE";
	}


	string label1= "@L_" + to_string(labelCnt++);
	string label2= "@L_" + to_string(labelCnt++);

	codeSegmentout<<"\t\tPOP BX"<<";load "<< $3->get_name()<<" line no:"<<yylineno<<endl;
	codeSegmentout<<"\t\tPOP AX"<<";load "<< $1->get_name()<<" line no:"<<yylineno<<endl;
	codeSegmentout<<"\t\tCMP AX, BX"<<endl;
	codeSegmentout<<"\t\t"<<rel<<" "<<label1<<endl;
	codeSegmentout<<"\t\t\tPUSH 0"<<endl;
	codeSegmentout<<"\t\t\tJMP "<<label2<<endl;
	codeSegmentout<<"\t\t"<<label1<<":"<<endl;
	codeSegmentout<<"\t\t\tPUSH 1"<<endl;
	codeSegmentout<<"\t\t"<<label2+":"<<endl;
}
;
simple_expression : term{
	$$=new SymbolInfo($1->get_name(),$1->get_type());
	logout<<"simple_expression : term "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("simple_expression : term");
}
| simple_expression ADDOP term{
	string var_type;
	if($1->get_dataType()=="CONST_FLOAT"||$3->get_dataType()=="CONST_FLOAT"||$1->get_dataType()=="float"||$3->get_dataType()=="float")
	{
		var_type="float";
	}
	else
	{
		var_type="int";
	}
	$$=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(),"var_type");
	logout<<"simple_expression : simple_expression ADDOP term  "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	int lin=min($1->get_startLine(),min($2->get_startLine(),$3->get_startLine()));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("simple_expression : simple_expression ADDOP term");











	codeSegmentout<<"\t\tPOP BX"<<";load "<< $3->get_name()<<" line no:"<<yylineno<<endl;
	codeSegmentout<<"\t\tPOP AX"<<";load "<< $1->get_name()<<" line no:"<<yylineno<<endl;
	if($2->get_name()=="+")
	{
		codeSegmentout<<"\t\tADD AX,BX"<<endl;
	}
	else
	{
		codeSegmentout<<"\t\tSUB AX,BX"<<endl;
	}
	codeSegmentout<<"\t\tPUSH AX"<<";save "<< $1->get_name()<<" line no:"<<yylineno<<endl;
}
| term error{
	yyclearin;
	yyerrok;
	$$=new SymbolInfo($1->get_name(),"error");
	logout<<"simple_expression : term "<<endl;
	errorout<<"Line# "<<yylineno<<": "<<"Syntax error at expression of expression statement"<<endl;
	//logout<<"Error at line no "<<yylineno<<" : syntax error"<<endl;
	//errorout<<"Line# "<<yylineno<<": "<<"Syntax error"<<endl;
}
;
term : unary_expression{
	$$=new SymbolInfo($1->get_name(),$1->get_type());
	//$$=$1;
	logout<<"term :	unary_expression "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("term : unary_expression");

}
| term MULOP unary_expression{
	string var_type;
	if($1->get_dataType()=="CONST_FLOAT"||$3->get_dataType()=="CONST_FLOAT"||$1->get_dataType()=="float"||$3->get_dataType()=="float")
	{
		var_type="float";
	}
	else
	{
		var_type="int";
	}
	if($1->get_type()=="void_err"||$3->get_type()=="void_err")
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Void cannot be used in expression "<<endl;
		var_type="error";
	}
	if($2->get_name()=="/"&& $3->get_name()=="0")
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<" A number can not divided by zero"<<endl;
		var_type="error";
	}
	else if($2->get_name()=="%"&& $3->get_name()=="0")
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Warning: division by zero i=0f=1Const=0"<<endl;
		var_type="error";
	}
	else if($2->get_name()=="%" && ($1->get_type()!="CONST_INT"||$3->get_type()!="CONST_INT"))
	{
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Operands of modulus must be integers "<<endl;
		var_type="error";
	}
	$$=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(),var_type);;
	logout<<"term : term MULOP unary_expression "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	int lin=min($1->get_startLine(),min($2->get_startLine(),$3->get_startLine()));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("term : term MULOP unary_expression");











	codeSegmentout<<"\t\tPOP BX"<<";load "<< $3->get_name()<<" line no:"<<yylineno<<endl;
	codeSegmentout<<"\t\tPOP AX"<<";load "<< $1->get_name()<<" line no:"<<endl;
	codeSegmentout<<"\t\tXOR DX , DX"<<";making DX zero "<<endl;
	if($2->get_name()=="*")
	{
		codeSegmentout<<"\t\tIMUL BX"<<endl;
		codeSegmentout<<"\t\tPUSH AX"<<endl;
	}
	else
	{
		codeSegmentout<<"\t\tIDIV BX"<<endl;
		if($2->get_name()=="/")
		{
			codeSegmentout<<"\t\tPUSH AX"<<endl;
		}
		else if($2->get_name()=="%")
		{
			codeSegmentout<<"\t\tPUSH DX"<<endl;
		}
	}

}
;
unary_expression : ADDOP unary_expression{
	$$=new SymbolInfo($1->get_name()+" "+$2->get_name(),"unary_expression");
	logout<<"unary_expression : ADDOP unary_expression "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->set_startLine(min($1->get_startLine(),$2->get_startLine()));
	$$->set_endLine(yylineno);
	$$->set_productionRule("unary_expression : ADDOP unary_expression");
	





	if($1->get_name()=="-")
	{
		codeSegmentout<<"\t\tPOP AX"<<endl;
		codeSegmentout<<"\t\tNEG AX"<<endl;
		codeSegmentout<<"\t\tPUSH AX"<<"; make the number into negitive "<<"line no:"<<yylineno<<endl;
	}
}
| NOT unary_expression{
	$$=new SymbolInfo("!"+$2->get_name(),"unary_expression");
	logout<<"unary_expression : NOT unary_expression "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->set_startLine(min($1->get_startLine(),$2->get_startLine()));
	$$->set_endLine(yylineno);
	$$->set_productionRule("unary_expression : NOT unary_expression");
}
| factor{
	$$=new SymbolInfo($1->get_name(),$1->get_type());
	logout<<"unary_expression : factor "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("unary_expression : factor");
}
;
factor : variable{
	$$=new SymbolInfo($1->get_name(),"factor");
	logout<<"factor	: variable "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("factor : variable");

	
	SymbolInfo* tmp=table.Look_Up($1->get_name());
	if(tmp!=NULL)
	{
		if(tmp->get_global_var()==1)
		{
			codeSegmentout<<"\t\tPUSH "<<tmp->get_name()<<";save "<<tmp->get_name()<<" line no:"<<yylineno<<endl;
			//cout<<"haa akhanei ase"<<tmp->get_name()<<" "<<tmp->get_varAsmname()<<endl;
		}
		else
		{
			//cout<<"PUSH"<<" "<<tmp->get_varAsmname()<<endl;
			codeSegmentout<<"\t\tPUSH "<<tmp->get_varAsmname()<<";save "<<tmp->get_name()<<" line no:"<<yylineno<<endl;
		}	
	}
}
| ID LPAREN argument_list RPAREN{


	int argument_size;//used for the icg

	string var_type;
	//table.Print_All_Scope_Table(errorout);
	SymbolInfo* tmp1=table.Look_Up($1->get_name());
	
	if(tmp1==NULL)
	{
		//error because the pattern as fun(...) should be inserted in the symbol table as it is a function
		var_type="error";
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Undeclared function '"<<$1->get_name()<<"'"<<endl;
	}
	else if(tmp1->get_dataType()!="Function")
	{
		//this is also an error as fun(...) is not an id caue id do not follow first parenthesis
		var_type="error";
		errcnt++;
		errorout<<"Line# "<<yylineno<<": "<<"Undeclared function '"<<$1->get_name()<<"'"<<endl;
	}
	else if(tmp1->get_dataType()=="Function")
	{
		var_type=tmp1->get_funRetType();
		vector<string> par_list=tmp1->get_parList();
		vector<string> arg_list;
		stringstream s($3->get_name());
		string tm;
		while(getline(s,tm,','))
		{
			arg_list.push_back(tm);
		}
		/*for(int i=0;i<arg_list.size();i++)
		{
			errorout<<yylineno<<" "<<arg_list[i]<<endl;
		}*/

		argument_size=arg_list.size();//used for icg


		if(par_list.size()>arg_list.size())
		{
			var_type="error";
			errcnt++;
			errorout<<"Line# "<<yylineno<<": "<<"Too few arguments to function '"<<$1->get_name()<<"'"<<endl;
		}
		else if(par_list.size()<arg_list.size())
		{
			var_type="error";
			errcnt++;
			errorout<<"Line# "<<yylineno<<": "<<"Too many arguments to function '"<<$1->get_name()<<"'"<<endl;
		}
		else
		{
			var_type=tmp1->get_funRetType();
			for(int i=0;i<par_list.size();i++)
			{
				//errorout<<yylineno<<" "<<par_list[i]<<endl;
				string tmp2=par_list[i];
				stringstream s(tmp2);
				string tmp3;
				vector<string>tmp4;
				while(getline(s,tmp3,' '))
				{
					tmp4.push_back(tmp3);
				}
				stringstream ss(arg_list[i]);
				vector<string>tmp5;
				while(getline(ss,tmp3,'.'))
				{
					tmp5.push_back(tmp3);
				}
				if(tmp4[0]=="INT"&&tmp5.size()>1)
				{
					var_type="error";
					errcnt++;
					errorout<<"Line# "<<yylineno<<": "<<"Type mismatch for argument "<<i+1<<" of "<<"'"<<$1->get_name()<<"'"<<endl;
				}
				else if(tmp4[0]!="INT"&&tmp5.size()==1)
				{
					var_type="error";
					errcnt++;
					errorout<<"Line# "<<yylineno<<": "<<"Type mismatch for argument "<<i+1<<" of "<<"'"<<$1->get_name()<<"'"<<endl;
				}
			}
		}
		if(tmp1->get_funRetType()=="VOID")
		{
			var_type="void_err";
		}
	}
	
	$$=new SymbolInfo($1->get_name()+"("+$3->get_name()+")",var_type);
	logout<<"factor : ID LPAREN argument_list RPAREN "<<endl;



	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	$$->make_child($4);
	int lin=min($1->get_startLine(),min($2->get_startLine(),min($3->get_startLine(),$4->get_startLine())));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("factor : ID LPAREN argument_list RPAREN");





	codeSegmentout<<"\t\tPUSH 0"<<endl;
	codeSegmentout<<"\t\tCALL "<<$1->get_name()<<";call function "<<$1->get_name()<<" line no:"<<yylineno<<endl;
	codeSegmentout<<"\t\tPOP AX"<<";store return value, line no:"<<yylineno<<endl;
	codeSegmentout<<"\t\tADD SP,"+to_string(argument_size*2)<<endl;
	if($1->get_funRetType()!="VOID")
	{
		codeSegmentout<<"\t\tPUSH AX"<<endl;
	}
	else
	{
		codeSegmentout<<"\t\tPUSH 0"<<endl;
	}
}
| LPAREN expression RPAREN{
	$$=new SymbolInfo("("+$2->get_name()+")",$2->get_type());
	logout<<"factor : LPAREN expression RPAREN "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	int lin=min($1->get_startLine(),min($2->get_startLine(),$3->get_startLine()));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("factor : LPAREN expression RPAREN");
}
| CONST_INT{
	$$=new SymbolInfo($1->get_name(),"CONST_INT");
	$$->set_dataType("int");
	logout<<"factor	: CONST_INT   "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("factor : CONST_INT");


	codeSegmentout<<"\t\tPUSH " + $1->get_name()<<";store "<<$1->get_name()<<",line no:"<<yylineno<<endl;

}
| CONST_FLOAT{
	$$=new SymbolInfo($1->get_name(),"CONST_FLOAT");
	$$->set_dataType("float");
	logout<<"factor : CONST_FLOAT "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("factor : CONST_FLOAT");


	codeSegmentout<<"\t\tPUSH " + $1->get_name()<<";store "<<$1->get_name()<<",line no:"<<yylineno<<endl;
}
| variable INCOP{
	$$=new SymbolInfo($1->get_name()+"++",$1->get_type());
	$$->set_dataType($1->get_type());
	logout<<"factor : variable INCOP "<<endl;

	$$->make_child($1);
	$$->make_child($2);
	$$->set_startLine(min($1->get_startLine(),$2->get_startLine()));
	$$->set_endLine(yylineno);
	$$->set_productionRule("factor : variable INCOP");

	SymbolInfo* tmpinc=table.Look_Up($1->get_name());
	if(tmpinc!=NULL)
	{
		codeSegmentout<<"\t\t"<<"PUSH "<<tmpinc->get_varAsmname()<<endl;
		codeSegmentout<<"\t\t"<<"INC"<<" "<<tmpinc->get_varAsmname()<<";"<<tmpinc->get_name()<<"++ ."<<"line no:"<<yylineno<<endl;
		
	}
}
| variable DECOP{
	$$=new SymbolInfo($1->get_name()+"--",$1->get_type());
	$$->set_dataType($1->get_type());
	logout<<"factor : variable DECOP "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->set_startLine(min($1->get_startLine(),$2->get_startLine()));
	$$->set_endLine(yylineno);
	$$->set_productionRule("factor : variable DECOP");


	SymbolInfo* tmpdec=table.Look_Up($1->get_name());
	if(tmpdec!=NULL)
	{
		codeSegmentout<<"\t\t"<<"PUSH "<<tmpdec->get_varAsmname()<<endl;
		codeSegmentout<<"\t\t"<<"DEC"<<" "<<tmpdec->get_varAsmname()<<";"<<tmpdec->get_name()<<"-- ."<<"line no:"<<yylineno<<endl;
		
	}
}
;
argument_list : arguments{
	$$=new SymbolInfo($1->get_name(),"argument_list");
	logout<<"argument_list : arguments "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("argument_list : arguments");

}
| {
	$$=new SymbolInfo("argument_list","epsilon");
	logout<<"argument_list : empty "<<endl;
}
;
arguments : arguments COMMA logic_expression{
	$$=new SymbolInfo($1->get_name()+","+$3->get_name(),"arguments");
	logout<<"arguments : arguments COMMA logic_expression "<<endl;


	$$->make_child($1);
	$$->make_child($2);
	$$->make_child($3);
	int lin=min($1->get_startLine(),min($2->get_startLine(),$3->get_startLine()));
	$$->set_startLine(lin);
	$$->set_endLine(yylineno);
	$$->set_productionRule("arguments : arguments COMMA logic_expression");
}
| logic_expression{
	$$=new SymbolInfo($1->get_name(),"arguments");
	logout<<"arguments : logic_expression "<<endl;


	$$->make_child($1);
	$$->set_startLine($1->get_startLine());
	$$->set_endLine(yylineno);
	$$->set_productionRule("arguments : logic_expression");
}
;
%%
int main(int argc,char *argv[])
{

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout.open("log.txt", ios::out);
	errorout.open("error.txt", ios::out);
	parseout.open("parsetree.txt", ios::out);

	codeAsmOut.open("code.asm", ios::out);
	codeAsmOut << ".MODEL SMALL \n .STACK 100h \n .DATA \n";
	//dataSegmentout.open("dataSegment.txt", ios::out);
	codeSegmentout.open("codeSegment.txt", ios::out);
	//dataSegmentout << ".MODEL SMALL \n .STACK 100h \n .DATA \n";
	codeSegmentout << ".CODE \n";
	
	yyin= fin;
	yylineno=1;
	yyparse();
	logout<<"Total Lines: "<<yylineno<<endl;
	logout<<"Total Errors: "<<errcnt<<endl;
	logout.close();
	errorout.close();
	parseout.close();


 	ifstream dataSegmentIn("dataSegment.txt");
	ifstream codeSegmentIn("codeSegment.txt");
   

	

    string line;
    while (getline(dataSegmentIn, line))
    {
        codeAsmOut << line << endl;
    }
    codeAsmOut << endl;
	
    while (getline(codeSegmentIn, line))
    {
        codeAsmOut << line << endl;
    }

	
		codeAsmOut<<"PRINT_NUM PROC"<<endl;
		codeAsmOut<<"\tMOV AX, 'Z'"<<endl;
		codeAsmOut<<"\tPUSH AX"<<endl;
		codeAsmOut<<"\tCMP BX, 0 "<<endl;
		codeAsmOut<<"\tJE ZERO"<<endl;
		codeAsmOut<<"\tJNL POSITIVE"<<endl;
		codeAsmOut<<"\tNEG BX"<<endl;
		codeAsmOut<<"\tMOV DL, '-'"<<endl;
		codeAsmOut<<"\tMOV AH, 2"<<endl;
		codeAsmOut<<"\tINT 21H"<<endl;
		codeAsmOut<<"\tJMP POSITIVE"<<endl;
		codeAsmOut<<"\tZERO:"<<endl;
		codeAsmOut<<"\t\tMOV DX, 0"<<endl;
		codeAsmOut<<"\t\tPUSH DX"<<endl;
		codeAsmOut<<"\t\tJMP PRINT_DIGIT"<<endl;
		codeAsmOut<<"\tPOSITIVE:"<<endl;
		codeAsmOut<<"\t\tMOV CX, 10"<<endl;
		codeAsmOut<<"\t\tMOV AX, BX"<<endl;
		codeAsmOut<<"\tSTORE_DIGIT:"<<endl;
		codeAsmOut<<"\t\tCMP AX, 0"<<endl;
		codeAsmOut<<"\t\tJE END_STORE_DIGIT"<<endl;
		codeAsmOut<<"\t\tMOV DX, 0"<<endl;
		codeAsmOut<<"\t\tDIV CX"<<endl;
		codeAsmOut<<"\t\tPUSH DX"<<endl;
		codeAsmOut<<"\t\tJMP STORE_DIGIT"<<endl;
		codeAsmOut<<"\tEND_STORE_DIGIT:"<<endl;
		codeAsmOut<<"\tPRINT_DIGIT:"<<endl;
		codeAsmOut<<"\t\tPOP DX"<<endl;
		codeAsmOut<<"\t\tCMP DX, 'Z'"<<endl;
		codeAsmOut<<"\t\tJE END_PRINT_DIGIT"<<endl;
		codeAsmOut<<"\t\tADD DX, 48"<<endl;
		codeAsmOut<<"\t\tMOV AH, 2"<<endl;
		codeAsmOut<<"\t\tINT 21H"<<endl;
		codeAsmOut<<"\t\tJMP PRINT_DIGIT"<<endl;
		codeAsmOut<<"\tEND_PRINT_DIGIT:"<<endl;
		codeAsmOut<<"\t\tPUSH AX"<<endl;
		codeAsmOut<<"\t\tPUSH DX"<<endl;
		codeAsmOut<<"\t\tMOV AH, 2"<<endl;
		codeAsmOut<<"\t\tMOV DL, 0DH"<<endl;
		codeAsmOut<<"\t\tINT 21H"<<endl;
		codeAsmOut<<"\t\tMOV DL, 0AH"<<endl;
		codeAsmOut<<"\t\tINT 21H"<<endl;
		codeAsmOut<<"\t\tPOP DX"<<endl;
		codeAsmOut<<"\t\tPOP AX"<<endl;
		codeAsmOut<<"\tRET"<<endl;
		codeAsmOut<<"PRINT_NUM ENDP"<<endl;
	
    codeAsmOut << endl << "END MAIN" << endl;

    dataSegmentIn.close();
    codeSegmentIn.close();
    codeAsmOut.close();
   
	//dataSegmentout.close();
	codeSegmentout.close();
	
	return 0;
}

