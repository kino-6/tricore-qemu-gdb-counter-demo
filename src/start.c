#include <stdint.h>

extern int main(void);

/* crt0.S -> _start -> ここに入る。リンカ記号は一切触らない */
__attribute__((noreturn))
void _start_c(void) {
    (void)main();
    for (;;);
}
