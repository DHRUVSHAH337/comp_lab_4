// VIVEK JAISWAL
// ROLL NUMBER: 20CS10077
// SEMESTER: 5
// COMPILER ASSIGNMENT 2
// I/O LIBRARY

#include "myl.h"						// Include My Header File
#define BUFF_SIZE 100						// Declaring BUFF_SIZE
#define INT_MAX __INT32_MAX__					// DECLARING INT_MAX
#define INT_MIN (-INT_MAX - 1)				// DECLARING INT_MIN
#define FRACTIONAL_PRECISION 6				// DECLARING FRACTIONAL_PRECISION
int printStr(char *str){					// PRINT STRING
	int len;						// Find Length of the string
	for(len = 0;str[len] != '\0';len++);
	__asm__ __volatile__ (					// Assembly Code for Printing String
		"movl $1, %%eax \n\t"
		"movq $1, %%rdi \n\t"
		"syscall \n\t"
		:
		:"S"(str), "d"(len)
	);
	return len;						// Return number of characters it printed
}

int printInt(int n){						// PRINT INTEGER NUMBER
	char integer[BUFF_SIZE];				// Declaring character array ( string ) for storing integer in string
	int temp = n;						// Temporary Variable Declaration for storing n
	int len = 0;						// Declaring length of array
	if(temp < 0){						// Checking for negative number
		integer[len++] = '-';
		temp *= -1;
	}
	while(temp){						// Pushing every digits in reverse order
		integer[len++] = '0' + temp%10;
		temp /= 10;
	}
	
	if(len == 0)						// Checking for 0 case
		integer[len++] = '0';
	
	int left = 0;						// Left Pointer for reversing the digits
	if(integer[left] == '-')
		left++;
	int right = len - 1;					// Right Pointer for reversing the digit
	while(left < right){					// reversing the digit
		char temp2 = integer[left];
		integer[left] = integer[right];
		integer[right] = temp2;
		left++;
		right--;
	}
	integer[len] = '\0';					// last value as \0
	return printStr(integer);				// printing integer in the form of string
}

int printFlt(float f){						// PRINT FLOATING NUMBER
	char floating[BUFF_SIZE];				// Declaring character array ( string ) for storing integer in string
	int len = 0;						// Declaring length of array
	float temp = f;					// Temporary Variable Declaration for storing f
	if(temp < 0){						// Checking for negative number
		floating[len++] = '-';
		temp *= -1;
	}
	int integral = temp;					// Find integral part of floating point number
	while(integral){					// Pushing every digits of integral part in reverse order
		floating[len++] = '0' + integral%10;
		integral /= 10;
	}
	
	if(len == 0 || floating[len-1] == '-')		// Checking for 0 case
		floating[len++] = '0';
	
	int left = 0;						// Left Pointer for reversing the digits before decimal point
	if(floating[0] == '-')
		left++;
	int right = len - 1;					// Right Pointer for reversing the digit before decimal point
	while(left < right){					// reversing the digit before decimal point
		char temp2 = floating[left];
		floating[left] = floating[right];
		floating[right] = temp2;
		left++;
		right--;
	}
	floating[len++] = '.';					// Decimal point
	left = len;						// Left Pointer for reversing the digits after decimal point
	integral = temp;					// Integral part
	float fractional = temp - integral;			// Fractional Part
	for(int i = 0;i < FRACTIONAL_PRECISION;i++)		// Convert Fractional till Precision to integer
		fractional *= 10;
	int fraction = fractional;				// Integer type casting
	while(fraction){					// Pushing every digits of fraction part in reverse order
		floating[len++] = '0' + fraction%10;
		fraction /= 10;
	}
	right = len - 1;					// Right Pointer for reversing the digit after decimal point
	while(left < right){					// reversing the digit after decimal point
		char temp2 = floating[left];
		floating[left] = floating[right];
		floating[right] = temp2;
		left++;
		right--;
	}
	floating[len++] = '\0';				// last value as \0
	return printStr(floating);				// Printing the Floating string
	
}

