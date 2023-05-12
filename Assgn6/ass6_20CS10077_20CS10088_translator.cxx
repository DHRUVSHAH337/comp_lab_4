#include "ass6_20CS10077_20CS10088_translator.h"
#include <iomanip>
using namespace std;

// Initialize the nextinstr to 0
int nextinstr = 0;

// Intiailize the static variable
int symbol_table::tempCount = 0;

quad_array quadList;        // stores the entire quads
symbol_table global_symbol_table;      // stores the global symbol table
symbol_table* present_symbol_table;           // present symbol table


// checking types and returning it
string checkType(symbol_type t) {
    if(t.type == data_type_void)
        return "void";
    else if(t.type == data_type_char)
        return "char";
    else if(t.type == data_type_integer)
        return "int";
    else if(t.type == data_type_float)
        return "float";
    else if(t.type == data_type_function)
        return "function";

    else if(t.type == data_type_pointer) {        
        string tp = "";
        if(t.nextType == data_type_char)
            tp += "char";
        else if(t.nextType == data_type_integer)
            tp += "int";
        else if(t.nextType == data_type_float)
            tp += "float";
        tp += string(t.pointers, '*');
        return tp;
    }

    else if(t.type == data_type_array) {          
        string tp = "";
        if(t.nextType == data_type_char)
            tp += "char";
        else if(t.nextType == data_type_integer)
            tp += "int";
        else if(t.nextType == data_type_float)
            tp += "float";
        vector<int> dim = t.dimension_vector;
        for(int i = 0; i < (int)dim.size(); i++) {
            if(dim[i])
                tp += "[" + to_string(dim[i]) + "]";
            else
                tp += "[]";
        }
        if((int)dim.size() == 0)
            tp += "[]";
        return tp;
    }

    else
        return "unknown";
}

// converting the types to make the expressions have same types
void convertToType(expression* arg, expression* res, data_type toType) {
    if(res->type == toType)
        return;

    if(res->type == data_type_float) {
        if(toType == data_type_integer)
            emit(arg->loc, res->loc, "", FtoI);
        else if(toType == data_type_char)
            emit(arg->loc, res->loc, "", FtoC);
    }
    else if(res->type == data_type_integer) {
        if(toType == data_type_float)
            emit(arg->loc, res->loc, "", ItoF);
        else if(toType == data_type_char)
            emit(arg->loc, res->loc, "", ItoC);
    }
    else if(res->type == data_type_char) {
        if(toType == data_type_float)
            emit(arg->loc, res->loc, "", CtoF);
        else if(toType == data_type_integer)
            emit(arg->loc, res->loc, "", CtoI);
    }
}

void convertToType(string t, data_type to, string f, data_type from) {
    if(to == from)
        return;
    
    if(from == data_type_float) {
        if(to == data_type_integer)
            emit(t, f, "", FtoI);
        else if(to == data_type_char)
            emit(t, f, "", FtoC);
    }
    else if(from == data_type_integer) {
        if(to == data_type_float)
            emit(t, f, "", ItoF);
        else if(to == data_type_char)
            emit(t, f, "", ItoC);
    }
    else if(from == data_type_char) {
        if(to == data_type_float)
            emit(t, f, "", CtoF);
        else if(to == data_type_integer)
            emit(t, f, "", CtoI);
    }
}


void convertIntToBool(expression* expr) {   // converting int to boolean expressions
    if(expr->type != data_type_bool) {
        expr->type = data_type_bool;
        expr->falselist = makelist(nextinstr);    // Add falselist for boolean expressions
        emit("", expr->loc, "", IF_FALSE_GOTO);
        expr->truelist = makelist(nextinstr);     // Add truelist for boolean expressions
        emit("", "", "", GOTO);
    }
}


// quad constructor
quad::quad(string res_, string arg1_, string arg2_, opcode op_): op(op_), arg1(arg1_), arg2(arg2_), result(res_) {}

