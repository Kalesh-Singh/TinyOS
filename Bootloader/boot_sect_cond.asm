;
; A simple boot sector program that demonstrates conditionals.
;

mov bx, 30

cmp bx, 4           ; if (bx <=4) -> al = 'A'
jg else_if_block
mov al, 'A'
jmp print

else_if_block:      ; else if (bx < 40) -> al = 'B'
    cmp bx, 40
    jge else_block
    mov al, 'B'
    jmp print

else_block:
    mov al, 'C'

print:
    mov ah, 0x0e    ; int=10/ah -> Scrolling teletype BIOS routine.
    int 0x10        ; print the character in al

jmp $               ; Infinite loop

; Padding and Boot Signature (Magic Number)

times 510-($-$$) db 0
dw 0xaa55
