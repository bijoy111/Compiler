#include<bits/stdc++.h>
using namespace std;

class SymbolInfo
{
    string name;
    string type;
    SymbolInfo *object;
    SymbolInfo* next;
    public:
    SymbolInfo(string name,string type)
    {
        this->name=name;
        this->type=type;
        this->next=nullptr;
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
};