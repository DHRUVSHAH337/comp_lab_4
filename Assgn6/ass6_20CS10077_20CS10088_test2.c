int printStr(char *s);
int readInt(int *eP);
int printInt(int n);

int main()
{
    

    int array[100];
    
    int c;
    int n;
    printStr("\n\nEnter number of elements in array:\n");
    readInt(&n);

    printStr("\n\nEnter the elements\n");
    for(c = 0; c < n; c++)
        {
            int x;
            readInt(&x);
            array[c]=x;
        }
    
    printStr("\n\n the elements are\n");
    for(c = 0; c < n; c++)
        {
            printInt(array[c]);
            printStr(" ");
        }

    printStr("\n\nEnter the location where you want to delete element from:  ");
    int position;
    readInt(&position);

    if(position >= n+1)
        {
            printStr("\n\nDeletion not possible\n\n");
        }
    else 
    {
        for(c = position-1; c < n-1; c++)
        {
            array[c] = array[c+1];
        }
        n=n-1;
    }
        

    printStr("\n\nResultant array is: \n");
    for(c = 0; c < n; c++) 
        {
            int x=array[c];
            printInt(x);
            printStr(" ");

        }

    return 0;
}