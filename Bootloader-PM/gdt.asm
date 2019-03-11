; Once the CPU has been switched into 32-bit protected mode, 
; the process by which it translates logical addresses 
; (i.e.the combination of a segment register and an offset) to 
; physical address is completely different: rather than multiply 
; the value of a segment register by 16 and then add to it 
; the offset, a segment register becomes an index to a particular
; segment descriptor (SD) in the GDT.

; A segment descriptor is an 8-byte structure that defines 
; the following properties of a protected-mode segment:A
; 1. Base address (32 bits), which defines where the 
;    segment begins in physical memory.
; 2. Segment Limit (20 bits), which defines the size of the 
;    segment.
; 3. Various flags, which affect how the CPU interprets the 
;    segment, such as the privilige level of code that runs 
;    within it or whether it is read- or write-only.

; The simplest workable configuration of segment registers is 
; described by Intel as the basic flat model, whereby two 
; overlapping segments are defined that cover the full 4 GB 
; of addressable memory, one for code and the other for data. 
; The fact that in this model these two segments overlap means 
; that there is no attempt to protect one segment from the other, 
; nor is there any attempt to use the paging features for virtual 
; memory. It pays to keep things simple early on, especially 
; since later we may alter the segment descriptors more easily 
; once we have booted into a higher-level language.

; Our CODE SEGMENT will have the following configuration:
; - Base Address: 0x0
; - Limit: 0xfffff
; - Present: 1, since segment is present in memory - used
;            for virtual memory.
; - Privilege: 0, ring 0 is the highest privilige.
; - Descriptor Type: 1 for Code or Data segment, 0 is used
;                    for traps.
; - Type: 
;       - Code: 1 for code, since this is a code segment.
;       - Conforming: 0, by not conforming it means code in
;                     a segment with a lower privilege may
;                     not call code in this segment - this
;                     is a key to memory protection.
;       - Readable: 1, 1 if readable, 0 if executeable only.
;                   Readable allows us to read constants
;                   defined in the code.
;       - Accessed: 0, This is often used for debugging and
;                   virtual memory techniques, since the CPU
;                   sets the bit when it accesses the segment.
; Other Flags:
;       - Granularity: 1, if set this multiplies our limit by 
;                      4K (i.e 16*16*16), so our 0xfffff would
;                      become 0xfffff000 (i.e. shift 3 hex digits
;                      to the left), allowing our segment to span
;                      4 GB of memory.
;       - 32-bit Default: 1, since our segment will hold 32-bit
;                         code, otherwise we'd use 0 for 16-bit
;                         code. This actually sets the default
;                         data unit size for operations (e.g.
;                         push 0x4, would expeand to a 32-bit
;                         number, etc).
;       - 64-bit Code Segment: 0, unused on 32-bit processor.
;       -AVL (Available for Use by System Software): 0, We can
;            set this for our own uses (e.g. debugging) but we
;            will not use it.

; Since we are using a simple flat model, with two identical
; overlapping code and data segments, the DATA SEGMENT Will
; be identical but for the type flags:
;
; - Type:
;       - Code: 0 for data.
;       - Expand Down: 0, This allows the segment to expand down.
;       - Writable: 1, This allows the data segment to be written
;                   to, otherwise it would be read only.
;       - Accessed: 0, this is often used for debuggin and virtual
;                   memory techniques, since the CPU sets the bit
;                   when it accesses the segment.

; In addition to the code and data segments, the CPU requires 
; that the first entry in the GDT purposely be an invalid
; NULL DESCRIPTOR (i.e. a structure of 8 zero bytes). The null 
; descriptor is a simple mechanism to catch mistakes where we 
; forget to set a particular segment register before accessing 
; an address, which is easily done if we had some segment 
; registers set to 0x0 and forgot to update them to the 
; appropriate segment descriptors after switching to protected 
; mode. If an addressing attempt is made with the null descriptor,
; then the CPU will raise an exception, which essentially is an 
; interrupt.

; Actually, for the simple reason that the CPU needs to know how 
; long our GDT is, we don’t actually directly give the CPU the 
; start address of our GDT but instead give it the address of a 
; much simpler structure called the GDT Descriptor 
; (i.e. something that describes the GDT). 

; The GDT Descriptor is a 6-byte structure containing:
; 1. GDT size (16 bits / 2 bytes)
; 2. GDT address (32 bits / 4 bytes)

;
; Global Descriptor Table (GDT) Data Structure
;

gdt_start:

gdt_null:           ; The mandatory null descriptor.
    dd 0x0          ; 'dd' means define double word (i.e 4 bytes)
    dd 0x0

gdt_code:           ; The Code Segment Descriptor
    ; base=0x0, limit=0xfffff,
    ; 1st flags: (present)1 (privilege)00 (descriptor type)1 
    ;           -> 1001b
    ; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 
    ;           -> 1010b
    ; 2nd flags: (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0 
    ;           -> 1100b
    
    dw 0xffff       ; Limit (bits 0-15)
    dw 0x0          ; Base (bits 0-15)
    db 0x0          ; Base (bits 16-23)
    db 10011010b    ; 1st Flags, Type Flags
    db 11001111b    ; 2nd Flags, Limit (bits 16-19)
    db 0x0          ; Base (bits 24-31)

gdt_data:           ; The Data Segment Descriptor
    ; Same as the code segment except for the type flags.
    ; Type Flags: (code)0 (expand down)0 (writable)1 (accessed)0
    ;           -> 0010b
    
    dw 0xffff       ; Limit (bits 0-15)
    dw 0x0          ; Base (bits 0-15)
    db 0x0          ; Base (bits 16-23)
    db 10010010b    ; 1st Flags, Type Flags
    db 11001111b    ; 2nd Flags, Limit (bits 16-19)
    db 0x0          ; Base (bits 24-31)

gdt_end:            ; The reason for putting a label at the end of the
                    ; GDT is so that we can have the assembler calculate
                    ; the size of the GDT for the GDT descriptor (below)

;
; GDT Descriptor
;

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of our GDT, always less one of the
                                ; true size
    dd gdt_start                ; Start address of our GDT

; Define some handy cnostants for the GDT Segment Descriptor offsets, which are
; what segment registers must contain when in protected mode. For example,
; when we set DS = 0x10 in PM (Protected Mode), the CPU knows that we mean it
; to use the segment described at offset 0x10 (i.w 16 bytes) in our GDT, which
; in our case is the DATA segment (0x0 -> NULL, 0x08 -> CODE, 0x10 -> DATA)

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
