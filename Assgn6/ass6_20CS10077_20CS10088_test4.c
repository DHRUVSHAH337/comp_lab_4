int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int hcf(int n1, int n2) {
    int x;
    if (n2 != 0)
        {
            x=hcf(n2, n1 % n2);
        } 
    else
        {
            x=n1;
        }

        return x;
}

int main() {
    int n1, n2;
    printStr("Enter two positive integers: \n");
    readInt(&n1);
    readInt(&n2);
    printStr("G.C.D of ");
    printInt(n1);
    printStr(" and ");
    printInt(n2);
    printStr(" is ");
    printInt(hcf(n1,n2));//.", n1, n2, hcf(n1, n2));
    printStr("\n");
    return 0;
}

