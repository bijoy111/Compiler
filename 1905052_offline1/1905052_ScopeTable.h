#include<bits/stdc++.h>
#include<fstream>
#include <sstream>
#include "1905052_SymboInfo.h"
using namespace std;
ofstream MyWriteFile;
class ScopeTable
{
    ScopeTable* parent_scope;//to take the parent scope table of each scope table
    SymbolInfo** symbol;//use it as a array for the pointers of SymbolInfo type and a hash function.
    int scope_table_size;
    int num_of_scopetable=0;//unique number of each scope table


    int hash_fun(string name)
    {
        return sdbm_hash(name) % scope_table_size;
    }
    int sdbm_hash(string str) 
    {
	    int hash = 0;
	    int i = 0;
	    int len = str.length();

	    for (i = 0; i < len; i++)
	    {
		    hash = ((str[i]) + (hash << 6) + (hash << 16) - hash) % scope_table_size;//the mod is used to solve the overflow problem
	    }

	    return hash % scope_table_size;
    }
    

    public:
    ScopeTable(int tot_bucket,ScopeTable* tmp,int unique_num)
    {
        scope_table_size=tot_bucket;
        symbol=new SymbolInfo* [scope_table_size+1];
        for(int i=0;i<scope_table_size;i++)
        {
            symbol[i]=nullptr;
        }
        this->parent_scope=tmp; 
        this->num_of_scopetable=unique_num; 
        cout<<"\t"<<"ScopeTable# "<<num_of_scopetable<<" created"<<endl;
        MyWriteFile<<"\t"<<"ScopeTable# "<<num_of_scopetable<<" created"<<endl;
    }
    void insert(string name,string type)
    {
        int hash_index=hash_fun(name);
        int pos=1;
        if(symbol[hash_index]==nullptr)
        {
            symbol[hash_index]=new SymbolInfo(name,type);
            symbol[hash_index]->set_next(nullptr);
            cout<<"\t"<<"Inserted in ScopeTable# "<<num_of_scopetable<<" at position "<<hash_index+1<<", "<<pos<<endl;
            MyWriteFile<<"\t"<<"Inserted in ScopeTable# "<<num_of_scopetable<<" at position "<<hash_index+1<<", "<<pos<<endl;
            return;
        }
        SymbolInfo* p=nullptr;
        SymbolInfo* tmp=symbol[hash_index];
        while(tmp!=nullptr)
        {
            if(name == tmp->get_name())
            {
                cout<<"\t"<<"'"<<name<<"'"<<" already exists in the current ScopeTable"<<endl;
                MyWriteFile<<"\t"<<"'"<<name<<"'"<<" already exists in the current ScopeTable"<<endl;
                return;
            }
            p=tmp;
            tmp=tmp->get_next();
            pos++;
        }
        tmp=new SymbolInfo(name,type);
        p->set_next(tmp);
        tmp->set_next(nullptr);
        cout<<"\t"<<"Inserted in ScopeTable# "<<num_of_scopetable<<" at position "<<hash_index+1<<", "<<pos<<endl;
        MyWriteFile<<"\t"<<"Inserted in ScopeTable# "<<num_of_scopetable<<" at position "<<hash_index+1<<", "<<pos<<endl;
    }
    bool look_Up(string name)
    {
        int hash_index=hash_fun(name);
        SymbolInfo* tmp=symbol[hash_index];
        int pos=1;
        while(tmp!=nullptr)
        {
            if(name == tmp->get_name())
            {
                cout<<"\t"<<"'"<<name<<"'"<<"found in ScopeTable# "<<num_of_scopetable<<" at position "<<hash_index+1<<", "<<pos<<endl;
                MyWriteFile<<"\t"<<"'"<<name<<"' "<<"found in ScopeTable# "<<num_of_scopetable<<" at position "<<hash_index+1<<", "<<pos<<endl;
                return true;
            }
            tmp=tmp->get_next();
            pos++;
        }
        return false;
    }
    bool deleted(string name)
    {
        int hash_index=hash_fun(name);
        SymbolInfo* p=nullptr;
        SymbolInfo* tmp=symbol[hash_index];
        int pos=1;
        while(tmp!=nullptr)
        {
            if(name == tmp->get_name())
            {
                cout<<"\t"<<"Deleted "<<"'"<<name<<"'"<<" from ScopeTable# "<<num_of_scopetable<<" at position "<<hash_index+1<<", "<<pos<<endl;
                MyWriteFile<<"\t"<<"Deleted "<<"'"<<name<<"'"<<" from ScopeTable# "<<num_of_scopetable<<" at position "<<hash_index+1<<", "<<pos<<endl;
                if(p==nullptr)
                {
                    symbol[hash_index]=nullptr;
                    delete tmp;
                }
                else
                {
                    p->set_next(tmp->get_next());
                    delete tmp;
                }
                return true;
            }
            p=tmp;
            tmp=tmp->get_next();
            pos++;
        }
        cout<<"\t"<<"Not found in current ScopeTable"<<endl;
        MyWriteFile<<"\t"<<"Not found in the current ScopeTable"<<endl;
        return false;
    }
    ScopeTable* get_Parent_Scope_Table()
    {
        return parent_scope;
    }
    void print()
    {
        cout<<"\t"<<"ScopeTable# "<<num_of_scopetable<<endl;
        MyWriteFile<<"\t"<<"ScopeTable# "<<num_of_scopetable<<endl;
        for(int i=0;i<scope_table_size;i++)
        {
            cout<<"\t"<<i+1<<"--> ";
            MyWriteFile<<"\t"<<i+1<<"--> ";
            SymbolInfo* tmp=symbol[i];
            while(tmp!=nullptr)
            {
                cout<<"<"<<tmp->get_name()<<","<<tmp->get_type()<<"> ";
                MyWriteFile<<"<"<<tmp->get_name()<<","<<tmp->get_type()<<"> ";
                tmp=tmp->get_next();
            }
            cout<<endl;
            MyWriteFile<<endl;
        }
        return;
    }
    ~ScopeTable()
    {
        for(int i=0;i<scope_table_size;i++)
        {
            SymbolInfo* tmp=symbol[i];
            if(tmp!=nullptr)
            {
                SymbolInfo* temp=tmp;
                tmp=tmp->get_next();
                delete temp;
            }
        }
        delete symbol;
    }
    int get_Num_Of_Scope_Table()
    {
        return num_of_scopetable;
    }

    static void write_file(string name)
    {
        MyWriteFile<<"\t"<<"'"<<name<<"'"<<" not found in any of the ScopeTables"<<endl;
    }
    static void write_command(int cmd,string line)
    {
        MyWriteFile<<"Cmd "<<cmd++<<": "<<line<<endl;
    }
    static void write_mismatch(string str)
    {
        MyWriteFile<<"\t"<<"Number of parameters mismatch for the command "<<str<<endl;
    }
    static void write_scope_table_remove(int num_)
    {
        MyWriteFile<<"\t"<<"ScopeTable# "<<num_<<" removed"<<endl;
    }
    static void write_scope_table_can_not_remove()
    {
        MyWriteFile<<"\t"<<"ScopeTable# 1 cannot be removed"<<endl;
    }
    static void write_not_found()
    {
        MyWriteFile<<"\t"<<"Not found in the current ScopeTable"<<endl;
    }
    static void file_open()
    {
        MyWriteFile.open("output.txt");
    }
    static void file_close()
    {
        MyWriteFile.close();
    }
};