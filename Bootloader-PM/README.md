# Switching to 32-bit Protected Mode #
The most difficult part about switching the CPU from 16-bit real mode into 32-bit protected mode is that we must prepare a complex data structure in memory called the global descriptor table (GDT), which defines memory segments and their protected-mode attributes. Once we have defined the GDT, we can use a special instruction to load it into the CPU, before setting a single bit in a special CPU control register to make the actual switch.

*NOTE: We can no longer use BIOS once switched into 32-bit protected mode.*

BIOS routines, having been coded to work only in 16-bit real mode, are no longer valid in 32-bit protected mode; indeed, attempting to use them would likely crash the machine. So what this means is that a 32-bit operating system must provide its own drivers for all hardware of the machine (e.g. the keybaord, screen, disk drives, mouse, etc).
