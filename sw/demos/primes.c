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
    int primes[15];
    int count = 0;

    for (int n = 2; n < 50; n++) {
        int is_prime = 1;
        for (int i = 2; i < n; i++) {
            int temp = n;
            while(temp >= i) {
                temp -= i;
            }
            if (temp == 0) {
                is_prime = 0;
                break;
            }
        }
        if (is_prime) {
            primes[count] = n;
            count++;
        }
    }

    unsigned int cycles = *CYCLE_CNT;
    unsigned int instrs = *INSTR_CNT;
    unsigned int stalls = *STALL_CNT;
    unsigned int flushes = *FLUSH_CNT;

    putchar('P'); putchar('R'); putchar('M'); putchar('\r'); putchar('\n');
    for (int i = 0; i < count; i++) {
        print_hex(primes[i]); putchar('\r'); putchar('\n');
    }
    
    putchar('C'); putchar(':'); print_hex(cycles); putchar('\r'); putchar('\n');
    putchar('I'); putchar(':'); print_hex(instrs); putchar('\r'); putchar('\n');
    putchar('S'); putchar(':'); print_hex(stalls); putchar('\r'); putchar('\n');
    putchar('F'); putchar(':'); print_hex(flushes); putchar('\r'); putchar('\n');
    putchar('D'); putchar('O'); putchar('N'); putchar('E'); putchar('\r'); putchar('\n');

    return 0;
}
