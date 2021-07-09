; 程序源代码（stoneru.asm）
%include "macro.asm"
org offset_usrprog2

    Dn_Rt equ 1            ; D-Down,U-Up,R-right,L-Left
    Up_Rt equ 2
    Up_Lt equ 3
    Dn_Lt equ 4
    delay equ 50000        ; 计时器延迟计数,用于控制画框的速度
    ddelay equ 580         ; 计时器延迟计数,用于控制画框的速度


start:
    pusha
    call ClearScreen       ; 清屏
    mov ax,cs
    mov es,ax              ; ES = CS
    mov ds,ax              ; DS = CS
    mov es,ax              ; ES = CS
    mov ax,0B800h
    mov gs,ax              ; GS = B800h，指向文本模式的显示缓冲区
    mov byte[char],'A'

    PRINT_IN_POS hint1, hint1len, 7, 29

initialize:                ; 多次调用用户程序时，可保证不受上次调用的影响
    mov word[x], 7
    mov word[y], 40
    mov byte[curcolor], 80h
    mov byte[curcolor2], 01h
    mov word[count], delay
    mov word[dcount], ddelay
    mov byte[rdul], Dn_Rt  ; 向右下运动

loop1:
    dec word[count]        ; 递减计数变量
    jnz loop1              ; >0：跳转;
    mov word[count],delay
    dec word[dcount]       ; 递减计数变量
    jnz loop1
    mov word[count],delay
    mov word[dcount],ddelay

    mov al,1
    cmp al,byte[rdul]
    jz  DnRt
    mov al,2
    cmp al,byte[rdul]
    jz  UpRt
    mov al,3
    cmp al,byte[rdul]
    jz  UpLt
    mov al,4
    cmp al,byte[rdul]
    jz  DnLt
    ; jmp $

DnRt:
    inc word[x]
    inc word[y]
    mov bx,word[x]
    mov ax,13
    sub ax,bx
    jz  dr2ur
    mov bx,word[y]
    mov ax,80
    sub ax,bx
    jz  dr2dl
    jmp show

dr2ur:
    mov word[x],11
    mov byte[rdul],Up_Rt
    jmp show

dr2dl:
    mov word[y],78
    mov byte[rdul],Dn_Lt
    jmp show


UpRt:
    dec word[x]
    inc word[y]
    mov bx,word[y]
    mov ax,80
    sub ax,bx
    jz  ur2ul
    mov bx,word[x]
    mov ax,-1
    sub ax,bx
    jz  ur2dr
    jmp show

ur2ul:
    mov word[y],78
    mov byte[rdul],Up_Lt
    jmp show

ur2dr:
    mov word[x],1
    mov byte[rdul],Dn_Rt
    jmp show


UpLt:
    dec word[x]
    dec word[y]
    mov bx,word[x]
    mov ax,-1
    sub ax,bx
    jz  ul2dl
    mov bx,word[y]
    mov ax,39
    sub ax,bx
    jz  ul2ur
    jmp show

ul2dl:
    mov word[x],1
    mov byte[rdul],Dn_Lt
    jmp show
ul2ur:
    mov word[y],41
    mov byte[rdul],Up_Rt
    jmp show

DnLt:
    inc word[x]
    dec word[y]
    mov bx,word[y]
    mov ax,39
    sub ax,bx
    jz  dl2dr
    mov bx,word[x]
    mov ax,13
    sub ax,bx
    jz  dl2ul
    jmp show

dl2dr:
    mov word[y],41
    mov byte[rdul],Dn_Rt
    jmp show

dl2ul:
    mov word[x],11
    mov byte[rdul],Up_Lt
    jmp show

show:
    xor ax,ax              ; 计算显存地址
    mov ax,word[x]
    mov bx,80
    mul bx
    add ax,word[y]
    mov bx,2
    mul bx
    mov bp,ax
    mov ah,[curcolor2]     ; 弹字符的背景色和前景色（默认值为07h，详见文档）
    inc byte[curcolor2]
    cmp byte[curcolor2], 0fh
    jnz skip
    mov byte[curcolor2], 1 ; 为了不改变背景色
skip:
    mov al,byte[char]      ; AL = 显示字符值（默认值为20h=空格符）
    mov word[gs:bp],ax     ; 显示字符的ASCII码值

    mov ah, 01h            ; 功能号：查询键盘缓冲区但不等待
    int 16h
    jz continue            ; 无键盘按下，继续
    mov ah, 0              ; 功能号：查询键盘输入
    int 16h
    cmp al, 101             ; 是否按下e
    je QuitUsrProg         ; 若按下e，退出用户程序

continue:
    jmp loop1

end:
    jmp $                  ; 停止画框，无限循环

QuitUsrProg:
    popa
    retf

ClearScreen:               ; 函数：清屏
    pusha
    mov ax, 0003h
    int 10h                ; 中断调用，清屏
    popa
    ret

DataArea:
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt          ; 向右下运动
    char db 'A'

    x dw 7
    y dw 40

    curcolor db 80h        
    curcolor2 db 01h       ; 保存当前字符颜色属性，用于移动的字符

    hint1 db 'This is usrprog 2. Press e to exit.'
    hint1len equ ($-hint1)

    times 1024-($-$$) db 0
