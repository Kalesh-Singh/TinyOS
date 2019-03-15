//
// A simple kernel - that simply lets us know that it has 
// been loaded by printing to the screen;
//

#include "../drivers/screen.h"

void main() {
    print("Tiny OS Kernel has been loaded\n");
    print("Yay the newline works");

    print("\nNow it's time to test the scrolling.\n");
    print("\nNow it's time to test the scrolling.\n");
    print("\nNow it's time to test the scrolling.\n");
    print("\nNow it's time to test the scrolling.\n");
    print("\nNow it's time to test the scrolling.\n");
    print("\nYay! The scrolling works!\n");
}
