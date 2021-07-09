#include <stdint.h>
#define bool unsigned short
#define true 1
#define false 0


void toupper(char* str) {
    int i=0;
    while(str[i]) {
        if (str[i] >= 'a' && str[i] <= 'z')  
        str[i] = str[i]-'a'+'A';
        i++;
    }
}


void tolower(char* str) {
    int i=0;
    while(str[i]) {
        if (str[i] >= 'A' && str[i] <= 'Z')  
        str[i] = str[i]-'A'+'a';
        i++;
    }
}


void my_reverse(char str[], int len)
{
	int start, end;
	char temp;
	for (start = 0, end = len - 1; start < end; start++, end--) {
		temp = *(str + start);
		*(str + start) = *(str + end);
		*(str + end) = temp;
	}
}


char* itoa_buf(int num, int base, char* str)
{
	int i = 0;
	bool isNegative = false;
	if (num == 0) {
		str[i] = '0';
		str[i + 1] = '\0';
		return str;
	}
	if (num < 0 && base == 10) {
		isNegative = true;
		num = -num;
	}
	while (num != 0) {
		int rem = num % base;
		str[i++] = (rem > 9) ? (rem - 10) + 'A' : rem + '0';
		num = num / base;
	}
	if (isNegative) {
		str[i++] = '-';
	}
	str[i] = '\0';
	my_reverse(str, i);
	return str;
}


int atoi(char *str) {
    int res = 0; 
    for (int i = 0; str[i] != '\0'; ++i) {
        res = res*10 + str[i] - '0'; 
    }
    return res; 
}


uint8_t bcd2decimal(uint8_t bcd)
{
    return ((bcd & 0xF0) >> 4) * 10 + (bcd & 0x0F);
}
