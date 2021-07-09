; (syscall_test.asm)测试系统调用的用户程序


%include "macro.asm"
org offset_syscalltest

Start:
    pusha
    push es

    mov ax, 0003h
    int 10h                            ; 清屏

    PRINT_IN_POS hint_all, hint_all_len, 0, 0
    mov ah, 0
    int 16h
    cmp al, 101                         ; 按下e
    je QuitUsrProg                     ; 直接退出

    ;PRINT_IN_POS hint0, hint_len, 2, 0
    mov ah, 00h                        ; 系统调用功能号ah=00h，显示字符串
    int 21h
    mov ah, 0
    int 16h
    cmp al, 101                        ; 按下e
    je QuitUsrProg                     ; 直接退出

    ;PRINT_IN_POS hint1, hint_len, 2, 0
    mov ax, cs
    mov es, ax                         ; es=cs
    mov dx, upper_lower                ; es:dx=串地址
    PRINT_IN_POS upper_lower, 14, 3, 0
    mov ah, 01h                        ; 系统调用功能号ah=01h，大写转小写
    int 21h
    PRINT_IN_POS upper_lower, 14, 4, 0
    mov ah, 0
    int 16h
    cmp al, 101                         ; 按下e
    je QuitUsrProg                     ; 直接退出

    ;PRINT_IN_POS hint2, hint_len, 2, 0
    mov ax, cs
    mov es, ax                         ; es=cs
    mov dx, upper_lower                ; es:dx=串地址
    mov ah, 02h                        ; 系统调用功能号ah=02h，小写转大写
    int 21h
    PRINT_IN_POS upper_lower, 14, 5, 0
    mov ah, 0
    int 16h
    cmp al, 101                       ; 按下e
    je QuitUsrProg                     ; 直接退出

   


QuitUsrProg:
    pop es
    popa
    retf

DataArea:
    hint_all db 'Welcome to syscall test program, please press ENTER to start and e to exit'
    hint_all_len equ $-hint_all


    upper_lower db 'AbCdEfGhIjKlMn', 0 ; 字符串以'\0'结尾

 