.section .init
.global _start

_start:
    /* Initialize stack pointer to top of RAM (4KB) */
    li sp, 0x00001000

    /* Clear the .bss section */
    la a0, __bss_start
    la a1, __bss_end
    bge a0, a1, bss_clear_done
bss_clear_loop:
    sw zero, 0(a0)
    addi a0, a0, 4
    blt a0, a1, bss_clear_loop
bss_clear_done:

    /* Jump to C main */
    call main

    /* If main returns, halt the processor using ECALL */
halt:
    ecall
    j halt
