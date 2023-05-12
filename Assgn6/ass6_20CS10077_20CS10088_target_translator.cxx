#include "ass6_20CS10077_20CS10088_translator.h"
#include <bits/stdc++.h>
using namespace std;

void target_code_generator(ofstream& dot_s_file);
void global_printer(ofstream& dot_s_file);
void Str_display(ofstream& dot_s_file);
void prologue_part_function(int memBind, ofstream& dot_s_file);
void label_assign();
void TAC_code(quad q, ofstream& dot_s_file);



vector<string> string_storage;
map<int, string> labels;
stack<pair<string, int>> parameters;
int label_iterator_cnt = 0;
string present_function = "";
string file_name;


extern symbol_table global_symbol_table;
extern symbol_table* present_symbol_table;
extern quad_array quadList;


// printing the main function part and calling all the other labels and functions
void target_code_generator(ofstream& dot_s_file) {
    global_printer(dot_s_file);
    Str_display(dot_s_file);
    symbol_table* currFuncTable = NULL;
    symbol* currFunc = NULL;
    label_assign();

    for(int i = 0; i < (int)quadList.quads.size(); i++) {
        // // print the quad as a comment in the assembly file
        // dot_s_file << "# " << quadList.quads[i].print() << endl;
        
        
        if(labels.count(i))
            dot_s_file << labels[i] << ":" << endl;

        // Necessary tasks for a function
        if(quadList.quads[i].op == FUNC_BEG) {
            i++;
            if(quadList.quads[i].op != FUNC_END)
                i--;
            else
                continue;
            currFunc = global_symbol_table.searchGlobal(quadList.quads[i].result);
            currFuncTable = currFunc->nestedTable;
            int takingParam = 1, memBind = 16;
            present_symbol_table = currFuncTable;
            for(int j = 0; j < (int)currFuncTable->symbols.size(); j++) {
                if(currFuncTable->symbols[j]->name == "RETVAL") {
                    takingParam = 0;
                    memBind = 0;
                    if(currFuncTable->symbols.size() > j + 1)
                        memBind = -currFuncTable->symbols[j + 1]->size;
                }
                else {
                    if(!takingParam) {
                        currFuncTable->symbols[j]->offset = memBind;
                        if(currFuncTable->symbols.size() > j + 1)
                            memBind -= currFuncTable->symbols[j + 1]->size;
                    }
                    else {
                        currFuncTable->symbols[j]->offset = memBind;
                        memBind += 8;
                    }
                }
            }
            if(memBind >= 0)
                memBind = 0;
            else
                memBind *= -1;
            present_function = quadList.quads[i].result;
            prologue_part_function(memBind, dot_s_file);
        }

        // Function epilogue (while leaving a function)
        else if(quadList.quads[i].op == FUNC_END) {
            present_symbol_table = &global_symbol_table;
            present_function = "";
            dot_s_file << "\tleave" << endl;
            dot_s_file << "\tret" << endl;
            dot_s_file << "\t.size\t" << quadList.quads[i].result << ", .-" << quadList.quads[i].result << endl;
        }

        if(present_function != "")
            TAC_code(quadList.quads[i], dot_s_file);
    }
}

// first the global information to the assembly file
void global_printer(ofstream& dot_s_file) {
    for(vector<symbol*>::iterator it = global_symbol_table.symbols.begin(); it != global_symbol_table.symbols.end(); it++) {
        symbol* sym = *it;
        if(sym->type.type == data_type_char && sym->name[0] != 't') {
            if(sym->initVal != NULL) {
                dot_s_file << "\t.globl\t" << sym->name << endl;
                dot_s_file << "\t.data" << endl;
                dot_s_file << "\t.type\t" << sym->name << ", @object" << endl;
                dot_s_file << "\t.size\t" << sym->name << ", 1" << endl;
                dot_s_file << sym->name << ":" << endl;
                dot_s_file << "\t.byte\t" << sym->initVal->c << endl;
            }
            else
                dot_s_file << "\t.comm\t" << sym->name << ",1,1" << endl;
        }
        else if(sym->type.type == data_type_integer && sym->name[0] != 't') {
            if(sym->initVal != NULL) {
                dot_s_file << "\t.globl\t" << sym->name << endl;
                dot_s_file << "\t.data" << endl;
                dot_s_file << "\t.align\t4" << endl;
                dot_s_file << "\t.type\t" << sym->name << ", @object" << endl;
                dot_s_file << "\t.size\t" << sym->name << ", 4" << endl;
                dot_s_file << sym->name << ":" << endl;
                dot_s_file << "\t.long\t" << sym->initVal->i << endl;
            }
            else
                dot_s_file << "\t.comm\t" << sym->name << ",4,4" << endl;
        }
    }
}

