;
; A simple routine that loads DH sectors to ES:BX
; from drive DL.
;
; Expects as parameters:
; 1. The address to which the sectors will be loaded to be 
;    passed as a parameter in registers ES:BX
; 2. The number of sectors to be read to be passed in 
;    register dh.
; 
; We will make use of the BIOS interrupt routine 0x13
; which expects certain registers to be set as follows:
; 1. dl - contains the drive number to be read (0 indexed).
; 2. ch - contains the cylinder number to be read (0 indexed).
; 3. dh - contains the head number (which side of the disk
;         to read). 0 = first side and 1 = second side
;         (0 indexed).
; 4. cl - contains the sector on the track to start reading from.
;         (1 indexed).
; 5. al - contains the number of sectors to read from the 
;         starting point.
; 
; Interrupt 0x13 also expects the address we'd like the BIOS
; to read the sectors to be set as ES:BX (i.e. segment ES
; with offset BX).

disk_load:
    pusha           ; Push all registers to the stack.
    push dx         ; Store DX on the stack so later we can recall
                    ; how many sectors were requested to be read,
                    ; even if it is altered in the meanwhile.
    mov ah, 0x02    ; BIOS read sector function
    
    mov al, dh      ; Read DH sectors
    mov ch, 0x00    ; Select cylinder 0
    mov dh, 0x00    ; Select head 0
    mov cl, 0x02    ; Start reading from the second sector
                    ; (i.e. after the boot sector)

    int 0x13        ; BIOS interrupt routine

    jc cf_set       ; Jump if error (i.e carry flag (CF) was set)

    pop dx          ; Restore dx from the stack
    cmp dh, al      ; if AL (sectors read) != DH (sectors expected)
    jne disk_error  ;   dispaly error message

    popa            ; Restore the original values of the registers
    ret             ; Return
    
    cf_set:
        mov bx, CF_SET_MSG
        call print_string
        call print_nl
    disk_error:
        mov bx, DISK_ERROR_MSG
        call print_string
        call print_nl
        jmp $

    ; Variables
    DISK_ERROR_MSG:
        db "Disk read error!", 0
    CF_SET_MSG:
        db "CF set!", 0
