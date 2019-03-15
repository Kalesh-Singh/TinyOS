#include "screen.h"
#include "../kernel/util.h"
#include "../kernel/low_level.h"

/* Print a char on the screen at col, row, or at cursor position */
void print_char(char ch, int col, int row, char attr_byte) {
    // Create a byte (char) pointer to the start of video memory
    unsigned char* vidmem = (unsigned char*) VIDEO_ADDRESS;

    // If attr_byte is 0, assume the default style.
    if (!attr_byte) {
        attr_byte = WHITE_ON_BLACK;
    }

    // Get the video memory offset for the screen location
    int offset;
    if (col >= 0 && row >=0) {
        offset = get_screen_offset(col, row);
    } else {
    // Otherwise use the current cursor position.
        offset = get_cursor();
    }

    // If we see a new line char, set offset to the end of
    // the current row, so it will advance to the first col
    // of the next row.
    if (ch == '\n') {
        int rows = offset / (2 * MAX_COLS);
        offset = get_screen_offset(79, rows);
    } else {
    // Otherwise, write the character and its attr_byte
    // to video memory at our calculated offset.
        vidmem[offset] = ch;
        vidmem[offset+1] = attr_byte;
    }

    // Update the offset to the next character cell, which is
    // 2 bytes ahead of the current cell.
    offset += 2;

    // Make scrolling adjustment, for when we reach the 
    // bottom of the screen.
    offset = handle_scrolling(offset);

    // Update the cursor position on the screen device.
    set_cursor(offset);
}

/* Maps row and col coordinates to the memory offset of a
 * particular display character cell from the start of video
 * memory. */
int get_screen_offset(int col, int row) {
    return 2 * (row * MAX_COLS + col);
}

/* Returns the offset of the cursor from the start of
 * video memory. */
int get_cursor() {
    // The device uses its control register as an index to
    // select its internal registers, of which we are
    // interested in.
    // reg 14: which is the high byte of the cursor's offset
    // reg 15: which is the low byte of the cursor's offset
    //
    // Once the internal register has been selected, we may
    // read or write a byte on the data register.
    port_byte_out(REG_SCREEN_CTRL, 14);
    int offset = port_byte_in(REG_SCREEN_DATA) << 8;
    port_byte_out(REG_SCREEN_CTRL, 15);
    offset += port_byte_in(REG_SCREEN_DATA);

    // Since the cursor offset reported by the VGA hardware
    // is the number of characters, we multiply it by two to
    // convert it to a character cell offset.
    return offset * 2;
}

/* Sets the screen cursor based on the character cell offset
 * specified. */
void set_cursor(int offset) {
    // Convert character cell offset to cursor offset
    // (i.e number of characters).
    offset /= 2;

    // This is similar to get_cursor, only now we write
    // bytes to those internal device registers.
    port_byte_out(REG_SCREEN_CTRL, 14);
    port_byte_out(REG_SCREEN_DATA, (unsigned char) (offset >> 8));
    port_byte_out(REG_SCREEN_CTRL, 15);
    port_byte_out(REG_SCREEN_DATA, (unsigned char) (offset));
}

/* Takes a pointer to the first character of a string
 * and prints each subsequent character, one after the
 * other from the given coordinates. If the coordinates
 * (-1, -1) are passed, then it will start printing from
 * the current cursor location. */
void print_at(char* msg, int col, int row) {
    // Update the cursor if col and row are not negative.
    if (col >= 0 && row >= 0) {
        set_cursor(get_screen_offset(col, row));
    }

    // Loop through each character of the message and 
    // print it.
    int i = 0;
    while (msg[i] != 0) {
        print_char(msg[i++], col, row, WHITE_ON_BLACK);
    }
}

/* A convenience function for printing at the current cursor
 * location. */
void print(char* msg) {
    print_at(msg, -1, -1);
}

/* Writes blank characters to every position on the screen */
void clear_screen() {
    int row = 0;
    int col = 0;

    // Loop through video memory and write blank characters.
    for (row = 0; row < MAX_ROWS; row++) {
        for (col = 0; col < MAX_COLS; col++) {
            print_char(' ', col, row, WHITE_ON_BLACK);
        }
    }

    // Move the cursor back to the top left.
    set_cursor(get_screen_offset(0, 0));
}

/* Advance the text cursor, scrolling the video buffer if necessary. */
int handle_scrolling(int cursor_offset) {
    // If the cursor is within the screen, return it unmodified.
    if (cursor_offset < MAX_ROWS * MAX_COLS * 2) {
        return cursor_offset;
    }

    // Shuffle the rows back by 1.
    int i;
    for (i = 1; i < MAX_ROWS; i++) {
        memory_copy((char*) (get_screen_offset(0, i) + VIDEO_ADDRESS),
                (char*) (get_screen_offset(0, i-1) + VIDEO_ADDRESS),
                MAX_COLS * 2);
    }

    // Blank the last line by setting all bytes to 0.
    char* last_line = (char*) (get_screen_offset(0, MAX_ROWS-1) + VIDEO_ADDRESS);
    for (i = 0; i < MAX_COLS * 2; i++) {
        last_line[i] = 0;
    }

    // Move the offset back one row, such that it is now on the 
    // last row, rather than off the edge of the screen.
    cursor_offset -= 2 * MAX_COLS;

    // Return the updated cursor position.
    return cursor_offset;
}

