; 程序源代码(usrproginfo.asm)

%include "macro.asm"
%macro UsrProgInfoBlock 7    ; 参数：(PID,程序名,字节数,柱面,磁头,扇区,内存地址)
    pid%1 db %1              ; 程序编号PID；相对偏移0
    name%1 db %2             ; 程序名（至多32字节）；相对偏移1
    times 16-($-name%1) db 0 ; 程序名占6字节
    size%1 dw %3             ; 程序大小；相对偏移17
    cylinder%1 db %4         ; 柱面；相对偏移19
    head%1 db %5             ; 磁头；相对偏移20
    sector%1 db %6           ; 扇区；相对偏移21
    addr%1 dw %7             ; 内存中的地址；相对偏移22
%endmacro                    ; 共24个字节

UsrProgNumber:
    db 4                     ; 用户程序数量

UserProgInfo:
    UsrProgInfoBlock 1, 'stonelu', 1024, 0,1,1, offset_usrprog1
    UsrProgInfoBlock 2, 'stoneru', 1024, 0,1,3, offset_usrprog2
    UsrProgInfoBlock 3, 'stoneld', 1024, 0,1,5, offset_usrprog3
    UsrProgInfoBlock 4, 'stonerd', 1024, 0,1,7, offset_usrprog4


SectorEnding:
    times 512-($-$$) db 0