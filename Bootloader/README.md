# Loading the Bootloader in QEMU

To start the emulation use the following command which defaults to using a hard drive for the boot device.

```bash
qemu-system-i386 boot_sect.bin
```

Optionally, you can specify whether to use a floppy or hard drive as follows:

```bash
qemu-system-i386 -fda boot_sect.bin    # Floppy Disk
qemu-system-i386 -hda boot_sect.bin    # Hard Disk
```