// all the strings wriiten at the top
void Str_display(ofstream& dot_s_file) {
    dot_s_file << ".section\t.rodata" << endl;
    int i = 0;
    for(vector<string>::iterator it = string_storage.begin(); it != string_storage.end(); it++) {
        dot_s_file << ".LC" << i++ << ":" << endl;
        dot_s_file << "\t.string " << *it << endl;
    }
}

// labels for the functions
void label_assign() {
    int i = 0;
    for(vector<quad>::iterator it = quadList.quads.begin(); it != quadList.quads.end(); it++) {
        if(it->op == GOTO || (it->op >= GOTO_EQ && it->op <= IF_FALSE_GOTO)) {
            int target = atoi((it->result.c_str()));
            if(!labels.count(target)) {
                string labelName = ".L" + to_string(label_iterator_cnt++);
                labels[target] = labelName;
            }
            it->result = labels[target];
        }
    }
}

// the part before the calling of the function, moving of rsp to rbp ,memory storage,etc.
void prologue_part_function(int memBind, ofstream& dot_s_file) {
    int width = 16;
    dot_s_file << endl << "\t.text" << endl;
    dot_s_file << "\t.globl\t" << present_function << endl;
    dot_s_file << "\t.type\t" << present_function << ", @function" << endl;
    dot_s_file << present_function << ":" << endl;
    dot_s_file << "\tpushq\t" << "%rbp" << endl;
    dot_s_file << "\tmovq\t" << "%rsp, %rbp" << endl;
    dot_s_file << "\tsubq\t$" << (memBind / width + 1) * width << ", %rsp" << endl;
}

