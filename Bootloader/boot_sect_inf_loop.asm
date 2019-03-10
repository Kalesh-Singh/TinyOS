;
; A simple boot sector program that loops forever.
;

loop:                   ; Define a label, "loop", that will allow
                        ; us to jump back to it, forever.

    jmp loop            ; Use a simple CPU instruction that jumps
                        ; to a new memory address to continue execution.
                        ; In our case, jump to the address of the 
                        ; current instruction.

times 510-($-$$) db 0   ; When compiled our program must fit into
                        ; 512 bytes, with the last two bytes being the
                        ; magic number, so here, tell our assembly
                        ; compiler to pad out our program with enough
                        ; zero bytes (db 0) to bring us to the
                        ; 510th byte.
                        ; I wish this was more documented. In NASM, 
                        ; the dollar operator ($) represents the address
                        ; of the current line. $$ represents the address 
                        ; of the first instruction. So, $-$$ returns 
                        ; the number of bytes from the current line to 
                        ; the start.

dw 0xaa55               ; Last two bytes (one word) form the magic
                        ; number, so BIOS knows we are a boot sector.
                        ; Remember that the BIOS INT 0x19 searches for 
                        ; a bootable disk. How does it know if the disk 
                        ; is bootable? The boot signiture. If the 511 
                        ; byte is 0xAA and the 512 byte is 0x55, 
                        ; INT 0x19 will load and execute the bootloader.

; Because the boot signiture must be the last two bytes in the bootsector,
; We use the times keyword to calculate the size different to fill in up 
; to the 510th byte, rather than the 512th byte.
