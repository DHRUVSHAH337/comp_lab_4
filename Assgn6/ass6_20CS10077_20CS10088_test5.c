int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int multiplyNumbers(int n) {
    int x;
    if (n>=1)
    {
        x=n*multiplyNumbers(n-1);
    }
    else
    {
        x=1;
    }
        return x;
}

int main() {
    int n;
    printStr("Enter a positive integer: \n");
    readInt(&n);
    printStr("Factorial of ");
    printInt(n);
    printStr(" = ");
    printInt(multiplyNumbers(n));
    printStr("\n");
    return 0;
}

