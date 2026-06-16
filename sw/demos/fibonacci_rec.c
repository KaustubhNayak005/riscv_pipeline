#include "../lib/uart.h"

volatile unsigned int* const CYCLE_CNT = (volatile unsigned int*)0xC0000000;
volatile unsigned int* const INSTR_CNT = (volatile unsigned int*)0xC0000004;
volatile unsigned int* const STALL_CNT = (volatile unsigned int*)0xC0000008;
volatile unsigned int* const FLUSH_CNT = (volatile unsigned int*)0xC000000C;

void print_hex(unsigned int val) {
    char hex_chars[16] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
    for (int i = 7; i >= 0; i--) putchar(hex_chars[(val >> (i * 4)) & 0xF]);
}

int fib(int n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

int main() {
    int result = fib(15);
    
    unsigned int cycles = *CYCLE_CNT;
    unsigned int instrs = *INSTR_CNT;
    unsigned int stalls = *STALL_CNT;
    unsigned int flushes = *FLUSH_CNT;

    putchar('F'); putchar('I'); putchar('B'); putchar('\r'); putchar('\n');
    print_hex(result); putchar('\r'); putchar('\n');
    
    putchar('C'); putchar(':'); print_hex(cycles); putchar('\r'); putchar('\n');
    putchar('I'); putchar(':'); print_hex(instrs); putchar('\r'); putchar('\n');
    putchar('S'); putchar(':'); print_hex(stalls); putchar('\r'); putchar('\n');
    putchar('F'); putchar(':'); print_hex(flushes); putchar('\r'); putchar('\n');
    putchar('D'); putchar('O'); putchar('N'); putchar('E'); putchar('\r'); putchar('\n');

    return 0;
}
