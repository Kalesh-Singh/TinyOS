## Compile the Kernel ##
`i386-elf-gcc -ffreestanding -c kernel.c -o kernel.o`
`i386-elf-ld -o kernel.bin -Ttext 0x1000 kernel.o --oformat binary`

## Compile the Boot Sector ##
`nasm boot_sect.asm -f bin -I '../v0/boot/real-mode/' -o boot_sect.asm`

The `-I` option tells the assembler where to look for our included files.

## Create a Kernel Image ##

To simplfy the problem of which disk and from which sectors to load the kernel code, the boot sector and kernel of an operating system can be grafted together into a kernel image, which can be written to the initial sectors of the boot disk, such that the boot sector code is always at the head of the kernel image.

`cat boot_sect.bin kernel.bin > os-kernel.img`
