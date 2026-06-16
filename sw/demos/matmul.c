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
    int A[3][3];
    A[0][0] = 1; A[0][1] = 2; A[0][2] = 3;
    A[1][0] = 4; A[1][1] = 5; A[1][2] = 6;
    A[2][0] = 7; A[2][1] = 8; A[2][2] = 9;

    int B[3][3];
    B[0][0] = 9; B[0][1] = 8; B[0][2] = 7;
    B[1][0] = 6; B[1][1] = 5; B[1][2] = 4;
    B[2][0] = 3; B[2][1] = 2; B[2][2] = 1;

    int C_mat[3][3];

    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            C_mat[i][j] = 0;
            for (int k = 0; k < 3; k++) {
                C_mat[i][j] += A[i][k] * B[k][j];
            }
        }
    }

    unsigned int cycles = *CYCLE_CNT;
    unsigned int instrs = *INSTR_CNT;
    unsigned int stalls = *STALL_CNT;
    unsigned int flushes = *FLUSH_CNT;

    putchar('M'); putchar('A'); putchar('T'); putchar('\r'); putchar('\n');
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            print_hex(C_mat[i][j]); putchar('\r'); putchar('\n');
        }
    }
    
    putchar('C'); putchar(':'); print_hex(cycles); putchar('\r'); putchar('\n');
    putchar('I'); putchar(':'); print_hex(instrs); putchar('\r'); putchar('\n');
    putchar('S'); putchar(':'); print_hex(stalls); putchar('\r'); putchar('\n');
    putchar('F'); putchar(':'); print_hex(flushes); putchar('\r'); putchar('\n');
    putchar('D'); putchar('O'); putchar('N'); putchar('E'); putchar('\r'); putchar('\n');

    return 0;
}
