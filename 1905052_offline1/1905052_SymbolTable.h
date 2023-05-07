#include<bits/stdc++.h>
#include "1905052_ScopeTable.h"
using namespace std;

class SymbolTable
{
    ScopeTable* current_scope_table;
    int tot_bucket;
    ofstream MyWriteFile;
    public:

    SymbolTable(int tot_bucket)
    {
        this->tot_bucket=tot_bucket;
        current_scope_table=new ScopeTable(tot_bucket,nullptr,1);
    }

    void Insert(string name,string type)
    {
        if(current_scope_table==nullptr)
        {
            current_scope_table=new ScopeTable(tot_bucket,nullptr,1);
        }
        current_scope_table->insert(name,type);
    }
    
    bool Look_Up(string name)
    {
        if(current_scope_table==nullptr)
        {
            cout<<"    "<<"'"<<name<<"'"<<" not found in any of the ScopeTables"<<endl;
            ScopeTable::write_file(name);
            return false;
        }
        
        bool var;
        ScopeTable* tmp=current_scope_table;
        while(tmp!=nullptr)
        {
            var=tmp->look_Up(name);
            if(var==true)
            {
                return true;
            }
            tmp=tmp->get_Parent_Scope_Table();
        }
        cout<<"\t"<<"'"<<name<<"'"<<" not found in any of the ScopeTables"<<endl;
        ScopeTable::write_file(name);
        return false;
    }

    bool Remove(string name)
    {
        if(current_scope_table==nullptr)
        {
            cout<<"    "<<"Not found in the current ScopeTable"<<endl;
            ScopeTable::write_not_found();
            return false;
        }
        bool var=current_scope_table->deleted(name);
        return var;
    }

    void Print_Current_Scope_Table()
    {
        if(current_scope_table!=nullptr)
        {
            current_scope_table->print();
        }
    }
    void Print_All_Scope_Table()
    {
        if(current_scope_table!=nullptr)
        {
            ScopeTable* tmp=current_scope_table;
            while(tmp!=nullptr)
            {
                tmp->print();
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
        if(current_scope_table->get_Num_Of_Scope_Table()==1)
        {
            cout<<"    ScopeTable# 1 cannot be removed"<<endl;
            ScopeTable::write_scope_table_can_not_remove();
            return;
        }
        if(current_scope_table!=nullptr)
        {
            cout<<"    ScopeTable# "<<current_scope_table->get_Num_Of_Scope_Table()<<" removed"<<endl;
            ScopeTable::write_scope_table_remove(current_scope_table->get_Num_Of_Scope_Table());
            ScopeTable* tmp=current_scope_table;
            current_scope_table=current_scope_table->get_Parent_Scope_Table();
            delete tmp;
        }
    }

    void Exit_All_Scope_Table()
    {
        while(current_scope_table!=nullptr)
        {
            cout<<"    ScopeTable# "<<current_scope_table->get_Num_Of_Scope_Table()<<" removed"<<endl;
            ScopeTable::write_scope_table_remove(current_scope_table->get_Num_Of_Scope_Table());
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