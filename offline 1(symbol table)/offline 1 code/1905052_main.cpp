#include<bits/stdc++.h>
#include<fstream>
#include <sstream>
#include "1905052_SymbolTable.h"
using namespace std;
int main()
{
    ifstream MyReadFile;
    MyReadFile.open("input.txt");
    string line, token;
	istringstream stream;
    getline(MyReadFile, line);
    int tot_bucket=stoi(line);//total number of bucket of each hash table 
    ScopeTable::file_open();
    SymbolTable symboltable(tot_bucket);
    int cmd=1;//for printing the command number
    int scope_table=1;//give each scope table a unique number
	while (!MyReadFile.eof()) 
    {
		getline(MyReadFile, line);
		if (MyReadFile.good()) 
        {
			stream.clear();
			stream.str(line);
            string arr[100];
            int ind=0;
			while (stream.good()) 
            {
				stream >> token;
                arr[ind++]=token;
			}
            ScopeTable::write_command(cmd,line);
            cout<<"Cmd "<<cmd++<<": "<<line<<endl;
            if(arr[0]=="I")
            {
               if(ind!=3)
               {
                    cout<<"    Number of parameters mismatch for the  command "<<arr[0]<<endl;
                    ScopeTable::write_mismatch(arr[0]);
               }
               else
               {
                    string name=arr[1];
                    string type=arr[2];
                    symboltable.Insert(name,type);
               }
            }
            else if(arr[0]=="L")
            {
               if(ind!=2)
               {
                cout<<"    Number of parameters mismatch for the  command "<<arr[0]<<endl;
                ScopeTable::write_mismatch(arr[0]);
               }
               else
               {
                    string name=arr[1];
                    symboltable.Look_Up(name);
               }
            }
            else if(arr[0]=="D")
            {
                if(ind!=2)
               {
                cout<<"    Number of parameters mismatch for the command "<<arr[0]<<endl;
                ScopeTable::write_mismatch(arr[0]);
               }
               else
               {

                    string name=arr[1];
                    symboltable.Remove(name);
               }
            }
            else if(arr[0]=="P")
            {
                if(ind!=2)
                {
                 cout<<"    Number of parameters mismatch for the  command "<<arr[0]<<endl;
                 ScopeTable::write_mismatch(arr[0]);
                }
                else
                {
                    if(arr[1]=="A")
                    {
                        symboltable.Print_All_Scope_Table();
                    }
                    else if(arr[1]=="C")
                    {
                        symboltable.Print_Current_Scope_Table();
                    }
                }
            }
            else if(arr[0]=="S")
            {
                if(ind!=1)
                {
                 cout<<"    Number of parameters mismatch for the  command "<<arr[0]<<endl;
                 ScopeTable::write_mismatch(arr[0]);
                }
                else
                {
                    scope_table++;
                    symboltable.Enter_Scope(scope_table);//we will create a new scope table and make the current scope table as a parent scope table of the newly one that is why we pass the scope_table parameter in the function
                }
            }
            else if(arr[0]=="E")
            {
                if(ind!=1)
                {
                 cout<<"    Number of parameters mismatch for the  command "<<arr[0]<<endl;
                 ScopeTable::write_mismatch(arr[0]);
                }
                else
                {
                    symboltable.Exit_Scope();
                }
            }
            else if(arr[0]=="Q")
            {
                if(ind!=1)
                {
                 cout<<"    Number of parameters mismatch for the  command "<<arr[0]<<endl;
                 ScopeTable::write_mismatch(arr[0]);
                }
                else
                {
                    symboltable.Exit_All_Scope_Table();
                }
            }
		}
	}
    MyReadFile.close();    
    ScopeTable::file_close();
    return 0;
}