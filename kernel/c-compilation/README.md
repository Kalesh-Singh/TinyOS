## Understanding C Compilation ##

A look at what assembly code some simple C snippets generate.


## Useful Commands ##

### Compile ###

`i386-elf-gcc -ffreestanding -c [file.c] -o [file.o]`

### Link ###

`i386-elf-ld -o [file.bin] -Ttext 0x0 --oformat binary [file.o]`

*Note: A warning may appear when linking, we can disregard it.*

### Decompile ###

`ndisasm -b 32 [file.bin]`

