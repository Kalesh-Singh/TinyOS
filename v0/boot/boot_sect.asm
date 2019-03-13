;
; A boot sector that boots a C kernel in 32-bit protected mode.
;
[org 0x7c00]
KERNEL_OFFSET equ 0x1000    ; This is the memory offset to
                            ; which we will load our kernel.

mov [BOOT_DRIVE], dl        ; BIOS stores our boot drive in
                            ; DL, so it's best to remember
                            ; this for later.

mov bp, 0x9000              ; Set-up the stack.
mov sp, bp

mov bx, MSG_REAL_MODE       ; Announce that we are starting
call print_string           ; the boot in 16-bit real mode
call print_nl

call load_kernel            ; Load our kernel

call switch_to_pm           ; Switch to protected mode, from
                            ; which we will not return

jmp $                       ; Hang

; Include our reusable routines (from v0/boot/real-mode/)
%include "print_lib.asm"
%include "disk_load.asm"
%include "gdt.asm"
%include "print_string_pm.asm"
%include "switch_to_pm.asm"

[bits 16]

;
; Load the kernel
;

load_kernel:
    mov bx, MSG_LOAD_KERNEL ; Print a message to say we are
    call print_string       ; loading the kernel
    call print_nl

    mov bx, KERNEL_OFFSET   ; Set-up parameters for our
    mov dh, 15              ; disk_load routine, so that we
    mov dl, [BOOT_DRIVE]    ; load the first 15 sectors
    call disk_load          ; (excluding the boot sector) from
                            ; the boot disk (i.e. our kernel
                            ; code) to address KERNEL_OFFSET

    ret                     ; Return

[bits 32]

; This is where we arrive after switching to and initializing
; protected mode.

BEGIN_PM:
    mov ebx, MSG_PROT_MODE  ; Use our 32-bit print routine
    call print_string_pm    ; announce we are in protected mode

    call KERNEL_OFFSET      ; Now jump to the address of our
                            ; loaded kernel code.

    jmp $                   ; Hang


;
; Global variables
;

BOOT_DRIVE      db 0
MSG_REAL_MODE   db "Started in 16-bit Real Mode", 0
MSG_PROT_MODE   db "Successfully landed in 32-bit Protected Mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory.", 0

;
; Boot Sector Padding and Magic Number
;

times 510-($-$$) db 0
dw 0xaa55



