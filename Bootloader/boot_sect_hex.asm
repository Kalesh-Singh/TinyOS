;
; A boot sector that prints an address as a hexadecimal.
;

[org 0x7c00]    ; Tell the assembler where this code will be loaded.

mov dx, 0x1fb6      ; Store the value to print in dx
call print_hex

jmp $               ; Infinite loop (Hang)

%include "print_lib.asm" ; Include the print library we created

;
; Data
;

; Padding and magic number
times 510-($-$$) db 0
dw 0xaa55
