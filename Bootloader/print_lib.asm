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
 
 ;
 ; A function that prints the newline followed by the
 ; carriage return character.
 ; 

 print_nl:
    pusha           ; Push all registers to the stack
    mov ah, 0x0e    ; int=10/ah=0x0e -> BIOS teletype output

    mov al, 0x0a    ; Newline char
    int 0x10        ; print('\n')

    mov al, 0x0d    ; Carriage return
    int 0x10        ; print('\r')

    popa            ; Restore original register values
    ret

;
; A function that prints an address as a hexadecimal.
;
; Expects the address to be passed in dx.
;

print_hex:
    pusha               ; Push all registers to the stack
    mov cx, 5           ; Index into the string

    hex_loop:
        mov ax, dx      ; Use ax as our working register
        and ax, 0x000f  ; 0x1234 -> 0x0004 by masking the first 3 to 0
        cmp ax, 10 
        jge hex_letter  ; The char is a letter
        add ax, 0x30    ; Convert to ASCII digit
        jmp hex_loop_end

        hex_letter:
            add ax, 0x57    ; Convert to ASCII letter (A-F)

        hex_loop_end:
            ; Place the letter in ax (lower 8 bits) 
            ; in the correct position in HEX_OUT
            mov bx, HEX_OUT ; bx = string base address
            add bx, cx      ; Address to place ASCII char
            
            mov [bx], al    ; Copy the ASCII char in ax to the address in bx
                            ; NOTE: We do not place the entire ax (16 bits)
                            ; into the address at bx as this would cause
                            ; us to put the ASCII character followed by 
                            ; a byte of zeros (the null character). 
                            ; Remember Little Endianess ?
                            ; And therefore the print_string function
                            ; would return after printing the first 
                            ; character in our hexadecimal number.
                            ; Hence we used al (the lower 8 bits of ax)
                            ; instead.

            shr dx, 4      ; shift dx right by 4 bits
            sub cx, 1      ; Decrement the index
            cmp cx, 2       
            jge hex_loop    ; Loop while index greater than or equal to 2

    mov bx, HEX_OUT     ; print the string pointed to
    call print_string   ; by BX
    popa                ; Restore original register values
    ret

; Global variables
HEX_OUT:
    db '0x0000', 0



