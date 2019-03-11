;
; A simple boot sector program that demonstrates
; segment offsetting.
;

mov ah, 0x0e        ; int 10/ah = 0x0e -> Scrolling teletype
                    ; BIOS routine.

mov al, [the_secret]
int 0x10            ; Does this print an X?
                    ; NO. We did not use [org 0x7c00] so the
                    ; assembler does not offset our labels to
                    ; the correct memory locations when the 
                    ; code is loaded by the BIOS to the 
                    ; address 0x7c00.

mov bx, 0x7c0       ; Can't set ds directly, so set bx
mov ds, bx          ; then copy bx to ds
mov al, [the_secret]
int 0x10            ; Does this print an X?
                    ; YES. By default the offset is from the
                    ; "data segment" (ds). Since we set the
                    ; ds register to 0x7c0, the CPU will
                    ; calculate the correct offset for us
                    ; (i.e. 0x7c0 * 16 + the secret).

mov al, [es:the_secret] ; Tell the CPU to use es not ds segment
int 0x10                ; Does this print an X?
                        ; No. The es register has not been set
                        ; to 0x7c0.


mov bx, 0x7c0
mov es, bx
mov al, [es:the_secret]
int 0x10                ; Does this print an X?
                        ; YES. Since we set the es register to 
                        ; 0x7c0  the correct offset will be
                        ; calculated by the CPU
                        ; (i.e 0x7c0 * 16 + the_secret).

jmp $               ; Infinite loop

the_secret:
    db 'X'

; Padding and magic BIOS number.
times 510-($-$$) db 0
dw 0xaa55
