%include "macro.asm"
%macro UsrProgInfoBlock 8    ; 参数：(ProgID,程序名,字节数,柱面,磁头,扇区,内存地址)
    progid%1 db %1           ; 程序编号ProgID；相对偏移0
    name%1 db %2             ; 程序名（至多32字节）；相对偏移1
    times 16-($-name%1) db 0 ; 程序名占6字节
    size%1 dw %3             ; 程序大小；相对偏移17
    cylinder%1 db %4         ; 柱面；相对偏移19
    head%1 db %5             ; 磁头；相对偏移20
    sector%1 db %6           ; 扇区；相对偏移21
    addr_seg%1 dw %7         ; 内存地址段值；相对偏移22
    addr_off%1 dw %8         ; 内存地址偏移量；相对偏移24
%endmacro                    ; 共26个字节
UsrProgNumber:
    db 5           ; 用户程序数量
UserProgInfo:
    UsrProgInfoBlock 1, 'stonelu',    1024, 1, 0, 1,  addr_usrprog1 >> 4 & 0F000h,    addr_usrprog1 & 0FFFFh
    UsrProgInfoBlock 2, 'stoneru',   1024, 1, 0, 3,  addr_usrprog2 >> 4 & 0F000h,    addr_usrprog2 & 0FFFFh
    UsrProgInfoBlock 3, 'stoneld',    1024, 1, 0, 5,  addr_usrprog3 >> 4 & 0F000h,    addr_usrprog3 & 0FFFFh
    UsrProgInfoBlock 4, 'stonerd',   1024, 1, 0, 7,  addr_usrprog4 >> 4 & 0F000h,    addr_usrprog4 & 0FFFFh
    UsrProgInfoBlock 5, 'test_syscall',    1024, 1, 0, 9, addr_syscalltest >> 4 & 0F000h, addr_syscalltest & 0FFFFh
SectorEnding:
    times 512-($-$$) db 0