#include <stdint.h>
#include "stringio.h"
#define BUFLEN 16

extern void clearScreen();
extern void powerOff();
extern uint8_t getUsrProgNum();
extern char* getUsrProgName(uint16_t progid);
extern uint16_t getUsrProgSize(uint16_t progid);
extern uint8_t getUsrProgCylinder(uint16_t progid);
extern uint8_t getUsrProgHead(uint16_t progid);
extern uint8_t getUsrProgSector(uint16_t progid);
extern uint16_t getUsrProgAddrSeg(uint16_t progid);
extern uint16_t getUsrProgAddrOff(uint16_t progid);
extern void loadAndRun(uint8_t cylinder, uint8_t head, uint8_t sector, uint16_t len, uint16_t seg, uint16_t offset);
extern uint8_t getDateYear();
extern uint8_t getDateMonth();
extern uint8_t getDateDay();
extern uint8_t getDateHour();
extern uint8_t getDateMinute();
extern uint8_t getDateSecond();
extern uint8_t bcd2decimal(uint8_t bcd);
extern void loadProcessMem(uint8_t cylinder, uint8_t head, uint8_t sector, uint16_t len, uint16_t seg, uint16_t offset, int progid_to_run);
extern uint16_t switchHotwheel();
extern uint16_t timer_flag;

void Delay()
{
	int i = 0;
	int j = 0;
	for( i=0;i<10000;i++ )
		for( j=0;j<10000;j++ )
		{
			j++;
			j--;
		}
}


void startUp() {
    clearScreen();
    char* title = "ChenConghao 18340013";
    char* hint = "myOS loads successfully. Press ENTER to start!";
    printInPos(title, strlen(title), 7, 29);
    printInPos(hint, strlen(hint), 14, 10);
}


void promptString() {
    char* prompt_string = "myOS >> ";
    print(prompt_string);
}


void showHelp() {
    char *help_msg = 
    "Welcome to myOS. These commands can be executed. \r\n"
    "\r\n"
    "    help - show information about myOS\r\n"
    "    clear - clear screen\r\n"
    "    list - show the information about user program\r\n"
    "    bat - use multiprocess to run user program. e.g. `bat 3 2 1`\r\n"
    "    run - run user program in sequence. e.g. `run 3 2 1`\r\n"
    "    date - show year month day hour minute second\r\n" 
	"    hotwheel - turn on/off the hotwheel\r\n" 
    "    poweroff - close the machine\r\n"
    ;
    print(help_msg);
}


void listUsrProg() {
    const char* hint = "You can use `run <ProgID>` to run a user program.\r\n";
    const char* list_head =
        "ProgID  - Program Name  -  Size  -  Addr - Cylinder - Head - Sector\r\n";
    const char* separator = "  -  ";
    print(hint);
    print(list_head);
    uint16_t prog_num = getUsrProgNum();  
    for(int i = 1; i <= prog_num; i++) {
        print(itoa(i, 10)); print(separator);  
        print(getUsrProgName(i));
        for(int j = 0, len = 16-strlen(getUsrProgName(i)); j < len; j++) {
            putchar(' ');
        }
        print(separator);  
        print(itoa(getUsrProgSize(i), 10)); print(separator);  
        putchar('0'); putchar('x');  
        print(itoa(getUsrProgAddrSeg(i), 16)); print(separator);  
        print(itoa(getUsrProgCylinder(i), 10)); print(separator);  
        print(itoa(getUsrProgHead(i), 10)); print(separator);  
        print(itoa(getUsrProgSector(i), 10));  
        NEWLINE;
    }
}


void showDateTime() {
    putchar('2'); putchar('0');
    print(itoa(bcd2decimal(getDateYear()), 10)); putchar('-');
    print(itoa(bcd2decimal(getDateMonth()), 10)); putchar('-');
    print(itoa(bcd2decimal(getDateDay()), 10)); putchar(' ');
    print(itoa(bcd2decimal(getDateHour()), 10)); putchar(':');
    print(itoa(bcd2decimal(getDateMinute()), 10)); putchar(':');
    print(itoa(bcd2decimal(getDateSecond()), 10));
    NEWLINE;
}


