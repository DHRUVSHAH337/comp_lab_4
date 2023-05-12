int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int checkPrime(int n)
{
    int i, isPrime = 1;

    // 0 and 1 are not prime numbers
    if (n == 0 || n == 1) 
    {
        isPrime = 0;
    }
    else {
        for(i = 2; i <n; ++i) 
        {
            int x=n%i;
            if(x == 0) 
            {
                isPrime = 0;
            }
        }
    }

    return isPrime;
}
int main() {
  int n, i, flag = 0;
  printStr("Enter a positive integer: ");
  readInt(&n);

  for (i = 2; i <= n; ++i) {
    // condition for i to be a prime number
    if (checkPrime(i) == 1) {
      // condition for n-i to be a prime number
      if (checkPrime(n - i) == 1) {
        printInt(i);
        printStr(" + ");
        printInt(n-i);
        printStr(" = ");
        printInt(n);
        printStr("\n");
        flag = 1;
      }
    }
  }

  if (flag == 0)
    printStr("Cannot be expressed as the sum of two prime numbers.");

  return 0;
}

