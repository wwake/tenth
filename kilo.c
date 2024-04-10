#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>

struct termios orig_termios;

void die(const char *s) {
  perror(s);
  exit(1);
}

void disableRawMode() {
  if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios) == -1)
    die("tcsetattr");
}

union bytes72 {
	unsigned char bytes[72];
	struct termios term;
};

void printTermStruct(struct termios *pStruct) {
	union bytes72 mybytes;
	mybytes.term = *pStruct;
	for (int i = 0; i < 72; i++) {
		printf("%02x ", mybytes.bytes[i]);
		if (i % 8 == 7) { printf("\n"); }
	}
}

void enableRawMode() {
	if (tcgetattr(STDIN_FILENO, &orig_termios) == -1) die("tcgetattr");
	atexit(disableRawMode);

	struct termios raw = orig_termios;

	printf("echo=%d\n", ECHO);
	printf("icanon=%d\n\n", ICANON);
	
	printf("Before:\n");
	printTermStruct(&raw);


//  raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
//  raw.c_oflag &= ~(OPOST);
//  raw.c_cflag |= (CS8);
//	raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
	raw.c_lflag &= ~(ECHO | ICANON);
//  raw.c_cc[VMIN] = 0;
//  raw.c_cc[VTIME] = 1;

	printf("After:\n");
	printTermStruct(&raw);

  if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) == -1) die("tcsetattr");
}

int main() {
  enableRawMode();

  while (1) {
    char c = '\0';
    if (read(STDIN_FILENO, &c, 1) == -1 && errno != EAGAIN) die("read");
    if (iscntrl(c)) {
      printf("%d\r\n", c);
    } else {
      printf("%d ('%c')\r\n", c, c);
    }
    if (c == 'q') break;
  }

  return 0;
}
