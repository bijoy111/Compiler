#include<bits/stdc++.h>
using namespace std;

class SymbolInfo
{
    string name;//atar mdde token or (what you call) ar name rakha hoi
    string type;//ar akane otar type ta ki hbe seta rakha hoi
    SymbolInfo *object;
    SymbolInfo* next;//atar offline 3 te apatoto kno use nai
    vector<string> par_list;//function ar parameter list or argument list gulo akhane thakbe
    string dataType;//
    int len=0;//for the variable. if it is an array then the size should be greater than 0
    string funRetType;//function ar return type ai variable a thakbe
    int funDef;//function defined kina setar jonno ai var k rakha hoise. ai variable ta 1 hbe jokhon function ar definition likha hbe
    

    int trmnal;//ata 1 hbe kno akta terminal ar jonno. actually ata parse tree ar jonno use krbo and ata 1 kre dbo parse tree ar leaf gulor jonno
    int sl;//start line used for the parse tree
    int el;//end line used for the parse tree
    string prod_rule;//production rule used for the parse tree

    vector<SymbolInfo*> child;//kno akta node ar theke jei child gulo paoa jai segular list akane thake
    


    //these variable are used for the icg offline
    string varAsmname;//the name of the variable in assembly code

    string lab; //this is used for labeling to jump on that label if required

    int base_position;//it is used for the base address of an array
    int global_var=0;

    public: 
    SymbolInfo(string name,string type)
    {
        this->name=name;
        this->type=type;
        this->next=nullptr;
        this->dataType="";
        len=0;
        funRetType="";
        funDef=0;
        prod_rule="";
        sl=1;
        el=1;
        trmnal=0;

        varAsmname="";
        lab="";
    }
    void set_name(string name)
    {
        this->name=name;
    }
    string get_name()
    {
        return name;
    }
    void set_type(string type)
    {
        this->type=type;
    }
    string get_type()
    {
        return type;
    }
    void set_next(SymbolInfo* next)
    {
        this->next=next;
    }
    SymbolInfo* get_next()
    {
        return next;
    }
    void set_parList(vector<string> par_list)
    {
        this->par_list=par_list;
    }
    vector<string> get_parList()
    {
        return par_list;
    }
    void set_dataType(string dataType)
    {
        this->dataType=dataType;
    }
    string get_dataType()
    {
        return dataType;
    }
    void set_arraySize(int len)
    {
        this->len=len;
    }
    int get_arraySize()
    {
        return len;
    }
    void set_funRetType(string funRetType)
    {
        this->funRetType=funRetType;
    }
    string get_funRetType()
    {
        return funRetType;
    }
    void set_funDef(int funDef)
    {
        this->funDef=funDef;
    }
    int get_funDef()
    {
        return funDef;
    }


    void make_child(SymbolInfo* tmp)
    {
        child.push_back(tmp);
    }
    vector<SymbolInfo*> get_childList()
    {
        return child;
    }
    void set_startLine(int tmp)
    {
        sl=tmp;
    }
    void set_endLine(int tmp)
    {
        el=tmp;
    }
    int get_startLine()
    {
        return sl;
    }
    int get_endLine()
    {
        return el;
    }
    void set_productionRule(string tmp)
    {
        prod_rule=tmp;
    }
    string get_productionRule()
    {
        return prod_rule;
    }
    void set_terminal(int tmp)
    {
        trmnal=tmp;
    }
    int get_terminal()
    {
        return trmnal;
    }




    //these code are used for the icg offline
    void set_varAsmname(string tmp)
    {
        varAsmname=tmp;
    }
    string get_varAsmname()
    {
        return varAsmname;
    }

    void set_label(string tmp)
    {
        lab=tmp;
    }
    string get_label()
    {
        return lab;
    }
    void set_basePosition(int tmp)
    {
        base_position=tmp;
    }
    int get_basePosition()
    {
        return base_position;
    }
    void set_global_var(int tmp)
    {
        global_var=tmp;
    }
    int get_global_var()
    {
        return global_var;
    }


};



/*




yacc -d -y -v 1905052.y

g++ -w -c -o y.o y.tab.c

flex 1905052.l

g++ -w -c -o l.o lex.yy.c

g++ y.o l.o -lfl -o sample

./sample input.txt


rm code.asm codeSegment.txt error.txt l.o lex.yy.c log.txt parsetree.txt sample y.o y.output y.tab.c y.tab.h




*/