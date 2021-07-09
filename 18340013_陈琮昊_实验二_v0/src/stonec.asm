; 程序源代码（stone.asm）
;   NASM汇编格式
    Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
    Up_Rt equ 2                  ;
    Up_Lt equ 3                  ;
    Dn_Lt equ 4                  ;
    delay equ 50000			; 计时器延迟计数,用于控制画框的速度
    ddelay equ 580				; 计时器延迟计数,用于控制画框的速度
	
    org 9100h                                     ; 程序加载到100h，可用于生成COM
OffsetOfMyos equ 7c00h
                mov ah,06h	;清屏
	mov al,0
	mov ch,0
	mov cl,0
	mov dh,24
	mov dl,79
	mov bh,0fh
	int 10h
	mov			ax, cs
	mov			ds, ax
	mov			es, ax
	call		ifm
	


ifm:
	dec 		word[count]				; 递减计数变量
	jnz 		ifm					; >0：跳转;
	mov 		word[count],delay
	dec 		word[dcount]				; 递减计数变量
	jnz 		ifm
	mov 		word[count],delay
	mov 		word[dcount],ddelay
	;用简单的双循环控制时延，这里时延50000x580个时间单位
	
	mov			ax, DisMessage
	mov			bp, ax
	mov			cx, [Strlen]    ;字符串长
	mov			ax, 01301h		;写模式
	mov			bx, 000fh		;页号0，黑底白字		
	mov			dh, [much]	;行=b
	mov			dl, [much]	;列=b
	int			10h				;10h号接口
	dec 		byte[much]
	jnz 			ifm
	
int	10h			 ; BIOS的10h功能：显示一行字符	
	mov	ax, cs	       ; 置其他段寄存器值与CS相同
	mov	ds, ax	       ; 数据段
	mov	bp, Messageend		 ; BP=当前串的偏移地址
	mov	ax, ds		 ; ES:BP = 串地址
	mov	es, ax		 ; 置ES=DS
	mov	cx, MessageendLength  ; CX = 串长（=9）
	mov	ax, 1301h		 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 0007h		 ; 页号为0(BH = 0) 黑底白字(BL = 07h)
   	mov dh, 0 		       ; 行号=0
	mov	dl, 0			 ; 列号=0
	int	10h			 ; BIOS的10h功能：显示一行字符
	mov ah,0
	int 16h 
	;利用软中断10H的0x0e号功能回显字符
	mov ah,0eh 	
	mov bl,0 
	int 10h 		; 调用10H号中断
	cmp al,'e'                 ;输入e实现跳转
	jz goback


	

goback:
    mov ax,cs                ;段地址 ; 存放数据的内存基地址
      mov es,ax                ;设置段地址
      mov bx, OffsetOfMyos ;偏移地址; 
      mov ah,2                 ; 功能号
      mov al,1                 ;扇区数
      mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
      mov dh,0                 ;磁头号 ; 起始编号为0
      mov ch,0                 ;柱面号 ; 起始编号为0
      mov cl,1                 ;起始扇区号 ; 起始编号为1
      int 13H ;                调用读磁盘BIOS的13h功能
      ; 第三个用户程序加载到指定内存区域中
      jmp OffsetOfMyos                   
	
DisMessage:		db		"ChenConghao 18340013"
Strlen               dw      20
delay 				equ 	50000
ddelay 				equ 	580
count 				dw 		delay
dcount 				dw 		ddelay
much			db		24
Messageend:                          db                              'Press e to exit'
MessageendLength  equ ($-Messageend)