// printing the quad
string quad::print() {
    string out = "";
    if(op >= ADD && op <= BW_XOR) {                 // Binary operators
        out += (result + " = " + arg1 + " ");
        switch(op) {
            case ADD: out += "+"; break;
            case SUB: out += "-"; break;
            case MULT: out += "*"; break;
            case DIV: out += "/"; break;
            case MOD: out += "%"; break;
            case SL: out += "<<"; break;
            case SR: out += ">>"; break;
            case BW_AND: out += "&"; break;
            case BW_OR: out += "|"; break;
            case BW_XOR: out += "^"; break;
        }
        out += (" " + arg2);
    }
    else if(op >= BW_U_NOT && op <= U_NEG) {        // Unary operators
        out += (result + " = ");
        switch(op) {
            case BW_U_NOT: out += "~"; break;
            case U_PLUS: out += "+"; break;
            case U_MINUS: out += "-"; break;
            case REFERENCE: out += "&"; break;
            case DEREFERENCE: out += "*"; break;
            case U_NEG: out += "!"; break;
        }
        out += arg1;
    }
    else if(op >= GOTO_EQ && op <= IF_FALSE_GOTO) { // Conditional operators
        out += ("if " + arg1 + " ");
        switch(op) {
            case GOTO_EQ: out += "=="; break;
            case GOTO_NEQ: out += "!="; break;
            case GOTO_GT: out += ">"; break;
            case GOTO_GTE: out += ">="; break;
            case GOTO_LT: out += "<"; break;
            case GOTO_LTE: out += "<="; break;
            case IF_GOTO: out += "!= 0"; break;
            case IF_FALSE_GOTO: out += "== 0"; break;
        }
        out += (" " + arg2 + " goto " + result);
    }
    else if(op >= CtoI && op <= CtoF) {             // Type Conversion functions
        out += (result + " = ");
        switch(op) {
            case CtoI: out += "CharToInt"; break;
            case ItoC: out += "IntToChar"; break;
            case FtoI: out += "FloatToInt"; break;
            case ItoF: out += "IntToFloat"; break;
            case FtoC: out += "FloatToChar"; break;
            case CtoF: out += "CharToFloat"; break;
        }
        out += ("(" + arg1 + ")");
    }

    else if(op == ASSIGN)                       // Assignment operator
        out += (result + " = " + arg1);
    else if(op == GOTO)                         // Goto
        out += ("goto " + result);
    else if(op == RETURN)                       // Return from a function
        out += ("return " + result);
    else if(op == PARAM)                        // Parameters for a function
        out += ("param " + result);
    else if(op == CALL) {                       // Call a function
        if(arg2.size() > 0)
            out += (arg2 + " = ");
        out += ("call " + result + ", " + arg1);
    }
    else if(op == ARR_IDX_ARG)                  // Array indexing
        out += (result + " = " + arg1 + "[" + arg2 + "]");
    else if(op == ARR_IDX_RES)                  // Array indexing
        out += (result + "[" + arg2 + "] = " + arg1);
    else if(op == FUNC_BEG)                     // Function begin
        out += (result + ": ");
    else if(op == FUNC_END) {                   // Function end
        out += ("function " + result + " ends");
    }
    else if(op == L_DEREF)                      // Dereference
        out += ("*" + result + " = " + arg1);

    return out;
}

// quad_array print
void quad_array::print() {
    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl;
    cout << "THREE ADDRESS CODE (TAC):" << endl;
    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl;

    // Print each of the quads one by one
    for(int i = 0; i < (int)quads.size(); i++) {
        if(quads[i].op != FUNC_BEG && quads[i].op != FUNC_END)
            cout << left << setw(4) << i << ":    ";
        else if(quads[i].op == FUNC_BEG)
            cout << endl << left << setw(4) << i << ": ";
        else if(quads[i].op == FUNC_END)
            cout << left << setw(4) << i << ": ";
        cout << quads[i].print() << endl;
    }
    cout << endl;
}

// expression constructor
expression::expression(): fold(0), folder(NULL) {}

//emit functions and its overloads
void emit(string result, string arg1, string arg2, opcode op) {
    quad q(result, arg1, arg2, op);
    quadList.quads.push_back(q);
    nextinstr++;
}

void emit(string result, int constant, opcode op) {
    quad q(result, to_string(constant), "", op);
    quadList.quads.push_back(q);
    nextinstr++;
}

void emit(string result, char constant, opcode op) {
    quad q(result, to_string(constant), "", op);
    quadList.quads.push_back(q);
    nextinstr++;
}

void emit(string result, float constant, opcode op) {
    quad q(result, to_string(constant), "", op);
    quadList.quads.push_back(q);
    nextinstr++;
}

list<int> makelist(int i) {
    list<int> l(1, i);      // creating the list
    return l;
}

list<int> merge(list<int> list1, list<int> list2) {
    list1.merge(list2);// merging two lists
    return list1;
}


void backpatch(list<int> l, int address) {
    string str = to_string(address);
    for(list<int>::iterator it = l.begin(); it != l.end(); it++) {  // backpatching at all addresses of the list
        quadList.quads[*it].result = str;
    }
}

// sizeof function
int sizeOfType(data_type t) {
    if(t == data_type_void)
        return size_of_void;
    else if(t == data_type_char)
        return size_of_character;
    else if(t == data_type_integer)
        return size_of_integer;
    else if(t == data_type_pointer)
        return size_of_pointer;
    else if(t == data_type_float)
        return size_of_float;
    else if(t == data_type_function)
        return size_of_function;
    else
        return 0;
}

// getting the initial value
string getInitVal(symbol* sym) {
    if(sym->initVal != NULL) {
        if(sym->type.type == data_type_integer)
            return to_string(sym->initVal->i);
        else if(sym->type.type == data_type_char)
            return to_string(sym->initVal->c);
        else if(sym->type.type == data_type_float)
            return to_string(sym->initVal->f);
        else
            return "-";
    }
    else
        return "-";
}

// constructor of the symbol
symbol::symbol(): nestedTable(NULL) {}

// constructor of symbol_table
symbol_table::symbol_table(): offset(0) {}


symbol* symbol_table::lookup(string name, data_type t, int pc) {    // searching function for the symbol in the symbol table
    if(table.count(name) == 0) {
        symbol* sym = new symbol();
        sym->name = name;
        sym->type.type = t;
        sym->offset = offset;
        sym->initVal = NULL;

        if(pc == 0) {
            sym->size = sizeOfType(t);
            offset += sym->size;
        }
        else {
            sym->size = size_of_pointer;
            sym->type.nextType = t;
            sym->type.pointers = pc;
            sym->type.type = data_type_array;
        }
        symbols.push_back(sym);
        table[name] = sym;
    }
    return table[name];
}

// searching the symbol using the map
symbol* symbol_table::searchGlobal(string name) {
    return (table.count(name) ? table[name] : NULL);
}

// generating the temporary variables
string symbol_table::gentemp(data_type t) {
    string tempName = "t" + to_string(symbol_table::tempCount++);
    
    
    symbol* sym = new symbol();
    sym->name = tempName;
    sym->size = sizeOfType(t);
    sym->offset = offset;
    sym->type.type = t;
    sym->initVal = NULL;

    offset += sym->size;
    symbols.push_back(sym);
    table[tempName] = sym;  

    return tempName;
}

// printing the symbol table
void symbol_table::print(string tableName) {
    for(int i = 0; i < 120; i++) {
        cout << '-';
    }
    cout << endl;
    cout << "Symbol Table: " << setfill(' ') << left << setw(50) << tableName << endl;
    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl;

    cout << setfill(' ') << left << setw(25) <<  "Name";
    cout << left << setw(25) << "Type";
    cout << left << setw(20) << "Initial Value";
    cout << left << setw(15) << "Size";
    cout << left << setw(15) << "Offset";
    cout << left << "Nested" << endl;

    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl;

    vector<pair<string, symbol_table*>> tableList;

    for(int i = 0; i < (int)symbols.size(); i++) {
        symbol* sym = symbols[i];
        cout << left << setw(25) << sym->name;
        cout << left << setw(25) << checkType(sym->type);
        cout << left << setw(20) << getInitVal(sym);
        cout << left << setw(15) << sym->size;
        cout << left << setw(15) << sym->offset;
        cout << left;

        if(sym->nestedTable != NULL) {
            string nestedTableName = tableName + "." + sym->name;
            cout << nestedTableName << endl;
            tableList.push_back({nestedTableName, sym->nestedTable});
        }
        else
            cout << "NULL" << endl;
    }

    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl << endl;
    for(vector<pair<string, symbol_table*>>::iterator it = tableList.begin(); it != tableList.end(); it++) {
        pair<string, symbol_table*> p = (*it);
        p.second->print(p.first);
    }

}

// overloads of setInitVal method of symbol_value class
void symbol_value::setInitVal(int val) {
    c = f = i = val;
    p = NULL;
}

void symbol_value::setInitVal(char val) {
    c = f = i = val;
    p = NULL;
}

void symbol_value::setInitVal(float val) {
    c = f = i = val;
    p = NULL;
}