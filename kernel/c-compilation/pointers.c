// Here, the start following th etype means that this is not
// a variable to hold a char (i.e. a single byte) but a
// pointer to the ADDRESS of a char, which, being an address,
// will actually require the allocation of at least 32-bits.

char* video_address = 0xb8000;

// If we'd like to store a character at the address pointed to,
// we make the assignment with a star-prefixed pointer
// variable, becuase we are not changing the address held by
// the pointer variable but the contents of that address.

*video_address = 'X';

// Just to emphasise the purpose of the star, an ommission of
// it, such as:

video_address = 'X';

// would erroneously store the ASCII code of 'X', in the
// pointer variable, such that it may later be interpretted
// as an address.
