#include "../lib/uart.h"

// Hardware-mapped performance counters
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
    for (int i = 7; i >= 0; i--) {
        putchar(hex_chars[(val >> (i * 4)) & 0xF]);
    }
}

int main() {
    int large_data[20];
    large_data[0] = 15; large_data[1] = 3; large_data[2] = 9; large_data[3] = 8;
    large_data[4] = 19; large_data[5] = 1; large_data[6] = 14; large_data[7] = 2;
    large_data[8] = 7; large_data[9] = 11; large_data[10] = 5; large_data[11] = 18;
    large_data[12] = 0; large_data[13] = 13; large_data[14] = 12; large_data[15] = 10;
    large_data[16] = 4; large_data[17] = 16; large_data[18] = 17; large_data[19] = 6;
    
    // Bubble sort 20 elements = ~190 inner loop iterations.
    for (int i = 0; i < 19; i++) {
        for (int j = 0; j < 19 - i; j++) {
            if (large_data[j] > large_data[j+1]) {
                int temp = large_data[j];
                large_data[j] = large_data[j+1];
                large_data[j+1] = temp;
            }
        }
    }
    
    // Read performance counters
    unsigned int cycles = *CYCLE_CNT;
    unsigned int instrs = *INSTR_CNT;
    unsigned int stalls = *STALL_CNT;
    unsigned int flushes = *FLUSH_CNT;

    putchar('C'); putchar(':'); print_hex(cycles); putchar('\r'); putchar('\n');
    putchar('I'); putchar(':'); print_hex(instrs); putchar('\r'); putchar('\n');
    putchar('S'); putchar(':'); print_hex(stalls); putchar('\r'); putchar('\n');
    putchar('F'); putchar(':'); print_hex(flushes); putchar('\r'); putchar('\n');

    // Print the sorted array
    putchar('\r'); putchar('\n');
    for (int k = 0; k < 20; k++) {
        print_hex(large_data[k]);
        putchar('\r'); putchar('\n');
    }

    putchar('D'); putchar('O'); putchar('N'); putchar('E'); putchar('\r'); putchar('\n');

    return 0;
}
