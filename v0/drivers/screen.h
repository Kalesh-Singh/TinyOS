#define VIDEO_ADDRESS 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80
// Attribute byte for our default color scheme
#define WHITE_ON_BLACK 0x0f

// Screen device I/O ports
#define REG_SCREEN_CTRL 0x3d4
#define REG_SCREEN_DATA 0x3d5

/* Print a char on the screen at col, row, or at cursor position */
void print_char(char ch, int col, int row, char attr_byte);

/* Maps row and col coordinates to the memory offset of a
 * particular display character cell from the start of video
 * memory. */
int get_screen_offset(int col, int row);

/* Returns the offset of the cursor from the start of
 * video memory. */
int get_cursor();

/* Sets the screen cursor based on the character cell offset
 * specified. */
void set_cursor(int offset);

/* Takes a pointer to the first character of a string
 * and prints each subsequent character, one after the
 * other from the given coordinates. If the coordinates
 * (-1, -1) are passed, then it will start printing from
 * the current cursor location. */
void print_at(char* msg, int col, int row);

/* A convenience function for printing at the current cursor
 * location. */
 void print(char* msg);

/* Writes blank characters to every position on the screen */
void clear_screen();

/* Advance the text cursor, scrolling the video buffer if necessary. */
int handle_scrolling(int cursor_offset);
