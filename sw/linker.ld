MEMORY
{
  ROM (rx) : ORIGIN = 0x00000000, LENGTH = 4K
  RAM (rw) : ORIGIN = 0x00000000, LENGTH = 4K
}

SECTIONS
{
  /* Instructions */
  .text : {
    *(.init)
    *(.text*)
  } > ROM

  /* Read-only and initialized data */
  /* Note: In a strict Harvard architecture without a unified bus, the CPU cannot 
     load this from ROM to RAM. Avoid initialized globals or .rodata. */
  .data : {
    *(.rodata*)
    *(.srodata*)
    *(.data*)
    *(.sdata*)
  } > RAM AT > ROM
  
  /* Uninitialized data */
  .bss (NOLOAD) : {
    __bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(COMMON)
    __bss_end = .;
  } > RAM

  /* Stack at the top of the 4KB data RAM */
  __stack_top = 0x00001000;
}
