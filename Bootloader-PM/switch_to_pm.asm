[bits 16]

;
; A re-usable routine that switches the CPU to protected mode.
;

switch_to_pm:
    cli         ; We must switch off interrupts until we have
                ; set-up the protected mode interrupt vector
                ; otherwise interrupts will run riot.

    lgdt [gdt_descriptor]   ; Load our global descriptor table, which
                            ; defines the protected mode segments
                            ; (e.g. for code and data)

    mov eax, cr0            ; To make the switch to protected mode,
    or eax, 0x1             ; we set the first bit of CR0, a control
    mov cr0, eax            ; register.

    jmp CODE_SEG:init_pm    ; Make a far jump (i.e. to a new segment)
                            ; to our 32-bit code. This also forces
                            ; the CPU to flush its cache of
                            ; or pre-fetched and real-mode decoded
                            ; instructions, which can cause problems.
                            ; A far jump by definition also causes
                            ; the CPU to update the CS register to
                            ; the target segment.

[bits 32]
;
; Initialize regiasters and the stack once in PM.
;

init_pm:
    mov ax, DATA_SEG    ; Now in PM, our old segments are meaningless
    mov ds, ax          ; so we point our segement registers to the
    mov ss, ax          ; data selector we defined in our GDT
    mov es, ax
    mov fs, ax
    mov gs, ax

    mox ebp, 0x90000    ; Update our stack position so it is right
                        ; at the top of the free space.

    call BEGIN_PM       ; Finally, call some well-known label.

    
