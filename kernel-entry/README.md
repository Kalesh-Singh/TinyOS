# Finding the Kernel Entry Routine (main) #

Since the our simple kernel had a single function, and based on our observations of how the compiler generates machine
code, we might assume that the first machine code instruction is the first instruction of the kernel's entry funciton,
main, but suppose that our kernel code looked like this:

```c
void some_fucntion() {

}

void main() {
    char* video_memory = 0xb8000;
    *video_memory = 'X';

    // Call some function
    some_function();
}
```

Now the compiler will likely precede the instrucitons of the entry function `main` with the instructions of
`some_function`, and since our boot strapping code begins executing blindly from the first instruction, it will hit the
first `ret` instruction of `some_function` and return to the boot sector code without ever having entered `main`.

## Solution ## 

We will write a simpel assembly routine whose sole purpose is to call the entry function of the kernel. The reason
assembly is used is becuase we know exactly how it will be translated into machine code, and so we can make sure that
the first instruction will eventually result in the kernel's entry function being called.

This is a good example of how the linker works, since we haven't really exploited this important tool yet. The linker
takes object files as inputs, then joins them together, but resolves any labels to their correct addresses. 

For example, if one object file has a piece of code that has a call to a function, `some function`, defined in another
object file, then after the object file's code has been physically linked together into one file, the label `:code:some function` will be resolved to the offset of wherever that particular routine ended up in the combined code.


### Compiling the Kernel-Entry and the Kernel into one Binary ###

#### Compile kernel entry to an object file for linking ####

`nasm kernel_entry.asm -f elf -o kernel_entry.o`

The `-f elf` option tells the assembler to output an object file of the format `Executable and Linking Format (ELF)`,
which is the default format output by our C compiler.

#### Linking the Kernel and Kernel Entry Object files ####

`i386-elf-ld -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --ofromat binary`

The linker respects the order of the files we give it on the command line, so the previous command will ensure that the
kernel_entry.o code will precede the code in kernel.o

#### Creating the OS Image ####

`cat boot_sect.bin kernel.bin > os-kernel.img`
