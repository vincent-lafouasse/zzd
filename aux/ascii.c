#include <stdio.h>

int main(void) {
	for (int i = 0; i < 256; i++) {
		char c = (char)i;
		printf("%c", c);
	}
}