void batch(char* cmdstr) {
    char progids[BUFLEN+1];
    getAfterFirstWord(cmdstr, progids);  
    uint8_t isvalid = 1;  
    for(int i = 0; progids[i]; i++) {  
        if(!isnum(progids[i]) && progids[i]!=' ') { 
            isvalid = 0;
            break;
        }
        if(isnum(progids[i]) && progids[i]-'0'>getUsrProgNum()) {
            isvalid = 0;
            break;
        }
    }
    if(isvalid) {  
        int i = 0;
        for(int i = 0; progids[i] != '\0'; i++) {
            if(isnum(progids[i])) {  
                int progid_to_run = progids[i] - '0';  
                loadAndRun(getUsrProgCylinder(progid_to_run), getUsrProgHead(progid_to_run), getUsrProgSector(progid_to_run), getUsrProgSize(progid_to_run)/512, getUsrProgAddrSeg(progid_to_run), getUsrProgAddrOff(progid_to_run));
                clearScreen();
            }
        }
        const char* hint = "All programs have been executed successfully!\r\n";
    }
    else {  
        const char* error_msg = "Invalid arguments. The number after run must less than or equal to ";
        print(error_msg);
        print(itoa(getUsrProgNum(), 10));
        putchar('.');
        NEWLINE;
    }
}

void multiProcessing(char* cmdstr) {
    char progids[BUFLEN+1];
    getAfterFirstWord(cmdstr, progids);  
    uint8_t isvalid = 1;  
    if(progids[0] == '\0') { isvalid = 0; }
    for(int i = 0; progids[i]; i++) {  
        if(!isnum(progids[i]) && progids[i]!=' ') {  
            isvalid = 0;
            break;
        }
        if(isnum(progids[i]) && progids[i]-'0'>4) {  
            isvalid = 0;
            break;
        }
    }
    if(isvalid) {  
        int i = 0;
        for(int i = 0; progids[i] != '\0'; i++) {
            if(isnum(progids[i])) {  
                int progid_to_run = progids[i] - '0';  
                loadProcessMem(getUsrProgCylinder(progid_to_run), getUsrProgHead(progid_to_run), getUsrProgSector(progid_to_run), getUsrProgSize(progid_to_run)/512, getUsrProgAddrSeg(progid_to_run), getUsrProgAddrOff(progid_to_run), progid_to_run);
            }
        }
        timer_flag = 1;  
        Delay();
        timer_flag = 0;  
        clearScreen();
        const char* hint = "All processes have been killed.\r\n";
        print(hint);
    }
    else {  
        const char* error_msg = "Invalid arguments. The number after bat must less than or equal to 4.";
        print(error_msg);
        NEWLINE;
    }
}

void shell() {
    clearScreen();
    showHelp();
    char cmdstr[BUFLEN+1] = {0}; 
    char cmd_firstword[BUFLEN+1] = {0};  
    enum command             { help,   clear,   list,   bat,   run,   poweroff,   date,    hotwheel};
    const char* commands[] = {"help", "clear", "list", "bat", "run", "poweroff", "date",  "hotwheel"};

    while(1) {
        promptString();
        readToBuf(cmdstr, BUFLEN);
        getFirstWord(cmdstr, cmd_firstword);

        if(strcmp(cmd_firstword, commands[help]) == 0) {
            showHelp();
        }
        else if(strcmp(cmd_firstword, commands[clear]) == 0) {
            clearScreen();
        }
        else if(strcmp(cmd_firstword, commands[list]) == 0) {
            listUsrProg();
        }
        else if(strcmp(cmd_firstword, commands[run]) == 0) {  
            batch(cmdstr);
        }
        else if(strcmp(cmd_firstword, commands[bat]) == 0) {  
            multiProcessing(cmdstr);
        }
        else if(strcmp(cmd_firstword, commands[hotwheel]) == 0) {
            const char* turned_on = "Hotwheel has been turned on.\r\n";
            const char* turned_off = "Hotwheel has been turned off.\r\n";
            if(switchHotwheel()==0) {
                print(turned_off); 
            }
            else {
                print(turned_on);
            }
        }
        else if(strcmp(cmd_firstword, commands[poweroff]) == 0) {
            powerOff();
        }
        else if(strcmp(cmd_firstword, commands[date]) == 0) {
            showDateTime();
        }
        else {
            if(cmd_firstword[0] != '\0') {
                const char* error_msg = ": command not found\r\n";
                print(cmd_firstword);
                print(error_msg);
            }
        }
    }
}