int readInt(int *n){						// READ INT FUNCTION
	char integer[BUFF_SIZE];				// Maximum string size of buff size to store integer
	int len;						// Len of the integer string
	__asm__ __volatile__ (					// Taking input integer as string
		"movl $0, %%eax \n\t" 
		"movq $0, %%rdi \n\t"
		"syscall \n\t"
		: "=a"(len)
		:"S"(integer), "d"(BUFF_SIZE)
	);
	if(len <= 0)						// If no input then ERR
		return ERR;
	int i = 0;						// Loop variable
	int sign = 1;						// sign value, 1 for positive and -1 for negative, defaulting as positive
	if(integer[i] == '-'){					// if sign is negative
		sign = -1;
		i++;
	} else if(integer[i] == '+'){				// if sign is positive
		sign = 1;
		i++;
	}
	long num = 0;						// input number
	while(i < len && integer[i] != '\n' && integer[i] != '\0') {
		if(integer[i] < '0' || integer[i] > '9')	// if not a digit then ERR
			return ERR;
		int digit = integer[i] - '0';			// getting digit
		num = num * 10 + (sign * digit);		// num updating
		if(num > INT_MAX || num < INT_MIN)		// checking Range
			return ERR;
		i++;
	}
	int number = num;					// Type Casting to int
	*n = number;						// Storing in n
	return OK;						// OK
}

int readFlt(float *f){						// READ FLOAT FUNCTION
	char floating[BUFF_SIZE];				// Maximum string size of buff size to store floating number
	int len;						// Len of the floating string
	__asm__ __volatile__ (					// Taking input floating number as string
		"movl $0, %%eax \n\t" 
		"movq $0, %%rdi \n\t"
		"syscall \n\t"
		: "=a"(len)
		:"S"(floating), "d"(BUFF_SIZE)
	);
	if(len <= 0)						// If no input then ERR
		return ERR;
	int i = 0;						// Loop variable
	int sign = 1;						// sign value, 1 for positive and -1 for negative, defaulting as positive
	if(floating[i] == '-'){				// if sign is negative
		sign = -1;
		i++;
	} else if(floating[i] == '+'){			// if sign is positive
		sign = 1;
		i++;
	}
	float num = 0;						// input number
	while(i < len && floating[i] != '.' && floating[i] != 'e' && floating[i] != 'E' && floating[i] != '\n' && floating[i] != '\0') {		// loop till i found decimal point or exponential point or end of line
		if(floating[i] < '0' || floating[i] > '9')	// if not a digit then ERR
			return ERR;
		int digit = floating[i] - '0';		// getting digit
		num = num * 10 + (sign * digit);		// num updating
		i++;
	}
	if(floating[i] == '.'){				// if i found decimal point then
		i++;
		int div = 10;
		float decimal = 0.0;				// calculating decimal
		while(i < len && floating[i] != 'e' && floating[i] != 'E' && floating[i] != '\n' && floating[i] != '\0') {				// loop till i found exponential point or end of line
			if(floating[i] < '0' || floating[i] > '9')	// if not a digit then ERR
				return ERR;
			int digit = floating[i] - '0';	// getting digit
			decimal += digit*1.0/div;		// updating decimal
			div *= 10;
			i++;
		}
		num += (sign * decimal);			// adding decimal
	}
	if(floating[i] == 'e' || floating[i] == 'E'){		// if i found exponential point
		i++;
		int expSign = 1;				// exponential sign, 1 for positive and -1 for negative, defaulting as positive
		if(floating[i] == '-'){			// if exponential sign is negative
			expSign = -1;
			i++;
		} else if(floating[i] == '+'){		// if exponential sign is positive
			expSign = 1;
			i++;
		}
		int expValue = 0;				// exponential value
		while(i < len && floating[i] != '\n' && floating[i] != '\0') {									// loop till i found end of line
			if(floating[i] < '0' || floating[i] > '9')	// if not a digit then ERR
				return ERR;
			int digit = floating[i] - '0';		// getting digit
			expValue = expValue*10 + digit;		// updating expValue
			i++;
		}
		for(int i = 0;i < expValue;i++){			// multiplying expValue
			if(expSign == -1)
				num /= 10;
			else
				num *= 10;
		}
	}
	*f = num;							// Storing num if f
	return OK;							// OK
}