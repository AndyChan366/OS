#include "stringio.h"
#define BUFLEN 16
#define NEWLINE putchar('\r');putchar('\n')

extern void clearScreen();
extern void powerOff();
extern uint8_t getUsrProgNum();
extern char* getUsrProgName(uint16_t pid);
extern uint16_t getUsrProgSize(uint16_t pid);
extern uint8_t getUsrProgCylinder(uint16_t pid);
extern uint8_t getUsrProgHead(uint16_t pid);
extern uint8_t getUsrProgSector(uint16_t pid);
extern uint16_t getUsrProgAddr(uint16_t pid);
extern void loadAndRun(uint8_t cylinder, uint8_t head, uint8_t sector, uint16_t len, uint16_t addr);
extern uint8_t getDateYear();
extern uint8_t getDateMonth();
extern uint8_t getDateDay();
extern uint8_t getDateHour();
extern uint8_t getDateMinute();
extern uint8_t getDateSecond();
extern uint16_t switchHotwheel();


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
    "Welcome to myOS. These commands can be execute. \r\n"
    "\r\n"
    "    help - show information about myOS\r\n"
    "    clear - clear screen\r\n"
    "    list - show the information about user program\r\n"
    "    run - run user program in sequence. e.g. `run 3 2 1`\r\n"
    "    date - show year month day hour minute second\r\n"
	"    hotwheel - turn on/off the hotwheel\r\n" 
    "    poweroff - force close the machine\r\n"
    ;
    print(help_msg);
}


void listUsrProg() {
    const char* hint = "You can use `run <PID>` to run a user programme.\r\n";
    const char* list_head =
        "PID  -     Name         -  Size  -  Addr - Cylinder - Head - Sector\r\n";
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
        print(itoa(getUsrProgAddr(i), 16)); print(separator);  
        print(itoa(getUsrProgCylinder(i), 10)); print(separator);  
        print(itoa(getUsrProgHead(i), 10)); print(separator);  
        print(itoa(getUsrProgSector(i), 10));  
        NEWLINE;
    }
}


uint8_t bcd2decimal(uint8_t bcd)
{
    return ((bcd & 0xF0) >> 4) * 10 + (bcd & 0x0F);
}


void shell() {
    clearScreen();
    showHelp();
    
    char cmdstr[BUFLEN+1] = {0};  
    char cmd_firstword[BUFLEN+1] = {0};  
    enum command             { help,   clear,   list,   run,   poweroff,    date,   hotwheel};
    const char* commands[] = {"help", "clear", "list", "run", "poweroff",  "date", "hotwheel"};

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
            char pids[BUFLEN+1];
            getAfterFirstWord(cmdstr, pids);  
            uint8_t isvalid = 1;  
            for(int i = 0; pids[i]; i++) {  
                if(!isnum(pids[i]) && pids[i]!=' ') {  
                    isvalid = 0;
                    break;
                }
                if(isnum(pids[i]) && pids[i]-'0'>getUsrProgNum()) {
                    isvalid = 0;
                    break;
                }
            }
            if(isvalid) {  
                int i = 0;
                for(int i = 0; pids[i] != '\0'; i++) {
                    if(isnum(pids[i])) {  
                        int pid_to_run = pids[i] - '0';  
                        loadAndRun(getUsrProgCylinder(pid_to_run), getUsrProgHead(pid_to_run), getUsrProgSector(pid_to_run), getUsrProgSize(pid_to_run)/512, getUsrProgAddr(pid_to_run));
                        clearScreen();
                    }
                }
                const char* hint = "All programmes have been executed successfully as you wish.\r\n";
                print(hint);
            }
            else {  
                const char* error_msg = "Invalid arguments. PIDs must be decimal numbers and less than or equal to ";
                print(error_msg);
                print(itoa(getUsrProgNum(), 10));
                putchar('.');
                NEWLINE;
            }

        }
        else if(strcmp(cmd_firstword, commands[poweroff]) == 0) {
            powerOff();
        }
        else if(strcmp(cmd_firstword, commands[date]) == 0) {
            putchar('2'); putchar('0');
            print(itoa(bcd2decimal(getDateYear()), 10)); putchar('-');
            print(itoa(bcd2decimal(getDateMonth()), 10)); putchar('-');
            print(itoa(bcd2decimal(getDateDay()), 10)); putchar(' ');
            print(itoa(bcd2decimal(getDateHour()), 10)); putchar(':');
            print(itoa(bcd2decimal(getDateMinute()), 10)); putchar(':');
            print(itoa(bcd2decimal(getDateSecond()), 10));
            NEWLINE;
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
        else {
            if(cmd_firstword[0] != '\0') {
                const char* error_msg = ": command not found\r\n";
                print(cmd_firstword);
                print(error_msg);
            }
        }
    }
}
