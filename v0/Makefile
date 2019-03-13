# Automatically generate lists of sources using wildcards.
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)

# Convert the *.c filenames to *.o to give a list
# of object files to build.
OBJ = $(C_SOURCES:.c=.o)

# Default build target
all: os-kernel.img

# Run qemu to simulate booting of our code
run: all
	qemu-system-x86_64 -fda os-kernel.img

# This is the actual disk image that the computer
# loads which is the combination of our compiled
# bootsector and kernel.
os-kernel.img: boot/boot_sect.bin kernel/kernel.bin
	cat $^ > os-kernel.img

# This builds the binary of our kernel form two 
# object files:
# - the kernel_entry, which jumps to main() in 
#   our kernel.
# - the compiled C kernel.
kernel/kernel.bin: kernel/kernel_entry.o ${OBJ}
	i386-elf-ld -o $@ -Ttext 0x1000 $^ --oformat binary

# Generic rule for compiling C code to an object
# file. For simplicity, we say all C files depend
# on all header files.
%.o : %.c ${HEADERS}
	i386-elf-gcc -ffreestanding -c $< -o $@

# General rule for compiling assembly code to
# object code.
%.o : %.asm
	nasm $< -f elf -o $@

# Generic rule for compiling assembly code to
# raw (binary) format.
%.bin : %.asm
	nasm $< -f bin -I 'boot/real-mode/' -o $@

# clean target will not work properly if a file named clean 
# is ever created in this directory. Since it has no prerequisites,
# clean would always be considered up to date and its recipe would 
# not be executed. To avoid this problem you can explicitly declare 
# the target to be phony by making it a prerequisite of the special 
# target .PHONY
.PHONY : clean

clean:
	rm -rf os-kernel.img
	rm -rf kernel/*.o kernel/*.bin boot/*.bin drivers/*.o


