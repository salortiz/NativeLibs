#include <stdio.h>
#ifdef _WIN32
#define FRMT "%I64u"
#else
#define FRMT "%lu"
#endif
int main() {
    printf("size: "FRMT, sizeof(int));
}
