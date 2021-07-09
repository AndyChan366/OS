BITS 16
[global sys_show]
[global sys_toUpper]
[global sys_toLower]


sys_show:
    pusha             ; 保护现场
    push ds
    push es
    mov	ax, cs        ; 置其他段寄存器值与CS相同
    mov	ds, ax        ; 数据段
    mov	bp, ouch_str  ; BP=当前串的偏移地址
    mov	ax, ds        ; ES:BP = 串地址
    mov	es, ax        ; 置ES=DS
    mov	cx, 7         ; CX = 串长
    mov	ax, 1301h     ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0038h     ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov    dh, 12        ; 行号
    mov	dl, 38        ; 列号
    int	10h           ; BIOS的10h功能：显示一行字符
    pop es
    pop ds
    popa              ; 恢复现场
    ret
    ouch_str db 'int 00h'

[extern toupper]
sys_toUpper:
    push es           ; 传递参数
    push dx           ; 传递参数
    call dword toupper
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret

[extern tolower]
sys_toLower:
    push es           ; 传递参数
    push dx           ; 传递参数
    call dword tolower
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret



