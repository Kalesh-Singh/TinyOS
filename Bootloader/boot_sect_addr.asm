;
; A simple boot sector program that demonstrates addressing.
;

mov ah, 0x0e    ; int 10/ah = 0eh -> Scrolling teletype BIOS routine.

; First attempt
mov al, the_secret
int 0x10            ; Does this print an X ?
                    ; No. The address of X is loaded
                    ; into al not X itself

; Second attempt
mov al, [the_secret]
int 0x10            ; Does this print an X ?
                    ; No. The contents of the address labelled 
                    ; 'the_secret' is loaded into al,
                    ; however, the CPU treats the address
                    ; as though it was from the start of memory
                    ; rather than from the start address of our
                    ; loaded code.

; Third attempt
mov bx, the_secret
add bx, 0x7c00      ; 0x7c00 is the address at which the BIOS 
                    ; loads the boot sector.
mov al, [bx]
int 0x10            ; Does this print an X?
                    ; Yes. We added the offset of 'the_secret;
                    ; to the address at which the BIOS loads
                    ; our boot sector.

; Fourth attempt
mov al, [0x7c1d]
int 0x10            ; Does this print an X:
                    ; Yes. Becuase we maually computed the
                    ; absolute address of 'the_secret' by looking
                    ; at the compiled program.
                    ; This allows us to appreciate the use of
                    ; labels in assembly languages.

jmp $               ; Jump forever.

the_secret:
    db "X"

; Padding and Boot Signature

times 510-($-$$) db 0
dw 0xaa55

; It is inconvenient to always have to account for this label--memory 
; offset in your code, so many assemblers will correct label references
; during assemblege if you include the following instruction at the 
; top of your code, telling it exactly where you expect the code to 
; be loaded in memory:

; org 0x7c00

