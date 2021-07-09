 ;程序源代码（stone.asm）
    org 07c00h					; 程序加载到100h，可用于生成COM
    Dn_Rt equ 1                 ;D-Down,U-Up,R-right,L-Left
    Up_Rt equ 2                  
    Up_Lt equ 3                  
    Dn_Lt equ 4   
    delay equ 50000				; 计时器延迟计数,用于控制画框的速度
    ddelay equ 580				; 计时器延迟计数,用于控制画框的速度
;开始引导扇区
	mov ax,cs
	mov ds,ax					; DS = CS
	mov es,ax					; ES = CS
	mov ax,0b800h
	mov gs,ax
	call ifm	;显示学号和姓名
	call start	;显示数字
	jmp $
;显示学号和姓名的代码块
ifm:
	mov	bp, 0	                 ; BP为当前串的偏移地址
	mov byte[gs:bp+0],'1'
	mov byte[gs:bp+2],'8'
	mov byte[gs:bp+4],'3'
	mov byte[gs:bp+6],'4'
	mov byte[gs:bp+8],'0'
	mov byte[gs:bp+10],'0'
	mov byte[gs:bp+12],'1'
	mov byte[gs:bp+14],'3'
	mov byte[gs:bp+16],'C'
	mov byte[gs:bp+18],'h'
	mov byte[gs:bp+20],'e'
	mov byte[gs:bp+22],'n'
    mov byte[gs:bp+24],'C'
	mov byte[gs:bp+26],'o'
	mov byte[gs:bp+28],'n'
	mov byte[gs:bp+30],'g'
	mov byte[gs:bp+32],'h'
	mov byte[gs:bp+34],'a'
	mov byte[gs:bp+36],'o'
	ret 
;反弹程序：
start:
	mov	ax,0B800h				; 显存起始地址
	mov	gs,ax					
    mov byte[char],'a'          ; 字符a
	
loop1:
	dec word[count]				; 计数器
	jnz loop1					; >0：跳转;
    mov word[count],delay		
	
	dec word[dcount]			
    jnz loop1
	mov word[count],delay
	mov word[dcount],ddelay	    ;以上是用一个二重循环实现时延50000*580个单位时间
;通过比较来确定运动方向
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
    jmp $	
;右下
DnRt:							
	inc word[x]
	inc word[y]
	mov ax,word[x]
	cmp ax,81	        ;和长方形的长比较				
    jz  dr2dl           ;若到达x方向最大值，则往左下弹（长方形的竖直方向的边为反射面）
	mov ax,word[y]
	cmp ax,26			;和长方形的宽比较	
    jz  dr2ur           ;若到达y方向最大值，则往右上弹（长方形的水平方向的边为反射面）
	jmp show
    
dr2dl:
    mov word[x],79				
    mov byte[rdul],Dn_Lt	;往左下弹
    jmp show

dr2ur:
    mov word[y],24
    mov byte[rdul],Up_Rt    ;往右上弹	
    jmp show
;右上：
UpRt:						
	inc word[x]
	dec word[y]
	mov ax,word[y]
	cmp ax,1
    jz  ur2dr           ;往右下弹（原理同上）
	mov ax,word[x]
	cmp ax,81
    jz  ur2ul           ;往左上弹（原理同上）
	jmp show
	
ur2dr:
    mov word[y],3
    mov byte[rdul],Dn_Rt	
    jmp show

ur2ul:
    mov word[x],79
    mov byte[rdul],Up_Lt	
    jmp show
;左上
UpLt:	
	dec word[x]
	dec word[y]
	mov ax,word[x]
	cmp ax,0
	jz  ul2ur             ;往右上弹
	mov ax,word[y]
	cmp ax,1
    jz  ul2dl             ;往左下弹 
	jmp show

    
ul2ur:
    mov word[x],2
    mov byte[rdul],Up_Rt	
    jmp show

ul2dl:
    mov word[y],3
    mov byte[rdul],Dn_Lt	
    jmp show
;左下	
DnLt:
	dec word[x]
	inc word[y]
	mov ax,word[x]
	cmp ax,0
    jz  dl2dr                  ;往右下弹
	mov ax,word[y]
	cmp ax,26
    jz  dl2ul                  ;往左上弹
	jmp show

dl2dr:
    mov word[x],2
    mov byte[rdul],Dn_Rt	
    jmp show
	
dl2ul:
    mov word[y],24
    mov byte[rdul],Up_Lt	
    jmp show
;显示
show:	
	mov ax,word[y]
	dec ax
	mov bx,160
	mul bx
	mov cx,ax	;存储在cx
	mov ax,word[x]
	dec ax
	add ax,ax
	add ax,cx
	mov bp,ax
	mov ah,byte[color]			;  变换颜色
	mov al,byte[char]			;  变换字符
	mov word[gs:bp],ax  		;  显示字符的ASCII码值
	cmp ah,10                   ;  最后为10号颜色
	jnz bianse
	mov byte[color],1           ;  初始为1号颜色
	jmp go
;变色	
bianse:	
	inc byte[color]             ;  颜色变化+1
	
go:	
    mov ah,byte[char]
    cmp ah,122                  ;  最后为字符z（其ASCII码为122）
    jnz bianzi
    mov byte[char],97           ;  初始为字符a（其ASCII码为97）
    jmp goway
;变字符
bianzi: 
	inc byte[char]              ;  ASCII码+1
	
goway:              
    jmp loop1                   ;  变换颜色字符过程结束返回循环
	
end:
    jmp $                  
	
datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt         
    x    dw 3
    y    dw 1
    char db 97
    color db 6
