//
// NOTE: The port number is expected to be sepcified in DX.
//
// GCC uses GAS (AT&T's style) for inline assemble
// as compared to the NASM style.

unsigned char port_byte_in(unsigned short port) {
    // A handy C wrapper function that reads a byte from 
    // the specified port.
    // "=a" (result) means: put AL register in variable RESULT
    // when finished.
    // "d" (port) means: load EDX with port.

    unsigned char result;
    __asm__("in %%dx, %%al" : "=a" (result) : "d" (port));
    return result;
}

void port_byte_out(unsigned short port, unsigned char data) {
    // A handy C wrapper function that writes a byte
    // to the specified port.
    // "a" (data) means: load EAX with data
    // "d" (port) means: load EDX with port

    __asm__("out %%al, %%dx" : "a" (data) : "d" (port));
}

unsigned short port_word_in(unsigned short port) {
    // A handy C wrapper that reads a word  (2 bytes) 
    // form the specified port.

    unsigned short result;
    __asm__("in %%dx, %%ax" : "=a"  (result) : "d" (port));
    return result;
}

void port_word_out(unsigned short port, unsigned short data) {
    // A handy C wrapper function that writes a word
    // (2 bytes) to the specified port.

    __asm__("out %%ax, %%dx" : "a" (data) : "d" (port));
}
