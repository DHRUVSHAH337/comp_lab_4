int printStr(char *s);
int readInt(int *eP);
int printInt(int n);

int main()
{  
    int i,j,k,l,n;    

    printStr("enter the range = \n");    
    readInt(&n);    
    // printInt(n);
    for(i=1;i<=n;i++)    
    {    
        for(j=1;j<=n-i;j++)    
        {    
            printStr(" ");    
        }    
        for(k=1;k<=i;k++)    
        {    
            printInt(k);    
        }    
        for(l=i-1;l>=1;l--)    
        {    
            printInt(l);    
        }    
        printStr("\n");    
    }    
    return 0;  
} 