#include "../lib/uart.h"

volatile unsigned int* const CYCLE_CNT = (volatile unsigned int*)0xC0000000;
volatile unsigned int* const INSTR_CNT = (volatile unsigned int*)0xC0000004;
volatile unsigned int* const STALL_CNT = (volatile unsigned int*)0xC0000008;
volatile unsigned int* const FLUSH_CNT = (volatile unsigned int*)0xC000000C;

void print_hex(unsigned int val) {
    char hex_chars[16];
    hex_chars[0] = '0'; hex_chars[1] = '1'; hex_chars[2] = '2'; hex_chars[3] = '3';
    hex_chars[4] = '4'; hex_chars[5] = '5'; hex_chars[6] = '6'; hex_chars[7] = '7';
    hex_chars[8] = '8'; hex_chars[9] = '9'; hex_chars[10] = 'A'; hex_chars[11] = 'B';
    hex_chars[12] = 'C'; hex_chars[13] = 'D'; hex_chars[14] = 'E'; hex_chars[15] = 'F';
    for (int i = 7; i >= 0; i--) putchar(hex_chars[(val >> (i * 4)) & 0xF]);
}

int main() {
    // Fill an array with bytes using loops and math
    char data[64];
    for (int i = 0; i < 64; i++) {
        data[i] = (i * 13) & 0xFF; // Generate pseudo-random bytes
    }
    
    // Pattern to match
    char pattern = 0x1A;
    int match_count = 0;

    for (int i = 0; i < 64; i++) {
        if (data[i] == pattern) {
            match_count++;
        }
    }

    unsigned int cycles = *CYCLE_CNT;
    unsigned int instrs = *INSTR_CNT;
    unsigned int stalls = *STALL_CNT;
    unsigned int flushes = *FLUSH_CNT;

    putchar('S'); putchar('T'); putchar('R'); putchar('\r'); putchar('\n');
    print_hex(match_count); putchar('\r'); putchar('\n');
    
    putchar('C'); putchar(':'); print_hex(cycles); putchar('\r'); putchar('\n');
    putchar('I'); putchar(':'); print_hex(instrs); putchar('\r'); putchar('\n');
    putchar('S'); putchar(':'); print_hex(stalls); putchar('\r'); putchar('\n');
    putchar('F'); putchar(':'); print_hex(flushes); putchar('\r'); putchar('\n');
    putchar('D'); putchar('O'); putchar('N'); putchar('E'); putchar('\r'); putchar('\n');

    return 0;
}