//input a quad, and using it writing the assembler code
void TAC_code(quad q, ofstream& dot_s_file) {
    string strLabel = q.result;
    bool hasStrLabel = (q.result[0] == '.' && q.result[1] == 'L' && q.result[2] == 'C');
    string toPrint1 = "", toPrint2 = "", toPrintRes = "";
    int off1 = 0, off2 = 0, offRes = 0;

    symbol* loc1 = present_symbol_table->lookup(q.arg1);
    symbol* loc2 = present_symbol_table->lookup(q.arg2);
    symbol* loc3 = present_symbol_table->lookup(q.result);
    symbol* glb1 = global_symbol_table.searchGlobal(q.arg1);
    symbol* glb2 = global_symbol_table.searchGlobal(q.arg2);
    symbol* glb3 = global_symbol_table.searchGlobal(q.result);

    if(present_symbol_table != &global_symbol_table) {
        if(glb1 == NULL)
            off1 = loc1->offset;
        if(glb2 == NULL)
            off2 = loc2->offset;
        if(glb3 == NULL)
            offRes = loc3->offset;

        if(q.arg1[0] < '0' || q.arg1[0] > '9') {
            if(glb1 != NULL)
                toPrint1 = q.arg1 + "(%rip)";
            else
                toPrint1 = to_string(off1) + "(%rbp)";
        }
        if(q.arg2[0] < '0' || q.arg2[0] > '9') {
            if(glb2 != NULL)
                toPrint2 = q.arg2 + "(%rip)";
            else
                toPrint2 = to_string(off2) + "(%rbp)";
        }
        if(q.result[0] < '0' || q.result[0] > '9') {
            if(glb3 != NULL)
                toPrintRes = q.result + "(%rip)";
            else
                toPrintRes = to_string(offRes) + "(%rbp)";
        }
    }
    else {
        toPrint1 = q.arg1;
        toPrint2 = q.arg2;
        toPrintRes = q.result;
    }

    if(hasStrLabel)
        toPrintRes = strLabel;

    if(q.op == ASSIGN) {
        if(q.result[0] != 't' || loc3->type.type == data_type_integer || loc3->type.type == data_type_pointer) {
            if(loc3->type.type != data_type_pointer) {
                if(q.arg1[0] < '0' || q.arg1[0] > '9')
                {
                    dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
                    dot_s_file << "\tmovl\t%eax, " << toPrintRes << endl; 
                }
                else
                    dot_s_file << "\tmovl\t$" << q.arg1 << ", " << toPrintRes << endl;
            }
            else {
                dot_s_file << "\tmovq\t" << toPrint1 << ", %rax" << endl;
                dot_s_file << "\tmovq\t%rax, " << toPrintRes << endl; 
            }
        }
        else {
            int temp = q.arg1[0];
            dot_s_file << "\tmovb\t$" << temp << ", " << toPrintRes << endl;
        }
    }
    else if(q.op == U_MINUS) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tnegl\t%eax" << endl;
        dot_s_file << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if(q.op == ADD) {
        if(q.arg1[0] > '0' && q.arg1[0] <= '9')
            dot_s_file << "\tmovl\t$" << q.arg1 << ", %eax" << endl;
        else
            dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl; 
        if(q.arg2[0] > '0' && q.arg2[0] <= '9')
            dot_s_file << "\tmovl\t$" << q.arg2 << ", %edx" << endl;
        else
            dot_s_file << "\tmovl\t" << toPrint2 << ", %edx" << endl; 
        dot_s_file << "\taddl\t%edx, %eax" << endl;
        dot_s_file << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if(q.op == SUB) {
        if(q.arg1[0] > '0' && q.arg1[0] <= '9')
            dot_s_file << "\tmovl\t$" << q.arg1 << ", %edx" << endl;
        else
            dot_s_file << "\tmovl\t" << toPrint1 << ", %edx" << endl; 
        if(q.arg2[0]>'0' && q.arg2[0]<='9')
            dot_s_file << "\tmovl\t$" << q.arg2 << ", %eax" << endl;
        else
            dot_s_file << "\tmovl\t" << toPrint2 << ", %eax" << endl; 
        dot_s_file << "\tsubl\t%eax, %edx" << endl;
        dot_s_file << "\tmovl\t%edx, %eax" << endl;
        dot_s_file << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if(q.op == MULT) {
        if(q.arg1[0] > '0' && q.arg1[0] <= '9')
            dot_s_file << "\tmovl\t$" << q.arg1 << ", %eax" << endl;
        else
            dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl; 
        dot_s_file << "\timull\t";
        if(q.arg2[0] > '0' && q.arg2[0] <= '9')
            dot_s_file << "$" << q.arg2 << ", %eax" << endl;
        else
            dot_s_file << toPrint2 << ", %eax" << endl;
        dot_s_file << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if(q.op == DIV) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tcltd\n\tidivl\t" << toPrint2 << endl;
        dot_s_file << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if(q.op == MOD) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tcltd\n\tidivl\t" << toPrint2 << endl;
        dot_s_file << "\tmovl\t%edx, " << toPrintRes << endl;
    }
    else if(q.op == GOTO)
        dot_s_file << "\tjmp\t" << q.result << endl;
    else if(q.op == GOTO_LT) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        dot_s_file << "\tjge\t.L" << label_iterator_cnt << endl;
        dot_s_file << "\tjmp\t" << q.result << endl;
        dot_s_file << ".L" << label_iterator_cnt++ << ":" << endl;
    }
    else if(q.op == GOTO_GT) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        dot_s_file << "\tjle\t.L" << label_iterator_cnt << endl;
        dot_s_file << "\tjmp\t" << q.result << endl;
        dot_s_file << ".L" << label_iterator_cnt++ << ":" << endl;
    }
    else if(q.op == GOTO_GTE) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        dot_s_file << "\tjl\t.L" << label_iterator_cnt << endl;
        dot_s_file << "\tjmp\t" << q.result << endl;
        dot_s_file << ".L" << label_iterator_cnt++ << ":" << endl;
    }
    else if(q.op == GOTO_LTE) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        dot_s_file << "\tjg\t.L" << label_iterator_cnt << endl;
        dot_s_file << "\tjmp\t" << q.result << endl;
        dot_s_file << ".L" << label_iterator_cnt++ << ":" << endl;
    }
    else if(q.op == GOTO_GTE) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        dot_s_file << "\tjl\t.L" << label_iterator_cnt << endl;
        dot_s_file << "\tjmp\t" << q.result << endl;
        dot_s_file << ".L" << label_iterator_cnt++ << ":" << endl;
    }
    else if(q.op == GOTO_EQ) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        if(q.arg2[0] >= '0' && q.arg2[0] <= '9')
            dot_s_file << "\tcmpl\t$" << q.arg2 << ", %eax" << endl;
        else
            dot_s_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        dot_s_file << "\tjne\t.L" << label_iterator_cnt << endl;
        dot_s_file << "\tjmp\t" << q.result << endl;
        dot_s_file << ".L" << label_iterator_cnt++ << ":" << endl;
    }
    else if(q.op == GOTO_NEQ) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        dot_s_file << "\tje\t.L" << label_iterator_cnt << endl;
        dot_s_file << "\tjmp\t" << q.result << endl;
        dot_s_file << ".L" << label_iterator_cnt++ << ":" << endl;
    }
    else if(q.op == IF_GOTO) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tcmpl\t$0" << ", %eax" << endl;
        dot_s_file << "\tje\t.L" << label_iterator_cnt << endl;
        dot_s_file << "\tjmp\t" << q.result << endl;
        dot_s_file << ".L" << label_iterator_cnt++ << ":" << endl;
    }
    else if(q.op == IF_FALSE_GOTO) {
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tcmpl\t$0" << ", %eax" << endl;
        dot_s_file << "\tjne\t.L" << label_iterator_cnt << endl;
        dot_s_file << "\tjmp\t" << q.result << endl;
        dot_s_file << ".L" << label_iterator_cnt++ << ":" << endl;
    }
    else if(q.op == ARR_IDX_ARG) {
        dot_s_file << "\tmovl\t" << toPrint2 << ", %edx" << endl;
        dot_s_file << "cltq" << endl;
        if(off1 < 0) {
            dot_s_file << "\tmovl\t" << off1 << "(%rbp,%rdx,1), %eax" << endl;
            dot_s_file << "\tmovl\t%eax, " << toPrintRes << endl;
        }
        else {
            dot_s_file << "\tmovq\t" << off1 << "(%rbp), %rdi" << endl;
            dot_s_file << "\taddq\t%rdi, %rdx" << endl;
            dot_s_file << "\tmovq\t(%rdx) ,%rax" << endl;
            dot_s_file << "\tmovq\t%rax, " << toPrintRes << endl;
        }
    }
    else if(q.op == ARR_IDX_RES) {
        dot_s_file << "\tmovl\t" << toPrint2 << ", %edx" << endl;
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "cltq" << endl;
        if(offRes > 0) {
            dot_s_file << "\tmovq\t" << offRes << "(%rbp), %rdi" << endl;
            dot_s_file << "\taddq\t%rdi, %rdx" << endl;
            dot_s_file << "\tmovl\t%eax, (%rdx)" << endl;
        }
        else
            dot_s_file << "\tmovl\t%eax, " << offRes << "(%rbp,%rdx,1)" << endl;
    }
    else if(q.op == REFERENCE) {
        if(off1 < 0) {
            dot_s_file << "\tleaq\t" << toPrint1 << ", %rax" << endl;
            dot_s_file << "\tmovq\t%rax, " << toPrintRes << endl;
        }
        else {
            dot_s_file << "\tmovq\t" << toPrint1 << ", %rax" << endl;
            dot_s_file << "\tmovq\t%rax, " << toPrintRes << endl;
        }
    }
    else if(q.op == DEREFERENCE) {
        dot_s_file << "\tmovq\t" << toPrint1 << ", %rax" << endl;
        dot_s_file << "\tmovq\t(%rax), %rdx" << endl;
        dot_s_file << "\tmovq\t%rdx, " << toPrintRes << endl;
    }
    else if(q.op == L_DEREF) {
        dot_s_file << "\tmovq\t" << toPrintRes << ", %rdx" << endl;
        dot_s_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        dot_s_file << "\tmovl\t%eax, (%rdx)" << endl;
    }
    else if(q.op == PARAM) {
        int paramSize;
        data_type t;
        if(glb3 != NULL)
            t = glb3->type.type;
        else
            t = loc3->type.type;
        if(t == data_type_integer)
            paramSize = size_of_integer;
        else if(t == data_type_char)
            paramSize = size_of_character;
        else
            paramSize = size_of_pointer;
        stringstream ss;
        if(q.result[0] == '.')
            ss << "\tmovq\t$" << toPrintRes << ", %rax" <<endl;
        else if(q.result[0] >= '0' && q.result[0] <= '9')
            ss << "\tmovq\t$" << q.result << ", %rax" <<endl;
        else {
            if(loc3->type.type != data_type_array) {
                if(loc3->type.type != data_type_pointer)
                    ss << "\tmovq\t" << toPrintRes << ", %rax" <<endl;
                else if(loc3 == NULL)
                    ss << "\tleaq\t" << toPrintRes << ", %rax" <<endl;
                else
                    ss << "\tmovq\t" << toPrintRes << ", %rax" <<endl;
            }
            else {
                if(offRes < 0)
                    ss << "\tleaq\t" << toPrintRes << ", %rax" <<endl;
                else {
                    ss << "\tmovq\t" << offRes << "(%rbp), %rdi" <<endl;
                    ss << "\tmovq\t%rdi, %rax" <<endl;
                }
            }
        }
        parameters.push(make_pair(ss.str(), paramSize));
    }
    else if(q.op == CALL) {
        int numParams = atoi(q.arg1.c_str());
        int totalSize = 0, k = 0;

        // allocating registers for parameters, registers depends on the count of the parameters
        if(numParams > 6) {
            for(int i = 0; i < numParams - 6; i++) {
                string s = parameters.top().first;
                dot_s_file << s << "\tpushq\t%rax" << endl;
                totalSize += parameters.top().second;
                parameters.pop();
            }
            dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r9d" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r8d" << endl;
            totalSize += parameters.top().second;				
            parameters.pop();
            dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rcx" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdx" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rsi" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdi" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
        }
        else {
            while(!parameters.empty()) {
                if(parameters.size() == 6) {
                    dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r9d" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if(parameters.size() == 5) {
                    dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r8d" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if(parameters.size() == 4) {
                    dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rcx" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if(parameters.size() == 3) {
                    dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdx" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if(parameters.size() == 2) {
                    dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rsi" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if(parameters.size() == 1) {
                    dot_s_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdi" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
            }
        }
        dot_s_file << "\tcall\t" << q.result << endl;
        if(q.arg2 != "")
            dot_s_file << "\tmovq\t%rax, " << toPrint2 << endl;
        dot_s_file << "\taddq\t$" << totalSize << ", %rsp" << endl;
    }
    else if(q.op == RETURN) {
        if(q.result != "")
            dot_s_file << "\tmovq\t" << toPrintRes << ", %rax" << endl;
        dot_s_file << "\tleave" << endl;
        dot_s_file << "\tret" << endl;
    }

}



int main(int argc, char* argv[]) {
    present_symbol_table = &global_symbol_table;
    yyparse();

    file_name = "ass6_20CS10077_20CS10088_" + string(argv[argc - 1]) + ".s";
    ofstream dot_s_file;
    dot_s_file.open(file_name);

    quadList.print();               // Print the three address quads

    present_symbol_table->print("present_symbol_table.global");         // Print the symbol tables

    present_symbol_table = &global_symbol_table;

    target_code_generator(dot_s_file);      // Generate the target assembly code

    dot_s_file.close();

    return 0;
}