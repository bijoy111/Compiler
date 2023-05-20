#include<bits/stdc++.h>
#include "symbolinfo.h"
using namespace std;
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
    }
    int insert(string name,string type)
    {
        int hash_index=hash_fun(name);
        int pos=1;
        if(symbol[hash_index]==nullptr)
        {
            symbol[hash_index]=new SymbolInfo(name,type);
            symbol[hash_index]->set_next(nullptr);
            return 1;
        }
        SymbolInfo* p=nullptr;
        SymbolInfo* tmp=symbol[hash_index];
        while(tmp!=nullptr)
        {
            if(name == tmp->get_name())
            {
                return 0;
            }
            p=tmp;
            tmp=tmp->get_next();
            pos++;
        }
        tmp=new SymbolInfo(name,type);
        p->set_next(tmp);
        tmp->set_next(nullptr);
        return 1;
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
        
        return false;
    }
    ScopeTable* get_Parent_Scope_Table()
    {
        return parent_scope;
    }
    void print(FILE* logout)
    {
        fprintf(logout,"\tScopeTable# %d\n",num_of_scopetable);
        for(int i=0;i<scope_table_size;i++)
        {
            SymbolInfo* tmp=symbol[i];
            if(tmp==nullptr)
            {
                continue;
            }
            fprintf(logout,"\t%d--> ",i+1);
            while(tmp!=nullptr)
            {
                string str1=tmp->get_name();
                string str2=tmp->get_type();
                char *s1 = &(str1[0]); 
                char *s2 = &(str2[0]); 
                fprintf(logout,"<%s,%s> ",s1,s2);
                tmp=tmp->get_next();
            }
            fprintf(logout,"\n");
            
           
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
};