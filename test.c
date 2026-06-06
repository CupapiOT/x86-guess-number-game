#include <stdio.h>
#include <unistd.h>
#include <stddef.h>

int main() {
  char buf[8];
  ssize_t bytes_read = read(0, buf, 8);
  while (1) {
    read(0, buf, 1);
    if (buf[0] == '\n')
      break;
    // printf("%c", buf[0]);
    // fflush(stdout);
  }
  printf("\n");
  printf("%s\n", buf);
  printf("%zu\n", bytes_read);
  return 0;
}
