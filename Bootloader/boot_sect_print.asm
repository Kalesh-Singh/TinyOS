;
; A simple boot sector that prints a message to the screen
; using a BIOS routine.
;

mov ah, 0x0e    ; int 10/ah = 0eh -> Scrolling teletype BIOS routine.

mov al, 'H'
int 0x10
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
int 0x10        ; al still contains 'l'. Remember?
mov al, 'o'
int 0x10

jmp $           ; Jump to the current address (infinite loop)

;
; Padding and magic BIOS number.
;

times 510-($-$$) db 0   ; Pad boot sector out with zeros.

dw 0xaa55               ; Last two bytes form the magic number,
                        ; so BIOS knkows we are a boot sector.
