; For now, it suffices to know that the display device can be 
; configured into one of several resolutions in one of two 
; modes, text mode and graphics mode; and that what is displayed 
; on the screen is a visual representation of a specific range 
; of memory. So, in order to manipulate the screen, we must 
; manipulate the specific memory range that it is using in its 
; current mode. The display device is an example of memory-mapped
; hardware because it works in this way. When most computers 
; boot, despite that they may infact have more advanced graphics 
; hardware, they begin in a simple Video Graphics Array (VGA) 
; colour text mode with dimmensions 80x25 characters. In text 
; mode, the programmer does not need to render individual pixels 
; to describe specific characters, since a simple font is already 
; defined in the internal memory of the VGA display device. 
; Instead, each character cell of the screen is represented by 
; two bytes in memory: the first byte is the ASCII code of the
; character to be displayed, and the second byte encodes the 
; characters attributes, such as the foreground and background 
; colour and if the character should be blinking. So, if we’d 
; like to display a character on the screen, then we need to set 
; its ASCII code and attributes at the correct memory address 
; for the current VGA mode, which is usually at address 0xb8000.
; 
; Note that, although the screen is displayed as columns and 
; rows, the video memory is simply sequential. For example, 
; the address of the column 5 on row 3 can be calculated
; as follows: 0xb8000 + 2 * (row * 80 + col)

[bits 32]   ; Tell the assembler to compile to 32-bit instructions
            ; from here on.

; Registers are extended to 32 bits, with their full capacity 
; being accessed by prefixing an e to the register name, 
; for example: mov ebx, 0x274fe8fe

; Define some constants
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

;
; Prints a null-terminated string pointed to by EBX
;
; Expects the the start address of the string to be
; passed as a prameter in EBX
;

print_string_pm:
    pusha                       ; Push all registers to stack
    mov edx, VIDEO_MEMORY       ; Set EDX to the start of the 
                                ; video memory

    print_string_pm_loop:
        mov al, [ebx]           ; Store char at EBX in AL
        mov ah, WHITE_ON_BLACK  ; Store the attribute in AH

        cmp al, 0               ; if (al == 0), at end of string,
        je print_string_pm_done ; so jump to done

        mov [edx], ax           ; Store the char and attribute at
                                ; current character cell.
        
        add ebx, 1  ; Increment ebx to the next char in string.
        add edx, 2  ; Move to next character cell in video memory.

        jmp print_string_pm_loop    ; loop around to print
                                    ; next char

    print_string_pm_done:
        popa                    ; Restore original register values
        ret                     ; Return from function


