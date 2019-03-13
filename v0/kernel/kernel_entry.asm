;
; Ensures that we jump straight into the kernel's entry function.
;

[bits 32]       ; We have already switched to 32-bit protected mode.

[extern main]   ; Declare that we will be referencing the external 
                ; symbol 'main', so the linker can substitute the
                ; final address.

call main       ; invoke main() in our compiled C kernel

jmp $           ; Hang forever when we return from the kernel.
