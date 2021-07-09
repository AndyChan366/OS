
#include <stdint.h>
#define funi(a) fun( a, 10)
extern void printInPos(const char *msg, uint16_t len, uint8_t row, uint8_t col);
// extern void putchar(char c);
extern void putchar_c(char c, uint8_t color);
extern char getch();
enum bios_color {white_c=0x07};

//统计字符串长度 
uint16_t strlen(const char *str) {
    int count = 0;
    while (str[count++] != '\0');
    return count - 1; 
}

//字符串比较 
uint8_t strcmp(const char* str1, const char* str2) {
    int i = 0;
    while (1) {
        if(str1[i]=='\0' || str2[i]=='\0') { break; }
        if(str1[i] != str2[i]) { break; }
        ++i;
    }
    return str1[i] - str2[i];
}


void putchar(char c) {
    putchar_c(c, 0x07);
}

//打印 
void print(const char* str) {
    for(int i = 0, len = strlen(str); i < len; i++) {
        putchar(str[i]);
    }
}

//带颜色打印 
void print_c(const char* str, uint8_t color) {
    for(int i = 0, len = strlen(str); i < len; i++) {
        putchar_c(str[i], color);
    }
}


void readToBuf(char* buffer, uint16_t maxlen) {
    int i = 0;
    while(1) {
        char tempc = getch();
        if(!(tempc==0xD || tempc=='\b' || tempc>=32 && tempc<=127)) { 
		    continue; 
		} 
        if(i > 0 && i < maxlen-1) { 
            if(tempc == 0x0D) {
                break;  
            }
            else if(tempc == '\b') {  
                putchar('\b');
                putchar(' ');
                putchar('\b');
                --i;
            }
            else{
                putchar(tempc);   
                buffer[i] = tempc;
                ++i;
            }
        }
        else if(i >= maxlen-1) {  
            if(tempc == '\b') {  
                putchar('\b');
                putchar(' ');
                putchar('\b');
                --i;
            }
            else if(tempc == 0x0D) {
                break;  
            }
        }
        else if(i <= 0) {  
            if(tempc == 0x0D) {
                break;  
            }
            else if(tempc != '\b') {
                putchar(tempc); 
                buffer[i] = tempc;
                ++i;
            }
        }
    }
    putchar('\r'); putchar('\n');
    buffer[i] = '\0';  
}

//整型转字符 
const char* itoa(int val, int base) {
	if(val==0) return "0";
	static char buf[32] = {0};
	int i = 30;
	for(; val && i ; --i, val /= base) {
		buf[i] = "0123456789ABCDEF"[val % base];
    }
	return &buf[i+1];
}

//判断是否为数字 
uint8_t isnum(char c) {
    return c>='0' && c<='9';
}


void getFirstWord(const char* str, char* buf) {
    int i = 0;
    while(str[i] && str[i] != ' ') {
        buf[i] = str[i];
        i++;
    }
    buf[i] = '\0'; 
}


void getAfterFirstWord(const char* str, char* buf) {
    buf[0] = '\0';  
    int i = 0;
    while(str[i] && str[i] != ' ') {
        i++;
    }
    while(str[i] && str[i] == ' ') {
        i++;
    }
    int j = 0;
    while(str[i]) {
        buf[j++] = str[i++];
    }
    buf[j] = '\0';  
}
