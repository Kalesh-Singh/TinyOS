;
; A function that prints a null terminated string.
; 
; Expects the start of the string to be passed in bx.

print_string:
    pusha       ; Push all registers to the stack
    mov ah, 0x0e    ; int=10/ah=0x0e -> BIOS teletype output

    print_char:
        mov al, [bx]
        cmp al, 0
        je return

        int 0x10        ; print the character in al
        add bx, 0x1     ; Increment the address in bx by 1 byte
        jmp print_char
        
    return:
        popa        ; Restore original register values
        ret         ; Return
