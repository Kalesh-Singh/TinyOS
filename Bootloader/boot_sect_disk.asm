;
; A simple boot sector program that reads some sectors 
; from the boot disk using our disk_read funciton.
;

[org 0x7c00]

mov [BOOT_DRIVE], dl    ; BIOS stores our boot drive in DL, so
                        ; it's best to remember this for later.

mov bp, 0x8000          ; Here we set our stack safely out of the
mov sp, bp              ; way, at 0x8000

mov bx, 0x9000          ; Load 5 sectors to 
                        ; 0x0000 (ES):0x9000(BX)
mov dh, 5               ; from the boot disk.
mov dl, [BOOT_DRIVE]    
call disk_load

mov dx, [0x9000]        ; Print out the first loaded word, which
call print_hex          ; we expect to be 0xdada, stored
call print_nl           ; at address 0x9000

mov dx, [0x9000 + 512]  ; Also print the first word from the
call print_hex          ; second loaded sector: should be 0xface
call print_nl

jmp $                   ; Hang (Infinite loop)

%include "print_lib.asm"    ; Reuse our print library
%include "disk_load.asm"    ; Include our new disk load function

; Global variables
BOOT_DRIVE: db 0

; Boot Sector Padding
times 510-($-$$) db 0
dw 0xaa55

; We know that BIOS will load only the first 512-byte sector from
; the disk, so if we purposely add a few more sectors to our code
; by repeating some familiar numbers, we can prove to ourselves
; that we actually loaded those additional two sectors from the
; disk we booted from.

; Remember that a word is 16-bit (in real mode) i.e. 2 bytes

times 256 dw 0xdada
times 256 dw 0xface

; Note: If you keep getting errors and your code seems fine, 
; make sure that qemu is booting from the right drive and 
; set the drive on dl accordingly.

; The BIOS sets dl to the drive number before calling the 
; bootloader. However, I found some problems with qemu 
; when booting from the hdd.

; There is a quick fix:
; Try the flag -fda for example, 
; qemu -fda boot_sect_main.bin 
; which will set dl as 0x00, it 
; seems to work fine then.
