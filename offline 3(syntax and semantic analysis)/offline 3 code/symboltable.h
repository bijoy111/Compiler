#include<bits/stdc++.h>
#include "scopetable.h"
using namespace std;
class SymbolTable
{
    ScopeTable* current_scope_table;
    int tot_bucket;
    public:

    SymbolTable(int tot_bucket)
    {
        this->tot_bucket=tot_bucket;
        current_scope_table=new ScopeTable(tot_bucket,nullptr,1);
    }

    SymbolInfo* Insert(string name,string type)
    {
        if(current_scope_table==nullptr)
        {
            current_scope_table=new ScopeTable(tot_bucket,nullptr,1);
        }
        return current_scope_table->insert(name,type);
    }
    
    SymbolInfo* Look_Up(string name)
    {
        if(current_scope_table==nullptr)
        {
            return NULL;
        }
        
        SymbolInfo* var;
        ScopeTable* tmp=current_scope_table;
        while(tmp!=nullptr)
        {
            var=tmp->look_Up(name);
            if(var!=NULL)
            {
                return var;
            }
            tmp=tmp->get_Parent_Scope_Table();
        }
        
        return NULL;
    }

    bool Remove(string name)
    {
        if(current_scope_table==nullptr)
        {
            
            return false;
        }
        bool var=current_scope_table->deleted(name);
        return var;
    }

    void Print_Current_Scope_Table(fstream& logout)
    {
        if(current_scope_table!=nullptr)
        {
            current_scope_table->print(logout);
        }
    }
    void Print_All_Scope_Table(fstream& logout)
    {
        if(current_scope_table!=nullptr)
        {
            ScopeTable* tmp=current_scope_table;
            while(tmp!=nullptr)
            {
                tmp->print(logout);
                tmp=tmp->get_Parent_Scope_Table();
            }
        }
    }

    void Enter_Scope(int unique_num)
    {
        current_scope_table=new ScopeTable(tot_bucket,current_scope_table,unique_num);
    }

    void Exit_Scope()
    {
        /*
        if(current_scope_table->get_Num_Of_Scope_Table()==1)
        {
            
            return;
        }
        if(current_scope_table!=nullptr)
        {
            
            ScopeTable* tmp=current_scope_table;
            current_scope_table=current_scope_table->get_Parent_Scope_Table();
            delete tmp;
        }
        */
        if(current_scope_table==nullptr)
        {
            return;
        }
        ScopeTable* tmp=current_scope_table;
        current_scope_table=current_scope_table->get_Parent_Scope_Table();
        delete tmp;

    }

    void Exit_All_Scope_Table()
    {
        while(current_scope_table!=nullptr)
        {
            
            ScopeTable* tmp=current_scope_table;
            current_scope_table=current_scope_table->get_Parent_Scope_Table();
            delete tmp;
        }
    }
    
    ~SymbolTable()
    {
        ScopeTable* tmp;
        while(current_scope_table!=nullptr)
        {
            tmp=current_scope_table->get_Parent_Scope_Table();
            delete current_scope_table;
            current_scope_table=tmp;
        }
    }
};