#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "base_elf.h"

int main() {
  FILE *fp = fopen("binz.o", "wb");
  if (!fp) {
    perror("Failed to create binary");
    return 1;
  }

  fwrite(build_hello, build_hello_len, 1, fp);
  fclose(fp);

  printf("Binary 'binz.o' created!\n");
  return 0;
}